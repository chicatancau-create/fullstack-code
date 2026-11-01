import { DetailArg, firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData } from '../../utils/requestUtils'

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

  @Builder
  goodsRow(item: ProductDataModel) {
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
    .width('95%')
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
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
        Text(this.current)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.loading ? '加载中…' : `共 ${this.goodsList.length} 件`)
          .fontSize(13)
          .fontColor('#9B9B9B')
      }
      .width('92%')
      .margin({ top: 10, bottom: 6 })

      if (this.tip !== '') {
        Column({ space: 10 }) {
          Text(this.tip)
            .fontSize(13)
            .fontColor('#9B9B9B')
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .fontSize(13)
            .onClick(() => {
              const index: number = this.current === '全部' ? 0 : this.currentIndexOf()
              this.pick(index)
            })
        }
        .width('100%')
        .margin({ top: 30 })
      }

      List({ space: 15 }) {
        ForEach(this.goodsList, (item: ProductDataModel) => {
          ListItem() {
            this.goodsRow(item)
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
      .width('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
    }
    .width('100%')
    .height('100%')
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
