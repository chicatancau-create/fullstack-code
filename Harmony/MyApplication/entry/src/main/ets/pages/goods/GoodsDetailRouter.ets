import { Goods } from '../../data/interface'
import Title from '../component/Title'

@Entry
@Component
struct GoodsDetailRouter {
  @State item: Goods = { id: 0, goodsName: '', goodsContent: '', goodsQuantity: 0, icon: '01.png', goodsPrice: 0 }

  // 第 10 章 Router 写法：页面显示时用 getParams 取列表传过来的商品
  onPageShow(): void {
    const params: Object | undefined = this.getUIContext().getRouter().getParams()
    if (params !== undefined) {
      this.item = params as Goods
    }
  }

  build() {
    Column({ space: 12 }) {
      Title({ title: '商品详情', arrow: true })
      Image($rawfile(this.item.icon))
        .width(180)
        .height(180)
        .objectFit(ImageFit.Contain)
      Text(this.item.goodsName)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('90%')
      Text(`￥${this.item.goodsPrice}`)
        .fontSize(16)
        .fontColor('#E64545')
        .width('90%')
      Text(`库存：${this.item.goodsQuantity}`)
        .fontSize(14)
        .width('90%')
      Text(this.item.goodsContent)
        .fontSize(14)
        .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}
