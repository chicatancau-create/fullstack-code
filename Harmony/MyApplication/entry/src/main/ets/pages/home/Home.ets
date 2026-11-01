import { allGoods, Goods } from '../../model/Data'
import { addCart } from '../../model/CartStore'
import { AdvertisementData, AdvertisementDataList } from '../../model/SwiperModel'
import { connectUser, User } from '../../model/User'
import { GoodsTypeData, GoodsTypeList } from '../../model/GoodsTypeModel'
import { CategoryArg, BASE_URL } from '../../utils/requestUtils'

@ComponentV2
export default struct Home {
  @Local kw: string = ''
  @Local swiperData: AdvertisementData[] = AdvertisementDataList
  @Local types: GoodsTypeData[] = GoodsTypeList
  // 11.4 步骤4：首页作为数据提供方，用 @Provider 把全局登录态暴露给子孙组件
  @Provider('user') user: User = connectUser()
  private goods: Goods[] = allGoods()

  // 11.4 步骤4：首页顶部用户信息区（未登录时给「去登录」入口）
  @Builder
  UserHeader() {
    if (this.user.isLoggedIn) {
      Row({ space: 10 }) {
        Image(this.user.avatar === '' ? $r('app.media.denglu') : BASE_URL + this.user.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
        Column() {
          Text(`欢迎，${this.user.name}`)
            .fontSize(15)
          Text(this.user.email)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('92%')
      .justifyContent(FlexAlign.Start)
    } else {
      Row() {
        Text('未登录')
          .fontSize(14)
          .fontColor('#9B9B9B')
        Blank()
        Button('去登录')
          .fontSize(13)
          .height(30)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Login' })
          })
      }
      .width('92%')
    }
  }

  private shown(): Goods[] {
    if (this.kw === '') {
      return this.goods
    }
    return this.goods.filter((item: Goods): boolean => item.name.includes(this.kw))
  }

  // 6.5 步骤4：把宫格单元提炼成 @Builder
  @Builder
  typeCell(item: GoodsTypeData) {
    Column({ space: 5 }) {
      Image(item.icon)
        .width(50)
        .height(50)
      Text(item.typeName)
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

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 11.4 步骤4：顶部用户信息区
        this.UserHeader()

        // 第 6 章轮播图：六张图，自动播放 2000 毫秒
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
          ForEach(this.types, (item: GoodsTypeData) => {
            GridItem() {
              this.typeCell(item)
            }
          }, (item: GoodsTypeData) => item.id.toString())
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
