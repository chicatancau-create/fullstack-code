import { allGoods, Goods } from '../../model/Data'
import { addCart } from '../../model/CartStore'
import { AdvertisementData, AdvertisementDataList } from '../../model/SwiperModel'
import { connectUser, User } from '../../model/User'
import { GoodsTypeData, GoodsTypeList } from '../../model/GoodsTypeModel'
import { CategoryArg, BASE_URL } from '../../utils/requestUtils'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  CHIP_RADIUS,
  DANGER,
  FONT_BODY,
  FONT_CAPTION,
  FONT_SUBTITLE,
  FONT_TITLE,
  GLASS_BG,
  IMAGE_BG,
  IMAGE_RADIUS,
  PRIMARY,
  PRIMARY_TINT,
  SPACE_MD,
  SPACE_SM,
  SPACE_XS,
  TEXT_MAIN,
  TEXT_MUTED,
  TEXT_ON_PRIMARY
} from '../../common/UiTokens'

@ComponentV2
export default struct Home {
  @Local kw: string = ''
  @Local swiperData: AdvertisementData[] = AdvertisementDataList
  @Local types: GoodsTypeData[] = GoodsTypeList
  // 11.4 步骤4：首页作为数据提供方，用 @Provider 把全局登录态暴露给子孙组件
  @Provider('user') user: User = connectUser()
  private goods: Goods[] = allGoods()

  // 11.4 步骤4：顶部用户信息区。白色半透明卡片衬在主色底上，未登录时给「去登录」入口
  @Builder
  UserHeader() {
    if (this.user.isLoggedIn) {
      Row({ space: SPACE_SM }) {
        Image(this.user.avatar === '' ? $r('app.media.denglu') : BASE_URL + this.user.avatar)
          .width(44)
          .height(44)
          .borderRadius(22)
          .border({ width: 2, color: 'rgba(255,255,255,0.6)' })
        Column({ space: 2 }) {
          Text(`欢迎，${this.user.name}`)
            .fontSize(FONT_SUBTITLE)
            .fontColor(TEXT_ON_PRIMARY)
          Text(this.user.email)
            .fontSize(FONT_CAPTION)
            .fontColor('rgba(255,255,255,0.75)')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(SPACE_MD)
      .borderRadius(CHIP_RADIUS)
      .backgroundColor(GLASS_BG)
      .justifyContent(FlexAlign.Start)
    } else {
      Row({ space: SPACE_SM }) {
        Image($r('app.media.denglu'))
          .width(36)
          .height(36)
        Column({ space: 2 }) {
          Text('未登录')
            .fontSize(FONT_SUBTITLE)
            .fontColor(TEXT_ON_PRIMARY)
          Text('登录后可以看购物车和个人中心')
            .fontSize(FONT_CAPTION)
            .fontColor('rgba(255,255,255,0.75)')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('去登录')
          .fontSize(FONT_BODY)
          .height(32)
          .backgroundColor(CARD_BG)
          .fontColor(PRIMARY)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Login' })
          })
      }
      .width('100%')
      .padding(SPACE_MD)
      .borderRadius(CHIP_RADIUS)
      .backgroundColor(GLASS_BG)
    }
  }

  // 搜索框也放进顶部主色区，白字浅底
  @Builder
  SearchBar() {
    Row({ space: SPACE_XS }) {
      Image($r('app.media.sousuo'))
        .width(20)
        .height(20)
        .fillColor('rgba(255,255,255,0.85)')
      TextInput({ placeholder: '搜索家电', text: this.kw })
        .layoutWeight(1)
        .height(36)
        .fontSize(FONT_BODY)
        .fontColor(TEXT_ON_PRIMARY)
        .backgroundColor(PRIMARY)
        .onChange((value: string) => {
          this.kw = value
        })
    }
    .width('100%')
    .height(44)
    .padding({ left: SPACE_MD, right: SPACE_MD })
    .borderRadius(22)
    .backgroundColor(GLASS_BG)
  }

  private shown(): Goods[] {
    if (this.kw === '') {
      return this.goods
    }
    return this.goods.filter((item: Goods): boolean => item.name.includes(this.kw))
  }

  // 6.5 步骤4：把宫格单元提炼成 @Builder。图标衬浅蓝圆底，按下时缩放
  @Builder
  typeCell(item: GoodsTypeData) {
    Column({ space: SPACE_XS }) {
      Column() {
        Image(item.icon)
          .width(30)
          .height(30)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor(PRIMARY_TINT)
      .justifyContent(FlexAlign.Center)

      Text(item.typeName)
        .fontSize(FONT_CAPTION)
        .fontColor(TEXT_MAIN)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
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
      Column({ space: SPACE_MD }) {
        // 顶部主色区：包住用户区与搜索框
        Column({ space: SPACE_SM }) {
          // 11.4 步骤4：顶部用户信息区
          this.UserHeader()
          this.SearchBar()
        }
        .width('100%')
        .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_MD, bottom: SPACE_MD })
        .borderRadius(CHIP_RADIUS)
        .backgroundColor(PRIMARY)

        // 第 6 章轮播图：六张图，自动播放 2000 毫秒
        Swiper() {
          ForEach(this.swiperData, (item: AdvertisementData) => {
            Image(item.icon)
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(CARD_RADIUS)
          }, (item: AdvertisementData) => item.id.toString())
        }
        .autoPlay(true)
        .interval(2000)
        .loop(true)
        .indicator(true)
        .width('92%')
        .height(200)

        // 第 6 章宫格：四列两行八项，整块做成白色卡片
        Column({ space: SPACE_XS }) {
          Text('商品分类')
            .fontSize(FONT_TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_MAIN)
            .width('100%')
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
          .width('100%')
          .height(200)
        }
        .width('92%')
        .padding(SPACE_MD)
        .borderRadius(CARD_RADIUS)
        .backgroundColor(CARD_BG)
        Text('热门推荐')
          .fontSize(FONT_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_MAIN)
          .width('92%')

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.shown(), (item: Goods) => {
            Column({ space: 6 }) {
              Image(item.img)
                .width('100%')
                .height(110)
                .objectFit(ImageFit.Contain)
                .borderRadius(IMAGE_RADIUS)
                .backgroundColor(IMAGE_BG)
              Text(item.name)
                .fontSize(FONT_BODY)
                .fontColor(TEXT_MAIN)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .height(40)
              Text(`¥${item.price}`)
                .fontSize(FONT_SUBTITLE)
                .fontColor(DANGER)
                .fontWeight(FontWeight.Medium)
              Button('加入购物车')
                .fontSize(FONT_CAPTION)
                .height(30)
                .backgroundColor(PRIMARY)
                .width('100%')
                .onClick(() => {
                  addCart(item.name, item.price)
                })
            }
            .width('48%')
            .padding(SPACE_MD)
            .margin({ bottom: SPACE_MD })
            .alignItems(HorizontalAlign.Start)
            .borderRadius(CARD_RADIUS)
            .backgroundColor(CARD_BG)
          }, (item: Goods) => item.name)
        }
        .width('92%')

        if (this.shown().length === 0) {
          Text('没有匹配的家电')
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 30, bottom: 30 })
        }
      }
      .width('100%')
      .padding({ top: SPACE_MD, bottom: SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
