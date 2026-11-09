import { test, expect } from '@playwright/test';

test('商品 → 下单 → 支付', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: '商品' })).toBeVisible();
  await page.getByRole('button', { name: '购买' }).first().click();
  await expect(page.getByText('pending_payment')).toBeVisible();
  await page.getByRole('button', { name: '支付' }).first().click();
  await expect(page.getByText('paid')).toBeVisible();
});
