import { CARD_RADIUS, FONT_DISPLAY, PRIMARY, SPACE_SM, SPACE_XS } from '../../common/UiTokens'

// 课件 11 章规定：公共标题用状态管理 V2 的 @ComponentV2 + @Param，属性名 isShow 控制返回箭头
@ComponentV2
export default struct Title {
  @Param title: string = ''
  @Param isShow: boolean = true

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row() {
        Image($r('app.media.jiantouzuo'))
          .width(18)
          .height(18)
          .fillColor('#FFFFFF')
          .padding(SPACE_XS)
          .backgroundColor('rgba(255,255,255,0.22)')
          .borderRadius(18)
          .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })
      }
      .width('100%')

      Text(this.title)
        .fontSize(FONT_DISPLAY)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('92%')
    .height(56)
    .padding({ left: SPACE_SM, right: SPACE_SM })
    .borderRadius(CARD_RADIUS)
    .backgroundColor(PRIMARY)
    .margin({ bottom: SPACE_XS })
  }
}
