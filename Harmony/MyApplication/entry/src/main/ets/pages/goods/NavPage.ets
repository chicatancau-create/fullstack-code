import { Goods, listGoods } from '../../data/interface'
import GoodsDetail from '../goods/GoodsDetail'

@Entry
@Component
struct NavPage {
  @State pathStack: NavPathStack = new NavPathStack()

  // 路由表：根据 name 决定显示哪个目标页
  @Builder pageMap(name: string, param: object) {
    if (name === 'GoodsDetail') {
      GoodsDetail({ item: param as Goods })
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 10 }) {
        Text('点击商品查看详情')
          .fontSize(16)
        List({ space: 10 }) {
          ForEach(listGoods, (item: Goods) => {
            ListItem() {
              Row() {
                Image($rawfile(item.icon))
                  .width(50)
                  .height(50)
                Text(item.goodsName)
                  .fontSize(15)
                  .layoutWeight(1)
                Text(`￥${item.goodsPrice}`)
                  .fontSize(15)
                  .fontColor('#E64545')
              }
              .width('100%')
              .padding(10)
              .onClick(() => {
                // 把当前商品作为参数压入路由栈
                this.pathStack.pushPath({ name: 'GoodsDetail', param: item })
              })
            }
          }, (item: Goods) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(12)
    }
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .title('商品详情')
    .hideNavBar(false)
  }
}
