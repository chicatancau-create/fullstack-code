export class Account {
  account: string = ''
  password: string = ''
  phone: string = ''

  constructor(account: string, password: string, phone: string) {
    this.account = account
    this.password = password
    this.phone = phone
  }
}

export class Goods {
  name: string = ''
  price: number = 0
  img: Resource = $r('app.media.dianqi')

  constructor(name: string, price: number, img: Resource) {
    this.name = name
    this.price = price
    this.img = img
  }
}

export class CartItem {
  name: string = ''
  price: number = 0
  count: number = 1

  constructor(name: string, price: number, count: number = 1) {
    this.name = name
    this.price = price
    this.count = count
  }
}

export function allGoods(): Goods[] {
  return [
    new Goods('冰箱', 1999, $r('app.media.bingxiang')),
    new Goods('电饭煲', 299, $r('app.media.dianfanbao')),
    new Goods('微波炉', 599, $r('app.media.weibolu')),
    new Goods('厨房电器', 899, $r('app.media.jiadiandianqi'))
  ]
}

export function findAccount(list: Account[], account: string): Account | undefined {
  return list.find((item: Account): boolean => item.account === account)
}

export function addCart(name: string, price: number): void {
  const list: CartItem[] = AppStorage.get<CartItem[]>('cartList') ?? []
  const hit: CartItem | undefined = list.find((item: CartItem): boolean => item.name === name)
  if (hit !== undefined) {
    hit.count += 1
  } else {
    list.push(new CartItem(name, price))
  }
  AppStorage.setOrCreate('cartList', list.slice())
}
