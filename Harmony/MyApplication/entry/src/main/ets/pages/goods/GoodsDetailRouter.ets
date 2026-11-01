import { DetailArg } from '../../utils/requestUtils'
import Title from '../component/Title'

@Entry
@Component
struct GoodsDetailRouter {
  @State arg: DetailArg = { title: '', priceText: '', content: '', image: '', stockText: '' }

  // 第 10 章 Router 写法：页面显示时取列表传过来的商品参数
  onPageShow(): void {
    const params: Object | undefined = this.getUIContext().getRouter().getParams()
    if (params !== undefined) {
      this.arg = params as DetailArg
    }
  }

  build() {
    Column({ space: 12 }) {
      Title({ title: '商品详情', arrow: true })

      // 图片可能是服务端绝对地址，也可能是本地 rawfile 文件名
      if (this.arg.image.startsWith('http')) {
        Image(this.arg.image)
          .width(180)
          .height(180)
          .objectFit(ImageFit.Contain)
      } else if (this.arg.image === '') {
        Image($r('app.media.dianqi'))
          .width(180)
          .height(180)
          .objectFit(ImageFit.Contain)
      } else {
        Image($rawfile(this.arg.image))
          .width(180)
          .height(180)
          .objectFit(ImageFit.Contain)
      }

      Text(this.arg.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('90%')
      Text(this.arg.priceText)
        .fontSize(16)
        .fontColor('#E64545')
        .width('90%')
      Text(this.arg.stockText)
        .fontSize(14)
        .width('90%')
      Text(this.arg.content)
        .fontSize(14)
        .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}
