import { allGoods, addCart, Goods } from '../../model/Data'

@Component
export default struct Home {
  @State kw: string = ''
  private goods: Goods[] = allGoods()

  private shown(): Goods[] {
    if (this.kw === '') {
      return this.goods
    }
    return this.goods.filter((item: Goods): boolean => item.name.includes(this.kw))
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Image($r('app.media.sousuo'))
          .width(20)
          .fillColor('#6B6B6B')
        TextInput({ placeholder: '搜索家电' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => {
            this.kw = value
          })
      }
      .width('92%')

      Text('热门推荐')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('92%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.shown(), (item: Goods) => {
          Column({ space: 8 }) {
            Image(item.img)
              .width(110)
              .height(110)
              .objectFit(ImageFit.Contain)
            Text(item.name)
              .fontSize(14)
              .fontColor('#333333')
            Text(`¥${item.price}`)
              .fontSize(14)
              .fontColor('#E64545')
            Button('加入购物车')
              .fontSize(12)
              .height(28)
              .onClick(() => {
                addCart(item.name, item.price)
              })
          }
          .width('50%')
          .padding(12)
        }, (item: Goods) => item.name)
      }
      .width('92%')

      if (this.shown().length === 0) {
        Text('没有匹配的家电')
          .fontSize(14)
          .fontColor('#9B9B9B')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16, bottom: 16 })
  }
}
