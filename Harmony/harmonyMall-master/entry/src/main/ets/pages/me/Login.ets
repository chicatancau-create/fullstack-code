import Title from '../component/Title'
@Entry
@Component
struct Login {
  @State email:string="123"
  @State password:string="wofule"
  build() {
    Column({space:10}) {
      Image($r('app.media.denglu')).width(80).margin({top:100,bottom:20})
      Title({title:'用户登录',arrow:true})
      //用户名
      Column(){
        Text("邮箱").textIndent(15)
        TextInput({placeholder:"请输入你的邮箱名"})
          .backgroundColor(0xcccccc)
          .type(InputType.Email)
          .onChange((value)=>{
            this.email=value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      //密码
      Column(){
        Text("密码").textIndent(15)
        TextInput({placeholder:"请输入密码"})
          .type(InputType.Password)
          .backgroundColor(0xcccccc)
          // .onChange((value)=>{
          //   this.password=value
          // })
          .onChange(v=>this.email=v)
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      Button('登录')
        .width('90%')
        .type(ButtonType.Normal)
        .borderRadius(10)
        .onClick(()=>{
          this.login()
        })
      Row(){
        Text("忘记密码")
        // Blank()
        Text("注册")
          .onClick(()=>{
            this.getUIContext().getRouter().pushUrl({url:'pages/me/RegPage'}).catch(() => {
              // TODO: Implement error handling.
            })
          })
      }.width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height('100%')
    .width('100%')
  }
  //处理用户登录
  login(){
    this.getUIContext().getPromptAction()
      .showToast({
        message:"用户名或者密码错误！",
        duration:3000,
        bottom:100,
        textColor:Color.Red,
        shadow:{radius:2,offsetX:3,offsetY:3}
      })
  }
  // 属性	说明
  // message	必选。显示的文本信息。
  // duration	设置Toast弹出的持续时间，取值范围：[1500, 10000]。
  // bottom	设置Toast底部边框距离导航条的高度。
  // showMode	设置Toast层级。参数：DEFAULT显示在应用内；TOP_MOST显示在子窗。
  // textColor	Toast的文本颜色。
  // shadow	Toast的背板阴影，参数：radius模糊半径，type阴影类型，color阴影颜色，offsetX阴影的X轴偏移量，offsetY阴影的Y轴偏移量。

}