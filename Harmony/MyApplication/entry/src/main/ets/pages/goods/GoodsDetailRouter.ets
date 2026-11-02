import { DetailArg } from '../../utils/requestUtils'
import Title from '../component/Title'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  CARD_SHADOW_COLOR,
  CARD_SHADOW_OFFSET_Y,
  CARD_SHADOW_RADIUS,
  CHIP_RADIUS,
  FONT_BODY,
  FONT_CAPTION,
  FONT_TITLE,
  PRIMARY_END,
  PRIMARY_START,
  SPACE_MD,
  SPACE_SM,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

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
    Column({ space: SPACE_SM }) {
      Title({ title: '商品详情', isShow: true })

      Scroll() {
        Column({ space: SPACE_MD }) {
          // hero 大图：白色卡片衬底。图片可能是服务端绝对地址，也可能是本地 rawfile 文件名
          Column() {
            if (this.arg.image.startsWith('http')) {
              Image(this.arg.image)
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Contain)
            } else if (this.arg.image === '') {
              Image($r('app.media.dianqi'))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Contain)
            } else {
              Image($rawfile(this.arg.image))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Contain)
            }
          }
          .width('92%')
          .padding(SPACE_MD)
          .borderRadius(CARD_RADIUS)
          .backgroundColor(CARD_BG)
          .shadow({
            radius: CARD_SHADOW_RADIUS,
            color: CARD_SHADOW_COLOR,
            offsetX: 0,
            offsetY: CARD_SHADOW_OFFSET_Y
          })

          Text(this.arg.title)
            .fontSize(FONT_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_MAIN)
            .width('92%')

          // 渐变价格条：左边价格，右边库存
          Row() {
            Text(this.arg.priceText)
              .fontSize(FONT_TITLE)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Blank()
            Text(this.arg.stockText)
              .fontSize(FONT_CAPTION)
              .fontColor('rgba(255,255,255,0.85)')
          }
          .width('92%')
          .padding(SPACE_MD)
          .borderRadius(CHIP_RADIUS)
          .linearGradient({
            angle: 135,
            colors: [[PRIMARY_START, 0], [PRIMARY_END, 1]]
          })

          if (this.arg.content !== '') {
            Column({ space: SPACE_XS }) {
              Text('商品说明')
                .fontSize(FONT_CAPTION)
                .fontColor(TEXT_MUTED)
                .width('100%')
              Text(this.arg.content)
                .fontSize(FONT_BODY)
                .fontColor(TEXT_MAIN)
                .lineHeight(22)
                .width('100%')
            }
            .width('92%')
            .padding(SPACE_MD)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
            .shadow({
              radius: CARD_SHADOW_RADIUS,
              color: CARD_SHADOW_COLOR,
              offsetX: 0,
              offsetY: CARD_SHADOW_OFFSET_Y
            })
          }
        }
        .width('100%')
        .padding({ top: SPACE_XS, bottom: SPACE_MD })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
