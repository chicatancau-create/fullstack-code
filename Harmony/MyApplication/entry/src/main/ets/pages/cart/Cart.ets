import { CartItem } from '../../model/Data'
import { CartStore, connectCart } from '../../model/CartStore'
import { connectUser, User } from '../../model/User'

@ComponentV2
export default struct Cart {
  @Local store: CartStore = connectCart()
  @Local user: User = connectUser()
  @Local notice: string = ''

  // 11.4 步骤5：购物车在路由栈里，返回后必须靠 @Monitor 监听全局 user 变化才刷新 UI
  @Monitor('user.isLoggedIn')
  onUserChange(): void {
    this.notice = this.user.isLoggedIn ? `欢迎回来，${this.user.name}` : '已退出登录'
  }

  private total(): number {
    return this.store.items.reduce((sum: number, item: CartItem): number => sum + item.price * item.count, 0)
  }

  private change(index: number, delta: number): void {
    const item: CartItem = this.store.items[index]
    item.count += delta
    if (item.count <= 0) {
      this.store.items.splice(index, 1)
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('92%')

      if (this.notice !== '') {
        Text(this.notice)
          .fontSize(13)
          .fontColor('#1698CE')
          .width('92%')
      }

      if (this.store.items.length === 0) {
        Text('购物车是空的，去首页加几件')
          .fontSize(14)
          .fontColor('#9B9B9B')
          .margin({ top: 40 })
      }

      List({ space: 8 }) {
        ForEach(this.store.items, (item: CartItem, index: number) => {
          ListItem() {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(item.name).fontSize(16)
                Text(`¥${item.price}`)
                  .fontSize(14)
                  .fontColor('#E64545')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Row({ space: 16 }) {
                Text('－')
                  .fontSize(18)
                  .onClick(() => {
                    this.change(index, -1)
                  })
                Text(`${item.count}`).fontSize(16)
                Text('＋')
                  .fontSize(18)
                  .onClick(() => {
                    this.change(index, 1)
                  })
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F7F7F7')
          }
        }, (item: CartItem) => item.name)
      }
      .layoutWeight(1)
      .width('92%')

      Row() {
        Text('合计').fontSize(16)
        Text(`¥${this.total()}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E64545')
      }
      .width('92%')
      .justifyContent(FlexAlign.SpaceBetween)

      Button('结算')
        .width('92%')
        .onClick(() => {
          if (this.store.items.length === 0) {
            this.getUIContext().getPromptAction().showToast({ message: '购物车是空的' })
            return
          }
          const n: number = this.store.items.reduce((sum: number, item: CartItem): number => sum + item.count, 0)
          this.getUIContext().getPromptAction().showToast({ message: `已提交 ${n} 件商品` })
          this.store.items.splice(0, this.store.items.length)
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
