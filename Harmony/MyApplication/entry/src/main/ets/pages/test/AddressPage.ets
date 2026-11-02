import { Address, listAddress } from '../../data/interface'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_SUBTITLE,
  IMAGE_RADIUS,
  SPACE_MD,
  SPACE_SM,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

@Entry
@Component
struct AddressPage {
  @State addressList: Address[] = listAddress.slice()
  @State isRefreshing: boolean = false

  // 任务三：侧滑后露出的删除按钮，危险红底
  @Builder itemEnd(index: number) {
    Column() {
      Image($r('app.media.delete_left'))
        .width(22)
        .height(22)
        .fillColor('#FFFFFF')
    }
    .width(56)
    .height(64)
    .borderRadius(IMAGE_RADIUS)
    .backgroundColor(DANGER)
    .justifyContent(FlexAlign.Center)
    .margin({ left: SPACE_MD })
    .onClick(() => {
      this.addressList.splice(index, 1)
    })
  }

  build() {
    Column() {
      // 任务四：Refresh 包住 List，$$ 把转圈状态双向绑给 isRefreshing
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 10 }) {
          ForEach(this.addressList, (item: Address, index: number) => {
            // 任务二：一条地址 = 姓名 / 地址 / 电话 三行
            ListItem() {
              Column({ space: SPACE_SM }) {
                Text(`姓名：${item.name}`)
                  .fontSize(FONT_SUBTITLE)
                  .fontColor(TEXT_MAIN)
                  .width('100%')
                Text(`地址：${item.address}`)
                  .fontSize(FONT_BODY)
                  .fontColor(TEXT_MAIN)
                  .width('100%')
                Text(`电话：${item.phone}`)
                  .fontSize(FONT_BODY)
                  .fontColor(TEXT_MUTED)
                  .width('100%')
              }
              .padding(SPACE_MD)
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
            .swipeAction({
              end: {
                builder: this.itemEnd(index)
              }
            })
          }, (item: Address) => JSON.stringify(item))
            // 任务五：长按列表项拖到新位置
            .onMove((from: number, to: number) => {
              const item: Address = this.addressList[from]
              this.addressList.splice(from, 1)
              this.addressList.splice(to, 0, item)
            })
        }
        .width('100%')
        .height('100%')
        .padding({ left: SPACE_MD, right: SPACE_MD })
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.addressList = listAddress.slice()
          this.isRefreshing = false
        }, 1500)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
