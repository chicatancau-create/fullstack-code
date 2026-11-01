import { allGoods, addCart, Goods } from '../../model/Data'
import { AdvertisementData, AdvertisementDataList } from '../../model/SwiperModel'
import { CategoryArg } from '../../utils/requestUtils'

// 第 6 章宫格：分类名与服务端 product_categories 种子数据对齐
interface GridItemInfo {
  icon: string
  name: string
  categoryId: number
}

const gridItems: GridItemInfo[] = [
  { icon: 'dianzichanpin.png', name: '电子', categoryId: 1 },
  { icon: 'fuzhuangfushi.png', name: '服装', categoryId: 2 },
  { icon: 'tushu.png', name: '书籍', categoryId: 3 },
  { icon: 'jiadian.png', name: '家居', categoryId: 4 },
  { icon: 'gerenhuli.png', name: '美妆', categoryId: 5 },
  { icon: 'yundongjianshen.png', name: '运动', categoryId: 6 },
  { icon: 'wanju.png', name: '玩具', categoryId: 7 },
  { icon: 'shipinyinliao.png', name: '食品', categoryId: 8 },
]

@Component
export default struct Home {
  @State kw: string = ''
  @State swiperData: AdvertisementData[] = AdvertisementDataList
  private goods: Goods[] = allGoods()

  private shown(): Goods[] {
    if (this.kw === '') {
      return this.goods
    }
    return this.goods.filter((item: Goods): boolean => item.name.includes(this.kw))
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 第 6 章轮播图：六张图，自动播放 2000 毫秒，也可手动滑动
        Swiper() {
          ForEach(this.swiperData, (item: AdvertisementData) => {
            Image(item.icon)
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
          }, (item: AdvertisementData) => item.id.toString())
        }
        .autoPlay(true)
        .interval(2000)
        .loop(true)
        .indicator(true)
        .width('100%')
        .height(200)

        // 第 6 章宫格：四列两行八项
        Grid() {
          ForEach(gridItems, (item: GridItemInfo) => {
            GridItem() {
              Column({ space: 5 }) {
                Image($rawfile(item.icon))
                  .width(50)
                  .height(50)
                Text(item.name)
                  .fontSize(12)
              }
              // 5.4 规定宫格要能跳到对应商品列表
              .onClick(() => {
                const arg: CategoryArg = { categoryId: item.categoryId }
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/test/NetGoodsPage',
                  params: arg
                })
              })
            }
          }, (item: GridItemInfo) => item.name)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .rowsGap(10)
        .columnsGap(10)
        .width('92%')
        .height(200)

        Row({ space: 8 }) {
          Image($r('app.media.sousuo'))
            .width(20)
            .fillColor('#6B6B6B')
          TextInput({ placeholder: '搜索家电' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.kw = value
            })
        }
        .width('92%')

        Text('热门推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('92%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.shown(), (item: Goods) => {
            Column({ space: 8 }) {
              Image(item.img)
                .width(110)
                .height(110)
                .objectFit(ImageFit.Contain)
              Text(item.name)
                .fontSize(14)
                .fontColor('#333333')
              Text(`¥${item.price}`)
                .fontSize(14)
                .fontColor('#E64545')
              Button('加入购物车')
                .fontSize(12)
                .height(28)
                .onClick(() => {
                  addCart(item.name, item.price)
                })
            }
            .width('50%')
            .padding(12)
          }, (item: Goods) => item.name)
        }
        .width('92%')

        if (this.shown().length === 0) {
          Text('没有匹配的家电')
            .fontSize(14)
            .fontColor('#9B9B9B')
        }
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
