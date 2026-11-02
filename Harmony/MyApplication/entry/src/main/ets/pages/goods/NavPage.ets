import { Goods, listGoods } from '../../data/interface'
import { GoodsDetailParam } from './GoodsDetailPage'

// 10.4：商品列表页根容器改为 Navigation，详情页交给系统路由表 router_map.json
@Entry
@Component
struct NavPage {
  @State pathStack: NavPathStack = new NavPathStack()

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
                // 10.4 步骤4：按名字跳转，只传商品 id，由详情页自己请求详情
                const arg: GoodsDetailParam = { goodsId: item.id }
                this.pathStack.pushPathByName('GoodsDetail', arg)
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
    .mode(NavigationMode.Stack)
    .title('商品列表')
    .hideNavBar(true)
  }
}
