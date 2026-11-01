import { DetailArg, ProductRow, ProductsPayload, firstImage, getJson } from '../../utils/requestUtils'

// 左侧分类菜单，index 对应服务端 category_id
interface Menu {
  name: string
  categoryId: number
}

const menus: Menu[] = [
  { name: '手机数码', categoryId: 1 },
  { name: '家用电器', categoryId: 2 },
  { name: '服饰鞋包', categoryId: 3 },
  { name: '食品生鲜', categoryId: 4 }
]

// 服务端不通时的本地兜底，保证演示不空白
const localNames: string[][] = [
  ['iPhone 15 Pro', '小米 14', '华为 Mate 60'],
  ['冰箱', '电饭煲', '微波炉'],
  ['运动鞋', '双肩包', 'T恤'],
  ['牛奶', '坚果', '咖啡']
]

@Component
export default struct Category {
  @State selected: number = 0
  @State goodsList: ProductRow[] = []
  @State fromServer: boolean = false

  aboutToAppear(): void {
    this.load(1)
  }

  private async load(categoryId: number): Promise<void> {
    try {
      const text: string = await getJson('/api/products?page=1&limit=20&category_id=' + categoryId.toString())
      const payload: ProductsPayload = JSON.parse(text) as ProductsPayload
      if (payload.code === 200 && payload.data !== undefined && payload.data.products !== undefined) {
        this.goodsList = payload.data.products
        this.fromServer = true
      } else {
        this.goodsList = []
        this.fromServer = false
      }
    } catch (err) {
      this.goodsList = []
      this.fromServer = false
    }
  }

  // 详情页统一参数：图片可能是服务端绝对地址，也可能是本地 rawfile 名
  private toDetail(item: ProductRow): DetailArg {
    const pic: string = firstImage(item.images)
    const arg: DetailArg = {
      title: item.name,
      priceText: `￥${item.price}`,
      content: item.description === null ? '' : item.description,
      image: pic,
      stockText: `库存：${item.stock}`
    }
    return arg
  }

  private localDetail(index: number): DetailArg {
    const arg: DetailArg = {
      title: localNames[this.selected][index],
      priceText: '￥0.00',
      content: '服务端未启动，这里显示的是本地占位数据。',
      image: '',
      stockText: '库存：—'
    }
    return arg
  }

  build() {
    Row() {
      List({ space: 8 }) {
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
      .width(100)
      .height('100%')
      .scrollBar(BarState.Off)

      Column({ space: 10 }) {
        Text(menus[this.selected].name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Text(this.fromServer ? '数据来源：服务端 /api/products' : '数据来源：本地占位（服务端未启动）')
          .fontSize(12)
          .fontColor('#9B9B9B')

        List({ space: 10 }) {
          if (this.fromServer) {
            ForEach(this.goodsList, (item: ProductRow, index: number) => {
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
              // 第 10 章：列表点击进详情并传参
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/goods/GoodsDetailRouter',
                  params: this.toDetail(item)
                })
              })
            }, (item: ProductRow) => item.id.toString())
          } else {
            ForEach(localNames[this.selected], (item: string, index: number) => {
              ListItem() {
                Row() {
                  Text(item).fontSize(15)
                  Image($r('app.media.jiantouyou'))
                    .width(16)
                    .fillColor('#9B9B9B')
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding(10)
              }
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/goods/GoodsDetailRouter',
                  params: this.localDetail(index)
                })
              })
            }, (item: string) => item)
          }
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
