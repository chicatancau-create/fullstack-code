// 10.4 步骤3：商品详情页用 NavDestination 作根容器，参数在 onReady 里取
import { firstImage, getJson, ProductDataModel, ResponseData } from '../../utils/requestUtils'

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
  param?: GoodsDetailParam

  // 10.4 步骤5：拿 goodsId 去请求商品详情接口
  private async loadGoodsDetail(goodsId: number): Promise<void> {
    this.tip = '加载中…'
    try {
      const text: string = await getJson('/api/products/' + goodsId.toString())
      const res: ResponseData<ProductDataModel> = JSON.parse(text) as ResponseData<ProductDataModel>
      if (res.code === 200 && res.data !== undefined && res.data.name !== undefined) {
        this.goodsInfo = res.data
        this.tip = ''
      } else {
        this.goodsInfo = null
        this.tip = '详情接口返回异常：' + res.message
      }
    } catch (err) {
      this.goodsInfo = null
      this.tip = '连不上服务端（默认 http://127.0.0.1:3000），请先启动 shopmall-api-v2-server'
    }
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        if (this.goodsInfo !== null) {
          if (firstImage(this.goodsInfo.images) === '') {
            Image($r('app.media.dianqi'))
              .width(140)
              .height(140)
          } else {
            Image(firstImage(this.goodsInfo.images))
              .width(140)
              .height(140)
              .objectFit(ImageFit.Contain)
          }
          Text(this.goodsInfo.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text(`价格${this.goodsInfo.price} 元`)
            .fontSize(16)
            .fontColor('#E64545')
          Text(`库存：${this.goodsInfo.stock}`)
            .fontSize(14)
          Text(this.goodsInfo.description === null ? '' : this.goodsInfo.description)
            .fontSize(14)
            .fontColor('#6B6B6B')
        } else {
          Text(this.tip)
            .fontSize(14)
            .fontColor('#9B9B9B')
            .margin({ top: 40 })
        }
      }
      .width('100%')
      .padding(16)
    }
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
