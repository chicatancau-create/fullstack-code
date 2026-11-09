import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import App from '../App';

const order = {
  id: 7, status: 'pending_payment', amount: 1999, qty: 1,
  items: [{ title: '键盘', qty: 1 }],
};

describe('交易前端', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('展示商品并在购买后显示订单状态', async () => {
    vi.stubGlobal('fetch', vi.fn(async (url: string) => {
      if (String(url).endsWith('/products')) {
        return new Response(JSON.stringify({ products: [{ sku: 'KB-1', title: '键盘', price_cents: 1999, stock: 5 }] }), { status: 200 });
      }
      return new Response(JSON.stringify(order), { status: 201 });
    }));
    render(<App />);
    expect(await screen.findByText('键盘')).toBeInTheDocument();
    fireEvent.click(screen.getByText('购买'));
    expect(await screen.findByText('pending_payment')).toBeInTheDocument();
  });

  it('接口失败时显示错误', async () => {
    vi.stubGlobal('fetch', vi.fn(async () => new Response(JSON.stringify({ error: 'out_of_stock' }), { status: 409 })));
    render(<App />);
    await waitFor(() => expect(screen.getByRole('alert')).toHaveTextContent('out_of_stock'));
  });
});
