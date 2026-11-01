// 11 章把状态管理改成 V2 后，公共标题组件也按课件用 @ComponentV2 + @Param
@ComponentV2
export default struct Title {
  @Param title: string = ''
  // 课件里这个属性叫 isShow：控制返回箭头显示与否，默认显示
  @Param isShow: boolean = true

  build() {
    Stack() {
      Row() {
        Image($r('app.media.jiantouzuo'))
          .width(20)
          .height(20)
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })
          .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
      }
      .width('90%')

      Text(this.title)
        .fontSize(20)
        .fontWeight(700)
    }
    .width('100%')
    .margin({ bottom: 10 })
  }
}
