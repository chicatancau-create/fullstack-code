import { CartItem } from '../../model/Data'
import { CartStore, connectCart } from '../../model/CartStore'
import { connectUser, User } from '../../model/User'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_CAPTION,
  FONT_PRICE,
  FONT_SUBTITLE,
  IMAGE_RADIUS,
  INPUT_BG,
  PRIMARY,
  PRIMARY_TINT,
  SPACE_MD,
  SPACE_SM,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED,
  TEXT_ON_PRIMARY
} from '../../common/UiTokens'

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

  private count(): number {
    return this.store.items.reduce((sum: number, item: CartItem): number => sum + item.count, 0)
  }

  private change(index: number, delta: number): void {
    const item: CartItem = this.store.items[index]
    item.count += delta
    if (item.count <= 0) {
      this.store.items.splice(index, 1)
    }
  }

  // 数量按钮：圆角方块，按下变浅
  @Builder countBtn(label: string, index: number, delta: number) {
    Text(label)
      .fontSize(FONT_SUBTITLE)
      .fontColor(PRIMARY)
      .width(30)
      .height(30)
      .textAlign(TextAlign.Center)
      .borderRadius(IMAGE_RADIUS)
      .backgroundColor(INPUT_BG)
      .onClick(() => {
        this.change(index, delta)
      })
  }

  build() {
    Column({ space: SPACE_SM }) {
      Text('购物车')
        .fontSize(FONT_PRICE)
        .fontWeight(FontWeight.Bold)
        .fontColor(TEXT_MAIN)
        .width('92%')

      if (this.notice !== '') {
        Text(this.notice)
          .fontSize(FONT_BODY)
          .fontColor(PRIMARY)
          .width('92%')
      }

      if (this.store.items.length === 0) {
        // 空态：图形 + 文案居中
        Column({ space: SPACE_SM }) {
          Image($r('app.media.cart_full'))
            .width(56)
            .height(56)
            .fillColor(PRIMARY_TINT)
          Text('购物车是空的，去首页加几件')
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.store.items, (item: CartItem, index: number) => {
            ListItem() {
              Row({ space: SPACE_MD }) {
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(FONT_SUBTITLE)
                    .fontColor(TEXT_MAIN)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`¥${item.price}`)
                    .fontSize(FONT_BODY)
                    .fontColor(DANGER)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Row({ space: SPACE_XS }) {
                  this.countBtn('－', index, -1)
                  Text(`${item.count}`)
                    .fontSize(FONT_SUBTITLE)
                    .fontColor(TEXT_MAIN)
                    .width(28)
                    .textAlign(TextAlign.Center)
                  this.countBtn('＋', index, 1)
                }
              }
              .width('100%')
              .padding(SPACE_MD)
              .alignItems(VerticalAlign.Center)
            }
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
            }, (item: CartItem) => item.name)
        }
        .layoutWeight(1)
        .width('92%')
        .scrollBar(BarState.Off)
      }

      // 吸底合计条
      Column({ space: SPACE_XS }) {
        Row({ space: SPACE_XS }) {
          Text('合计')
            .fontSize(FONT_SUBTITLE)
            .fontColor(TEXT_MAIN)
          Text(`共 ${this.count()} 件`)
            .fontSize(FONT_CAPTION)
            .fontColor(TEXT_MUTED)
          Blank()
          Text(`¥${this.total()}`)
            .fontSize(FONT_PRICE)
            .fontWeight(FontWeight.Bold)
            .fontColor(DANGER)
        }
        .width('100%')

        Button('结算')
          .width('100%')
          .height(44)
          .fontSize(FONT_SUBTITLE)
          .fontColor(TEXT_ON_PRIMARY)
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
      .width('92%')
      .padding(SPACE_MD)
      .borderRadius(CARD_RADIUS)
      .backgroundColor(CARD_BG)
      .margin({ bottom: SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .padding({ top: SPACE_MD })
    .backgroundColor(BG_PAGE)
  }
}
