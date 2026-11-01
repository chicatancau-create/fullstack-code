import { AppStorageV2 } from '@kit.ArkUI'
import { CartItem } from './Data'

// 购物车改成 V2 可观测存储，配合 11.4 要求的 @Monitor 监听
@ObservedV2
export class CartStore {
  @Trace items: CartItem[] = []
}

export function connectCart(): CartStore {
  return AppStorageV2.connect<CartStore>(CartStore, (): CartStore => new CartStore())!
}

export function addCart(name: string, price: number): void {
  const store: CartStore = connectCart()
  const hit: CartItem | undefined = store.items.find((item: CartItem): boolean => item.name === name)
  if (hit !== undefined) {
    hit.count += 1
  } else {
    store.items.push(new CartItem(name, price))
  }
}
