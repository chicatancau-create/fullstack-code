import Home from "./home/Home"
import Category from "./category/Category"
import Cart from "./cart/Cart"
import Me from "./me/Index"
import { TabIndexArg } from '../utils/requestUtils'
import { FONT_CAPTION, FONT_BODY, PRIMARY, TAB_ACTIVE_BG, TEXT_SECONDARY } from '../common/UiTokens'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  // 第 8 章：登录成功会带着 {id: 3} 跳回这一页，参数在 onPageShow 里读，用来定位到指定 tab
  onPageShow(): void {
    const params: Object | undefined = this.getUIContext().getRouter().getParams()
    if (params !== undefined) {
      const arg: TabIndexArg = params as TabIndexArg
      if (arg.id !== undefined && arg.id !== 0) {
        this.currentIndex = arg.id
      }
    }
  }

  // tab 选中态：图标放大 + 文字加粗 + 底下衬一块主色胶囊
  @Builder tabBuilder(title: string, targetIndex: number, image: Resource) {
    Column() {
      Column({ space: 2 }) {
        Image(image)
          .size({ width: 24, height: 24 })
          .fillColor(this.currentIndex === targetIndex ? PRIMARY : TEXT_SECONDARY)
          Text(title)
          .fontSize(this.currentIndex === targetIndex ? FONT_BODY : FONT_CAPTION)
          .fontWeight(this.currentIndex === targetIndex ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.currentIndex === targetIndex ? PRIMARY : TEXT_SECONDARY)
      }
      .width(64)
      .height(42)
      .justifyContent(FlexAlign.Center)
      .borderRadius(21)
      .backgroundColor(this.currentIndex === targetIndex ? TAB_ACTIVE_BG : Color.Transparent)
      }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          Home()
        }
        .tabBar(this.tabBuilder('首页', 0, $r('app.media.shouye')))
        TabContent() {
          Category()
        }
        .tabBar(this.tabBuilder('分类', 1, $r('app.media.fenlei')))
        TabContent() {
          Cart()
        }
        .tabBar(this.tabBuilder('购物车', 2, $r('app.media.cart_full')))
        TabContent() {
          Me()
        }
        .tabBar(this.tabBuilder('我的', 3, $r('app.media.wode')))
      }
      .onSelected((index: number) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
  }
}
