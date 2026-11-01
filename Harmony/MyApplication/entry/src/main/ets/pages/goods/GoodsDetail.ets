import { Goods } from '../../data/interface'

// 商品详情：Navigation 的目标内容组件，不单独登记路由
@Component
export default struct GoodsDetail {
  item: Goods = { id: 0, goodsName: '', goodsContent: '', goodsQuantity: 0, icon: '01.png', goodsPrice: 0 }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Image($rawfile(this.item.icon))
          .width(160)
          .height(160)
        Text(this.item.goodsName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(`￥${this.item.goodsPrice}`)
          .fontSize(16)
          .fontColor('#E64545')
        Text(`库存：${this.item.goodsQuantity}`)
          .fontSize(14)
        Text(this.item.goodsContent)
          .fontSize(14)
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .title('商品详情')
  }
}
