import { GoodsDetailParam } from './GoodsDetailPage'
import { firstImage, getJson, GoodsDataModel, ProductDataModel, ResponseData, BASE_URL } from '../../utils/requestUtils'

// 10.4：商品列表页根容器改为 Navigation，详情页交给系统路由表 router_map.json
@Entry
@Component
struct NavPage {
  @State pathStack: NavPathStack = new NavPathStack()
  @State goodsList: ProductDataModel[] = []
  @State tip: string = ''

  // 列表与详情都取服务端数据，避免本地素材 id 和服务端对不上（点 A 显示 B）
  private async load(): Promise<void> {
    this.tip = '加载中…'
    try {
      const text: string = await getJson('/api/products?page=1&limit=20')
      const res: ResponseData<GoodsDataModel> = JSON.parse(text) as ResponseData<GoodsDataModel>
      if (res.code === 200 && res.data !== undefined && res.data.products !== undefined) {
        this.goodsList = res.data.products
        this.tip = ''
      } else {
        this.tip = '服务端返回异常：' + res.message
      }
    } catch (err) {
      this.tip = '连不上服务端（默认 http://127.0.0.1:3000），请先启动 shopmall-api-v2-server'
    }
  }

  aboutToAppear(): void {
    this.load()
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 10 }) {
        Text(this.tip === '' ? '点击商品查看详情' : this.tip)
          .fontSize(15)
          .fontColor(this.tip === '' ? '#333333' : '#9B9B9B')
        List({ space: 10 }) {
          ForEach(this.goodsList, (item: ProductDataModel) => {
            ListItem() {
              Row() {
                if (firstImage(item.images) === '') {
                  Image($r('app.media.dianqi'))
                    .width(50)
                    .height(50)
                } else {
                  Image(BASE_URL + String(item.images).split(',')[0])
                    .width(50)
                    .height(50)
                    .objectFit(ImageFit.Cover)
                }
                Text(item.name)
                  .fontSize(15)
                  .layoutWeight(1)
                Text(`￥${item.price}`)
                  .fontSize(15)
                  .fontColor('#E64545')
              }
              .width('100%')
              .padding(10)
              .onClick(() => {
                // 10.4 步骤4：按名字跳转，只传商品 id，由详情页自己请求详情
                const arg: GoodsDetailParam = { goodsId: item.id }
                this.pathStack.pushPathByName('GoodsDetail', arg)
              })
            }
          }, (item: ProductDataModel) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(12)
    }
    .mode(NavigationMode.Stack)
    .title('商品列表')
    .hideNavBar(true)
  }
}
