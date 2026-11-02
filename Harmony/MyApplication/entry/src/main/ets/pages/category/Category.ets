import { DetailArg, firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData } from '../../utils/requestUtils'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_CAPTION,
  FONT_PRICE,
  FONT_SUBTITLE,
  FONT_TITLE,
  IMAGE_RADIUS,
  PRIMARY,
  SPACE_MD,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED,
  TEXT_SECONDARY
} from '../../common/UiTokens'

interface CategoryTab {
  name: string
  categoryId: number
}

// 名称与服务端 product_categories 表的种子数据一致
const tabs: CategoryTab[] = [
  { name: '电子', categoryId: 1 },
  { name: '服装', categoryId: 2 },
  { name: '书籍', categoryId: 3 },
  { name: '家居', categoryId: 4 },
  { name: '美妆', categoryId: 5 },
  { name: '运动', categoryId: 6 },
  { name: '玩具', categoryId: 7 },
  { name: '食品', categoryId: 8 }
]

// 第 9 章规定：顶部一排可横向滑动的分类标签，第一个是「全部」，切标签就换分类重新取数
@ComponentV2
export default struct Category {
  @Local goodsList: ProductDataModel[] = []
  @Local current: string = '全部'
  @Local tip: string = ''
  @Local loading: boolean = false

  aboutToAppear(): void {
    this.load(0)
  }

  // categoryId 为 0 表示不分类，取全部
  private async load(categoryId: number): Promise<void> {
    this.loading = true
    this.tip = ''
    let url = '/api/products?page=1&limit=20'
    if (categoryId !== 0) {
      url = url + '&category_id=' + categoryId.toString()
    }
    try {
      const text: string = await getJson(url)
      const res: ResponseData<GoodsDataModel> = JSON.parse(text) as ResponseData<GoodsDataModel>
      if (res.code === 200 && res.data !== undefined && res.data.products !== undefined) {
        this.goodsList = res.data.products
        if (this.goodsList.length === 0) {
          this.tip = '该分类下服务端没有商品'
        }
      } else {
        this.goodsList = []
        this.tip = '服务端返回异常：' + res.message
      }
    } catch (err) {
      this.goodsList = []
      this.tip = '连不上服务端（默认 http://127.0.0.1:3000）。请先启动 shopmall-api-v2-server，'
        + '真机则把 requestUtils.ets 里的 BASE_URL 改成服务端所在机器的局域网地址。'
    } finally {
      this.loading = false
    }
  }

  // 下标 0 是「全部」，后面每个下标正好对应服务端 category_id
  private pick(index: number): void {
    if (index === 0) {
      this.current = '全部'
      this.load(0)
      return
    }
    const item: CategoryTab = tabs[index - 1]
    this.current = item.name
    this.load(item.categoryId)
  }

  // 详情页统一参数：图片可能是服务端绝对地址，也可能是本地 rawfile 名
  private toDetail(item: ProductDataModel): DetailArg {
    const arg: DetailArg = {
      title: item.name,
      priceText: `价格${item.price} 元`,
      content: item.description === null ? '' : item.description,
      image: firstImage(item.images),
      stockText: `库存：${item.stock}`
    }
    return arg
  }

  // 列表项：白色圆角卡片，图片圆角、名称两行截断、右侧价格与箭头
  @Builder
  goodsCard(item: ProductDataModel) {
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
        Text(item.description === null ? '' : item.description)
          .fontSize(FONT_CAPTION)
          .fontColor(TEXT_MUTED)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
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

  build() {
    Column({ space: SPACE_XS }) {
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
        }
        .tabBar('全部')

        ForEach(tabs, (item: CategoryTab) => {
          TabContent() {
          }
          .tabBar(item.name)
        }, (item: CategoryTab) => item.name)
      }
      .barMode(BarMode.Scrollable)
      .height(50)
      .onChange((index: number) => {
        this.pick(index)
      })

      Row() {
        Column({ space: 2 }) {
          Text(this.current)
            .fontSize(FONT_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_MAIN)
          Text(this.loading ? '加载中…' : `共 ${this.goodsList.length} 件`)
            .fontSize(FONT_BODY)
            .fontColor(TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('92%')
      .margin({ top: SPACE_XS })

      if (this.tip !== '') {
        Column({ space: 10 }) {
          Text(this.tip)
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .fontSize(FONT_BODY)
            .backgroundColor(PRIMARY)
            .onClick(() => {
              const index: number = this.current === '全部' ? 0 : this.currentIndexOf()
              this.pick(index)
            })
        }
        .width('100%')
        .margin({ top: 30 })
      }

      List({ space: 10 }) {
        ForEach(this.goodsList, (item: ProductDataModel) => {
          ListItem() {
            this.goodsCard(item)
          }
          .width('94%')
          .padding(SPACE_MD)
          .borderRadius(CARD_RADIUS)
          .backgroundColor(CARD_BG)
          // 第 10 章：点击列表项，把当前商品传给详情页
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/goods/GoodsDetailRouter',
              params: this.toDetail(item)
            })
          })
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

  private currentIndexOf(): number {
    for (let i = 0; i < tabs.length; i++) {
      if (tabs[i].name === this.current) {
        return i + 1
      }
    }
    return 0
  }
}
