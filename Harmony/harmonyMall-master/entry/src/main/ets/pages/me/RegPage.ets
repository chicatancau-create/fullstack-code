import Title from '../component/Title'
@Entry
@Component
struct RegPage {
  @State email: string = ""
  @State password: string = ""
  @State confirmPassword: string = ""
  @State name: string = ""
  @State phone: string = ""

  build() {
    Column({ space: 10 }) {
      Title({ title: '用户注册', arrow: true })
      //邮箱
      Column() {
        Text("邮箱").textIndent(15)
        TextInput({ placeholder: "请输入你的邮箱名" })
          .backgroundColor(0xcccccc)
          .type(InputType.Email)
          .onChange((value) => {
            this.email = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')

      //密码
      Column() {
        Text("密码").textIndent(15)
        TextInput({ placeholder: "请输入你的密码" })
          .backgroundColor(0xcccccc)
          .type(InputType.Password)
          .onChange((value) => {
            this.password = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')

      //确认密码
      Column() {
        Text("确认密码").textIndent(15)
        TextInput({ placeholder: "请再次输入密码" })
          .backgroundColor(0xcccccc)
          .type(InputType.Password)
          .onChange((value) => {
            this.confirmPassword = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')

      Column() {
        Text("用户名").textIndent(15)
        TextInput({ placeholder: "请输入你的用户名" })
          .backgroundColor(0xcccccc)
          .type(InputType.Normal)
          .onChange((value) => {
            this.name = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')

      Column() {
        Text("电话号码").textIndent(15)
        TextInput({ placeholder: "请输入你的电话号码" })
          .backgroundColor(0xcccccc)
          .type(InputType.PhoneNumber)
          .onChange((value) => {
            this.phone = value
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')

      Button('注册')
        .width('90%')
        .type(ButtonType.Normal)
        .borderRadius(10)
        .onClick(() => {
          this.zhuce()
        })
    }
    .height('100%')
    .width('100%')
  }

  //处理用户注册
  zhuce() {
    const emailReg: RegExp = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    const phoneReg: RegExp = /^1[3-9]\d{9}$/
    if (this.email.trim().length === 0) {
      this.showTip("请输入邮箱！")
      return
    }
    if (!emailReg.test(this.email)) {
      this.showTip("邮箱格式不正确！")
      return
    }
    if (this.password.length < 6) {
      this.showTip("请输入至少6位密码！")
      return
    }
    if (this.confirmPassword !== this.password) {
      this.showTip("两次输入的密码不一致！")
      return
    }
    if (this.name.trim().length === 0) {
      this.showTip("请输入用户名！")
      return
    }
    if (!phoneReg.test(this.phone)) {
      this.showTip("请输入正确的11位手机号！")
      return
    }
    this.getUIContext().getPromptAction()
      .showToast({
        message: "注册成功！",
        duration: 3000,
        bottom: 100,
        textColor: Color.Green,
        shadow: { radius: 2, offsetX: 3, offsetY: 3 }
      })
    this.getUIContext().getRouter().back()
  }

  showTip(msg: string) {
    this.getUIContext().getPromptAction()
      .showToast({
        message: msg,
        duration: 3000,
        bottom: 100,
        textColor: Color.Red,
        shadow: { radius: 2, offsetX: 3, offsetY: 3 }
      })
  }
}
