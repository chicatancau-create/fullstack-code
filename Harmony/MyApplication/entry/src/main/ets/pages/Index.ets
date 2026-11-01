import Home from "./home/Home"
import Category from "./category/Category"
import Cart from "./cart/Cart"
import Me from "./me/Index"
import { TabIndexArg } from '../utils/requestUtils'

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

  @Builder tabBuilder(title: string, targetIndex: number, image: Resource) {
    Column() {
      Image(image)
        .size({ width: 25, height: 25 })
        .fillColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
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
