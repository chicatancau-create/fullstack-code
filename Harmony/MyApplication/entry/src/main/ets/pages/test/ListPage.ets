import { Goods, listGoods } from '../../data/interface'
import Title from '../component/Title'

@Entry
@Component
struct ListPage {
  @State goodsList: Goods[] = listGoods.slice()
  @State isRefreshing: boolean = false

  // 侧滑后露出的删除按钮
  @Builder itemEnd(index: number) {
    Image($r('app.media.delete_left'))
      .width(40)
      .height(40)
      .fillColor(Color.Red)
      .margin({ left: 20, right: 20 })
      .onClick(() => {
        this.goodsList.splice(index, 1)
      })
  }

  build() {
    Column() {
      Title({ title: '商品列表', arrow: true })
      // 下拉刷新：refreshing 双向绑定 isRefreshing
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 10 }) {
          ForEach(this.goodsList, (item: Goods, index: number) => {
            ListItem() {
              Row() {
                Image($rawfile(item.icon))
                  .width(60)
                  .height(60)
                Text(item.goodsName)
                  .fontSize(15)
                  .layoutWeight(1)
                Text(`￥${item.goodsPrice}`)
                  .fontSize(15)
                  .fontColor('#E64545')
              }
              .width('100%')
              .padding(10)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            // 第 10 章：点击列表项，把当前商品作为参数传给详情页
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/goods/GoodsDetailRouter',
                params: item
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
  }
}
