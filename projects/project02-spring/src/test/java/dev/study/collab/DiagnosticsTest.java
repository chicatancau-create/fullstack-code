package dev.study.collab;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Objects;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@ActiveProfiles("test")
class DiagnosticsTest {
    @Autowired
    DataSource dataSource;
    @Autowired
    JdbcTemplate jdbc;

    @Value("${spring.datasource.url}")
    String url;
    @Value("${spring.datasource.username}")
    String username;
    @Value("${spring.datasource.password}")
    String password;

    @BeforeEach
    void reset() {
        jdbc.execute("CREATE TABLE IF NOT EXISTS diag_locks (id INT PRIMARY KEY, v INT NOT NULL) ENGINE=InnoDB");
        jdbc.update("DELETE FROM diag_locks");
        jdbc.update("INSERT INTO diag_locks (id, v) VALUES (1, 0), (2, 0)");
    }

    @Test
    void innodbDetectsDeadlockAndRollsBackOneTransaction() throws Exception {
        ExecutorService workers = Executors.newFixedThreadPool(2);
        try (Connection first = dataSource.getConnection(); Connection second = dataSource.getConnection()) {
            first.setAutoCommit(false);
            second.setAutoCommit(false);
            update(first, 1);
            update(second, 2);

            CountDownLatch start = new CountDownLatch(1);
            Future<SQLException> a = workers.submit(() -> crossUpdate(start, first, 2));
            Future<SQLException> b = workers.submit(() -> crossUpdate(start, second, 1));
            start.countDown();

            SQLException failureA = a.get(15, TimeUnit.SECONDS);
            SQLException failureB = b.get(15, TimeUnit.SECONDS);

            assertThat(Objects.nonNull(failureA) ^ Objects.nonNull(failureB))
                    .as("exactly one transaction must be rolled back by the deadlock detector")
                    .isTrue();
            SQLException deadlock = failureA != null ? failureA : failureB;
            assertThat(deadlock.getErrorCode()).isEqualTo(1213);

            first.rollback();
            second.rollback();
        } finally {
            workers.shutdownNow();
        }
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM diag_locks", Integer.class)).isEqualTo(2);
    }

    @Test
    void singleConnectionPoolTimesOutThenRecovers() throws Exception {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(username);
        config.setPassword(password);
        config.setMaximumPoolSize(1);
        config.setMinimumIdle(0);
        config.setConnectionTimeout(1000);
        config.setPoolName("diag-exhaustion-pool");

        try (HikariDataSource pool = new HikariDataSource(config)) {
            long started = System.nanoTime();
            try (Connection held = pool.getConnection()) {
                SQLException exhausted = assertThrows(SQLException.class, pool::getConnection);
                long waitedMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - started);
                assertThat(exhausted.getMessage()).contains("Connection is not available");
                assertThat(waitedMs).isBetween(900L, 5000L);
            }
            try (Connection recovered = pool.getConnection()) {
                assertThat(recovered.isValid(1)).isTrue();
            }
        }
    }

    private static SQLException crossUpdate(CountDownLatch start, Connection connection, int target) throws Exception {
        start.await(5, TimeUnit.SECONDS);
        try {
            update(connection, target);
            connection.commit();
            return null;
        } catch (SQLException error) {
            connection.rollback();
            return error;
        }
    }

    private static void update(Connection connection, int id) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate("UPDATE diag_locks SET v = v + 1 WHERE id = " + id);
        }
    }
}
