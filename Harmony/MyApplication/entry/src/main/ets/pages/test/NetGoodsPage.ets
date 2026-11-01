import { ProductRow, ProductsPayload, firstImage, getJson } from '../../utils/requestUtils'
import Title from '../component/Title'

@Entry
@Component
struct NetGoodsPage {
  @State list: ProductRow[] = []
  @State loading: boolean = false
  @State tip: string = ''

  // 第 9 章：组件即将出现时发起网络请求
  aboutToAppear(): void {
    this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    this.tip = ''
    try {
      const text: string = await getJson('/api/products?page=1&limit=20')
      const payload: ProductsPayload = JSON.parse(text) as ProductsPayload
      this.list = payload.data
      if (this.list.length === 0) {
        this.tip = '服务端没有返回商品'
      }
    } catch (err) {
      this.list = []
      this.tip = '加载失败：请确认服务端已启动，并且手机与电脑在同一局域网'
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      Title({ title: '网络商品列表', arrow: true })

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
              this.load()
            })
        }
        .width('90%')
        .margin({ top: 30 })
      }

      List({ space: 8 }) {
        ForEach(this.list, (item: ProductRow) => {
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
                Text(`￥${item.price}　库存 ${item.stock}`)
                  .fontSize(13)
                  .fontColor('#E64545')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(10)
          }
        }, (item: ProductRow) => item.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
