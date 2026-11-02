import { CategoryArg, firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData } from '../../utils/requestUtils'
import Title from '../component/Title'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  CARD_SHADOW_COLOR,
  CARD_SHADOW_OFFSET_Y,
  CARD_SHADOW_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_CAPTION,
  FONT_PRICE,
  FONT_SUBTITLE,
  IMAGE_RADIUS,
  MOTION_FAST,
  PRIMARY,
  SPACE_MD,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

@Entry
@Component
struct NetGoodsPage {
  @State list: ProductDataModel[] = []
  @State loading: boolean = false
  @State tip: string = ''
  @State categoryId: number = 1
  private loadedFor: number = 0

  // 第 9 章：组件即将出现时发起网络请求
  aboutToAppear(): void {
    this.load(this.categoryId)
  }

  // 首页宫格跳进来时带分类参数，按 9.1 文档在页面显示时取参
  onPageShow(): void {
    const params: Object | undefined = this.getUIContext().getRouter().getParams()
    if (params !== undefined) {
      const arg: CategoryArg = params as CategoryArg
      if (arg.categoryId !== undefined && arg.categoryId !== this.loadedFor) {
        this.categoryId = arg.categoryId
        this.load(arg.categoryId)
      }
    }
  }

  private async load(categoryId: number): Promise<void> {
    this.loading = true
    this.tip = ''
    this.loadedFor = categoryId
    try {
      const text: string = await getJson('/api/products?page=1&limit=20&category_id=' + categoryId.toString())
      const res: ResponseData<GoodsDataModel> = JSON.parse(text) as ResponseData<GoodsDataModel>
      if (res.code === 200 && res.data !== undefined && res.data.products !== undefined) {
        this.list = res.data.products
        if (this.list.length === 0) {
          this.tip = '服务端没有返回商品'
        }
      } else {
        this.list = []
        this.tip = '服务端返回异常：' + res.message
      }
    } catch (err) {
      this.list = []
      this.tip = '连不上服务端：请确认 shopmall-api-v2-server 已启动（默认 http://127.0.0.1:3000）'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column({ space: SPACE_XS }) {
      Title({ title: `网络商品列表 分类${this.categoryId}`, isShow: true })

      if (this.loading) {
        Row({ space: SPACE_XS }) {
          LoadingProgress()
            .width(22)
            .height(22)
            .color(PRIMARY)
          Text('加载中…')
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
        }
        .width('92%')
        .margin({ top: SPACE_XS })
      }

      if (this.tip !== '') {
        Column({ space: 12 }) {
          Text(this.tip)
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .fontSize(FONT_BODY)
            .backgroundColor(PRIMARY)
            .onClick(() => {
              this.load(this.categoryId)
            })
        }
        .width('92%')
        .margin({ top: 30 })
      }

      List({ space: 10 }) {
        ForEach(this.list, (item: ProductDataModel) => {
          ListItem() {
            Row({ space: SPACE_MD }) {
              if (firstImage(item.images) === '') {
                Image($r('app.media.dianqi'))
                  .width(64)
                  .height(64)
                  .borderRadius(IMAGE_RADIUS)
                  .backgroundColor('#F7F8FA')
              } else {
                Image(firstImage(item.images))
                  .width(64)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(IMAGE_RADIUS)
              }
              Column({ space: 4 }) {
                Text(item.name)
                  .fontSize(FONT_SUBTITLE)
                  .fontColor(TEXT_MAIN)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`库存 ${item.stock}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MUTED)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text(`￥${item.price}`)
                .fontSize(FONT_PRICE)
                .fontColor(DANGER)
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.jiantouyou'))
                .width(14)
                .height(14)
                .fillColor(TEXT_MUTED)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('94%')
          .padding(SPACE_MD)
          .borderRadius(CARD_RADIUS)
          .backgroundColor(CARD_BG)
          .shadow({
            radius: CARD_SHADOW_RADIUS,
            color: CARD_SHADOW_COLOR,
            offsetX: 0,
            offsetY: CARD_SHADOW_OFFSET_Y
          })
          .stateStyles({
            pressed: {
              .scale({ x: 0.98, y: 0.98 })
            },
            normal: {
              .scale({ x: 1, y: 1 })
            }
          })
          .animation({ duration: MOTION_FAST, curve: Curve.EaseOut })
        }, (item: ProductDataModel) => item.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
