import Me from './me/Index'
@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
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
    Tabs({barPosition:BarPosition.End}) {
      TabContent() {
      }
      .tabBar(this.tabBuilder('首页',0,$r('app.media.shouye')))
      TabContent() {
      }
      .tabBar(this.tabBuilder('分类',1,$r('app.media.fenlei')))
      TabContent() {
      }
      .tabBar(this.tabBuilder('购物车',2,$r('app.media.cart_full')))
      TabContent() {
        Me()
      }
      .tabBar(this.tabBuilder('我的',3,$r('app.media.wode')))
    }
    .onSelected((index: number) => {
      this.currentIndex = index;
    })
  }
}
