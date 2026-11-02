import { CARD_RADIUS, FONT_DISPLAY, MOTION_FAST, PRIMARY_END, PRIMARY_START, SPACE_SM, SPACE_XS } from '../../common/UiTokens'

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
          .stateStyles({
            pressed: {
              .opacity(0.6)
            },
            normal: {
              .opacity(1)
            }
          })
          .animation({ duration: MOTION_FAST })
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
    .linearGradient({
      angle: 135,
      colors: [[PRIMARY_START, 0], [PRIMARY_END, 1]]
    })
    .shadow({
      radius: 10,
      color: 'rgba(43,127,243,0.28)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: SPACE_XS })
  }
}
