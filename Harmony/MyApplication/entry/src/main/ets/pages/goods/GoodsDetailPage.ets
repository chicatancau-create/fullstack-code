// 10.4 步骤3：商品详情页用 NavDestination 作根容器，参数在 onReady 里取
import { firstImage, getJson, ProductDataModel, ResponseData } from '../../utils/requestUtils'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  CHIP_RADIUS,
  FONT_BODY,
  FONT_CAPTION,
  FONT_TITLE,
  PRIMARY,
  SPACE_MD,
  SPACE_SM,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

export interface GoodsDetailParam {
  goodsId: number
}

@Builder
export function GoodsDetailPageBuilder(name: string, param: object) {
  GoodsDetailPage({ param: param as GoodsDetailParam })
}

@Component
export struct GoodsDetailPage {
  @State goodsInfo: ProductDataModel | null = null
  @State tip: string = ''
  @State loading: boolean = false
  param?: GoodsDetailParam

  // 10.4 步骤5：拿 goodsId 去请求商品详情接口
  private async loadGoodsDetail(goodsId: number): Promise<void> {
    this.loading = true
    this.tip = ''
    try {
      const text: string = await getJson('/api/products/' + goodsId.toString())
      const res: ResponseData<ProductDataModel> = JSON.parse(text) as ResponseData<ProductDataModel>
      if (res.code === 200 && res.data !== undefined && res.data.name !== undefined) {
        this.goodsInfo = res.data
      } else {
        this.goodsInfo = null
        this.tip = '详情接口返回异常：' + res.message
      }
    } catch (err) {
      this.goodsInfo = null
      this.tip = '连不上服务端（默认 http://127.0.0.1:3000），请先启动 shopmall-api-v2-server'
    } finally {
      this.loading = false
    }
  }

  build() {
    NavDestination() {
      Column({ space: SPACE_MD }) {
        if (this.goodsInfo !== null) {
          // hero 大图：白色卡片衬底
          Column() {
            if (firstImage(this.goodsInfo.images) === '') {
              Image($r('app.media.dianqi'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)
            } else {
              Image(firstImage(this.goodsInfo.images))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)
            }
          }
          .width('100%')
          .padding(SPACE_MD)
          .borderRadius(CARD_RADIUS)
          .backgroundColor(CARD_BG)
          Text(this.goodsInfo.name)
            .fontSize(FONT_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_MAIN)
            .width('100%')

          // 价格条：左边价格，右边库存
          Row() {
            Text(`价格${this.goodsInfo.price} 元`)
              .fontSize(FONT_TITLE)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Blank()
            Text(`库存：${this.goodsInfo.stock}`)
              .fontSize(FONT_CAPTION)
              .fontColor('rgba(255,255,255,0.85)')
          }
          .width('100%')
          .padding(SPACE_MD)
          .borderRadius(CHIP_RADIUS)
          .backgroundColor(PRIMARY)

          if (this.goodsInfo.description !== null && this.goodsInfo.description !== '') {
            Column({ space: SPACE_XS }) {
              Text('商品说明')
                .fontSize(FONT_CAPTION)
                .fontColor(TEXT_MUTED)
                .width('100%')
              Text(this.goodsInfo.description)
                .fontSize(FONT_BODY)
                .fontColor(TEXT_MAIN)
                .width('100%')
            }
            .width('100%')
            .padding(SPACE_MD)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
          }
        } else if (this.loading) {
          Text('加载中…')
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
            .margin({ top: 40 })
        } else {
          Column({ space: SPACE_SM }) {
            Text(this.tip)
              .fontSize(FONT_BODY)
              .fontColor(TEXT_MUTED)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .margin({ top: 40 })
        }
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(BG_PAGE)
    .title('商品详情')
    .onReady((context: NavDestinationContext) => {
      // 本 SDK 的 NavDestinationContext 把参数放在 pathInfo.param 里
      const arg: GoodsDetailParam = context.pathInfo.param as GoodsDetailParam
      if (arg !== undefined && arg.goodsId !== undefined) {
        this.loadGoodsDetail(arg.goodsId)
      } else {
        this.tip = '没有收到商品 id'
      }
    })
  }
}
