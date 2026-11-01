import { CategoryArg, firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData } from '../../utils/requestUtils'
import Title from '../component/Title'

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
    Column() {
      Title({ title: `网络商品列表 分类${this.categoryId}`, isShow: true })

      if (this.loading) {
        Text('加载中…')
          .fontSize(15)
          .fontColor('#9B9B9B')
          .margin({ top: 30 })
      }

      if (this.tip !== '') {
        Column({ space: 12 }) {
          Text(this.tip)
            .fontSize(14)
            .fontColor('#9B9B9B')
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => {
              this.load(this.categoryId)
            })
        }
        .width('90%')
        .margin({ top: 30 })
      }

      List({ space: 8 }) {
        ForEach(this.list, (item: ProductDataModel) => {
          ListItem() {
            Row({ space: 10 }) {
              if (firstImage(item.images) === '') {
                Image($r('app.media.dianqi'))
                  .width(56)
                  .height(56)
              } else {
                Image(firstImage(item.images))
                  .width(56)
                  .height(56)
                  .objectFit(ImageFit.Cover)
              }
              Column({ space: 4 }) {
                Text(item.name)
                  .fontSize(16)
                Text(`价格${item.price} 元　库存 ${item.stock}`)
                  .fontSize(13)
                  .fontColor('#E64545')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(10)
          }
        }, (item: ProductDataModel) => item.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
