import { useEffect, useState } from 'react';
import { act, createOrder, getOrder, listProducts, type Order, type Product } from './api';

export default function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [qty, setQty] = useState(1);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    listProducts()
      .then((data) => setProducts(data.products))
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  async function buy(product: Product) {
    setBusy(true);
    setError('');
    try {
      const order = await createOrder(product.sku, qty);
      setOrders((current) => [order, ...current.filter((item) => item.id !== order.id)]);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  async function run(order: Order, action: 'pay' | 'cancel' | 'ship' | 'complete' | 'refund') {
    setBusy(true);
    setError('');
    try {
      await act(order.id, action);
      const fresh = await getOrder(order.id);
      setOrders((current) => current.map((item) => (item.id === fresh.id ? fresh : item)));
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  if (loading) return <main><p role="status">加载商品…</p></main>;

  return (
    <main>
      <h1>商品</h1>
      {error && <p role="alert">{error}</p>}
      <label>
        数量
        <input
          aria-label="数量"
          type="number"
          min={1}
          max={100}
          value={qty}
          onChange={(event) => setQty(Number(event.target.value))}
        />
      </label>
      <ul>
        {products.map((product) => (
          <li key={product.sku}>
            <strong>{product.title}</strong>
            <span> {product.sku} · ¥{(product.price_cents / 100).toFixed(2)} · 库存 {product.stock}</span>
            <button disabled={busy || product.stock < qty} onClick={() => buy(product)}>购买</button>
          </li>
        ))}
      </ul>
      <h2>我的订单</h2>
      {orders.length === 0 && <p>暂无订单</p>}
      <ul>
        {orders.map((order) => (
          <li key={order.id}>
            <span>#{order.id} {order.items?.[0]?.title} × {order.qty} · ¥{(Number(order.amount) / 100).toFixed(2)} · </span>
            <strong data-testid={`status-${order.id}`}>{order.status}</strong>
            <button disabled={busy} onClick={() => run(order, 'pay')}>支付</button>
            <button disabled={busy} onClick={() => run(order, 'cancel')}>取消</button>
          </li>
        ))}
      </ul>
    </main>
  );
}
