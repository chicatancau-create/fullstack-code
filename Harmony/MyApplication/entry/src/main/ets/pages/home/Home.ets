import { allGoods, addCart, Goods } from '../../model/Data'

// 第 6 章宫格：图标与名称一一对应
interface GridItemInfo {
  icon: string
  name: string
}

const gridItems: GridItemInfo[] = [
  { icon: 'dianzichanpin.png', name: '电子产品' },
  { icon: 'fuzhuangfushi.png', name: '服装服饰' },
  { icon: 'gerenhuli.png', name: '个人护理' },
  { icon: 'jiadian.png', name: '家电' },
  { icon: 'shipinyinliao.png', name: '食品饮料' },
  { icon: 'tushu.png', name: '图书' },
  { icon: 'wanju.png', name: '玩具' },
  { icon: 'yundongjianshen.png', name: '运动健身' },
]

const bannerList: string[] = ['01.jpeg', '02.jpeg', '03.jpeg', '04.jpeg', '05.jpeg', '06.jpeg']

@Component
export default struct Home {
  @State kw: string = ''
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
        // 第 6 章轮播图：六张图，3000 毫秒自动切换，也可手动滑动
        Swiper() {
          ForEach(bannerList, (item: string) => {
            Image($rawfile(item))
              .width('100%')
              .height(150)
              .objectFit(ImageFit.Cover)
          }, (item: string) => item)
        }
        .autoPlay(true)
        .interval(3000)
        .loop(true)
        .indicator(true)
        .width('92%')
        .height(150)

        // 第 6 章宫格：四列八项
        Grid() {
          ForEach(gridItems, (item: GridItemInfo) => {
            GridItem() {
              Column({ space: 6 }) {
                Image($rawfile(item.icon))
                  .width(40)
                  .height(40)
                Text(item.name)
                  .fontSize(12)
              }
            }
          }, (item: GridItemInfo) => item.name)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(10)
        .columnsGap(10)
        .width('92%')
        .height(170)

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
