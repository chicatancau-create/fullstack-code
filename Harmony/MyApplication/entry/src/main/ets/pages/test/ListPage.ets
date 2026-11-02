import { Goods, listGoods } from '../../data/interface'
import { DetailArg } from '../../utils/requestUtils'
import Title from '../component/Title'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_PRICE,
  FONT_SUBTITLE,
  IMAGE_RADIUS,
  SPACE_MD,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

@Entry
@Component
struct ListPage {
  @State goodsList: Goods[] = listGoods.slice()
  @State isRefreshing: boolean = false

  // 侧滑后露出的删除按钮
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
      this.goodsList.splice(index, 1)
    })
  }

  build() {
    Column({ space: 6 }) {
      Title({ title: '商品列表', isShow: true })
      // 下拉刷新：refreshing 双向绑定 isRefreshing
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 10 }) {
          ForEach(this.goodsList, (item: Goods, index: number) => {
            ListItem() {
              Row({ space: SPACE_MD }) {
                Image($rawfile(item.icon))
                  .width(60)
                  .height(60)
                  .borderRadius(IMAGE_RADIUS)
                  .backgroundColor('#F7F8FA')
                Column({ space: 4 }) {
                  Text(item.goodsName)
                    .fontSize(FONT_SUBTITLE)
                    .fontColor(TEXT_MAIN)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`库存 ${item.goodsQuantity}`)
                    .fontSize(FONT_BODY)
                    .fontColor(TEXT_MUTED)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text(`￥${item.goodsPrice}`)
                  .fontSize(FONT_PRICE)
                  .fontColor(DANGER)
                  .fontWeight(FontWeight.Medium)
                Image($r('app.media.jiantouyou'))
                  .width(14)
                  .height(14)
                  .fillColor(TEXT_MUTED)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('94%')
            .padding(SPACE_MD)
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
            // 第 10 章：点击列表项，把当前商品作为参数传给详情页
            .onClick(() => {
              const arg: DetailArg = {
                title: item.goodsName,
                priceText: `￥${item.goodsPrice}`,
                content: item.goodsContent,
                image: item.icon,
                stockText: `库存：${item.goodsQuantity}`
              }
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/goods/GoodsDetailRouter',
                params: arg
              })
            })
            .swipeAction({
              end: {
                builder: this.itemEnd(index)
              }
            })
          }, (item: Goods) => JSON.stringify(item))
            // 长按拖拽换序
            .onMove((from: number, to: number) => {
              const item: Goods = this.goodsList[from]
              this.goodsList.splice(from, 1)
              this.goodsList.splice(to, 0, item)
            })
        }
        .width('100%')
        .height('100%')
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.goodsList = listGoods.slice()
          this.isRefreshing = false
        }, 1500)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
