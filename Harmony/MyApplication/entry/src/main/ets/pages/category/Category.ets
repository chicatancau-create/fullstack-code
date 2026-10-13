@Component
export default struct Category {
  private menus: string[] = ['厨房电器', '生活电器', '电脑电器']
  private goods: string[][] = [
    ['电饭煲', '微波炉', '油烟机'],
    ['吸尘器', '加湿器', '电风扇'],
    ['笔记本电脑', '显示器', '机械键盘']
  ]
  @State selected: number = 0

  build() {
    Row() {
      List({ space: 8 }) {
        ForEach(this.menus, (item: string, index: number) => {
          ListItem() {
            Text(item)
              .fontSize(15)
              .fontColor(this.selected === index ? '#1698CE' : '#333333')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(12)
          }
          .backgroundColor(this.selected === index ? '#EAF5FB' : '#F5F5F5')
          .onClick(() => {
            this.selected = index
          })
        }, (item: string) => item)
      }
      .width(100)
      .height('100%')
      .scrollBar(BarState.Off)

      Column({ space: 12 }) {
        Text(this.menus[this.selected])
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        ForEach(this.goods[this.selected], (item: string) => {
          Row() {
            Text(item).fontSize(15)
            Image($r('app.media.jiantouyou'))
              .width(16)
              .fillColor('#9B9B9B')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }, (item: string) => item)
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
