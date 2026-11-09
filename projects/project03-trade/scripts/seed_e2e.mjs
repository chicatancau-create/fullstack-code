// E2E 自备商品/库存种子，避免依赖历史残留数据。
import { createPool } from '../src/db.mjs';

const pool = createPool();
try {
  await pool.query(`INSERT INTO p03.products (sku, title, price_cents, active) VALUES
    ('sku-1', '机械键盘', 299, true), ('sku-2', '显示器', 1299, true)
    ON CONFLICT (sku) DO UPDATE SET title = EXCLUDED.title, price_cents = EXCLUDED.price_cents, active = true`);
  await pool.query(`INSERT INTO p03.inventory (sku, title, unit_price, stock) VALUES
    ('sku-1', '机械键盘', 299, 10), ('sku-2', '显示器', 1299, 1)
    ON CONFLICT (sku) DO UPDATE SET stock = EXCLUDED.stock, unit_price = EXCLUDED.unit_price`);
  console.log('e2e seed: sku-1 stock=10, sku-2 stock=1');
} finally {
  await pool.end();
}
