package dev.study.collab;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers(disabledWithoutDocker = true)
class MySqlContainerTest {
    @Container
    static final MySQLContainer<?> MYSQL = new MySQLContainer<>("mysql:8.4")
            .withDatabaseName("p02j")
            .withUsername("study")
            .withPassword("study-pass");

    @Test
    void containerStartsAndAcceptsQueries() throws Exception {
        try (Connection connection = DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword());
             Statement statement = connection.createStatement()) {
            statement.execute("CREATE TABLE smoke (id INT PRIMARY KEY, note VARCHAR(20) NOT NULL)");
            statement.execute("INSERT INTO smoke (id, note) VALUES (1, 'container')");
            try (ResultSet result = statement.executeQuery("SELECT note FROM smoke WHERE id = 1")) {
                assertThat(result.next()).isTrue();
                assertThat(result.getString(1)).isEqualTo("container");
            }
        }
    }
}
