import { DetailArg, firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData } from '../../utils/requestUtils'

interface Menu {
  name: string
  categoryId: number
}

// 名称与服务端 product_categories 表的种子数据一致
const menus: Menu[] = [
  { name: '电子', categoryId: 1 },
  { name: '服装', categoryId: 2 },
  { name: '书籍', categoryId: 3 },
  { name: '家居', categoryId: 4 },
  { name: '美妆', categoryId: 5 },
  { name: '运动', categoryId: 6 },
  { name: '玩具', categoryId: 7 },
  { name: '食品', categoryId: 8 }
]

@Component
export default struct Category {
  @State selected: number = 0
  @State goodsList: ProductDataModel[] = []
  @State tip: string = ''
  @State loading: boolean = false

  aboutToAppear(): void {
    this.load(menus[0].categoryId)
  }

  // 第 9 章：按分类取服务端商品
  private async load(categoryId: number): Promise<void> {
    this.loading = true
    this.tip = ''
    try {
      const text: string = await getJson('/api/products?page=1&limit=20&category_id=' + categoryId.toString())
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

  build() {
    Row() {
      List({ space: 6 }) {
        ForEach(menus, (item: Menu, index: number) => {
          ListItem() {
            Text(item.name)
              .fontSize(15)
              .fontColor(this.selected === index ? '#1698CE' : '#333333')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(12)
          }
          .backgroundColor(this.selected === index ? '#EAF5FB' : '#F5F5F5')
          .onClick(() => {
            this.selected = index
            this.load(item.categoryId)
          })
        }, (item: Menu) => item.name)
      }
      .width(90)
      .height('100%')
      .scrollBar(BarState.Off)

      Column({ space: 10 }) {
        Text(menus[this.selected].name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        if (this.loading) {
          Text('加载中…')
            .fontSize(14)
            .fontColor('#9B9B9B')
            .margin({ top: 30 })
        }

        if (this.tip !== '') {
          Column({ space: 10 }) {
            Text(this.tip)
              .fontSize(13)
              .fontColor('#9B9B9B')
              .textAlign(TextAlign.Center)
            Button('重新加载')
              .fontSize(13)
              .onClick(() => {
                this.load(menus[this.selected].categoryId)
              })
          }
          .width('100%')
          .margin({ top: 30 })
        }

        List({ space: 10 }) {
          ForEach(this.goodsList, (item: ProductDataModel) => {
            ListItem() {
              Row() {
                if (firstImage(item.images) === '') {
                  Image($r('app.media.dianqi'))
                    .width(50)
                    .height(50)
                } else {
                  Image(firstImage(item.images))
                    .width(50)
                    .height(50)
                    .objectFit(ImageFit.Cover)
                }
                Text(item.name)
                  .fontSize(15)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Clip })
                  .layoutWeight(1)
                Text(`￥${item.price}`)
                  .fontSize(14)
                  .fontColor('#E64545')
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            // 第 10 章：点击列表项，把当前商品传给详情页
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/goods/GoodsDetailRouter',
                params: this.toDetail(item)
              })
            })
          }, (item: ProductDataModel) => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
      }
      .layoutWeight(1)
      .height('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
