import Title from '../component/Title';

@Entry
@Component
struct Login {
  @State email: string = '';
  @State password: string = '';

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.denglu')).width(80).margin({ top: 100, bottom: 20 })
      Title({ title: '用户登录', arrow: true })
      // 邮箱
      Column() {
        Text('邮箱').textIndent(15)
        TextInput({ placeholder: '请输入你的邮箱名' })
          .backgroundColor(0xF1F3F5)
          .type(InputType.Email)
          .onChange((value: string) => {
            this.email = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      // 密码
      Column() {
        Text('密码').textIndent(15)
        TextInput({ placeholder: '请输入密码' })
          .backgroundColor(0xF1F3F5)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      Button('登录')
        .width('90%')
        .type(ButtonType.Normal)
        .borderRadius(10)
        .onClick(() => {
          this.login();
        })
      Row() {
        Text('忘记密码')
          .onClick(() => {
            this.getUIContext().showAlertDialog({
              title: '提示',
              message: '请联系管理员重置密码',
              confirm: {
                value: '确定',
                action: () => {
                }
              }
            })
          })
        Text('注册')
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/me/RegPage' }).catch(() => {
              // TODO: Implement error handling.
            })
          })
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height('100%')
    .width('100%')
  }

  // 处理用户登录
  login() {
    if (this.email.trim().length === 0) {
      this.showTip('请输入邮箱！');
      return;
    }
    if (this.password.length === 0) {
      this.showTip('请输入密码！');
      return;
    }
    this.getUIContext().getPromptAction()
      .showToast({
        message: '登录成功！',
        duration: 3000,
        bottom: 100,
        textColor: Color.Green,
        shadow: { radius: 2, offsetX: 3, offsetY: 3 }
      });
    this.getUIContext().getRouter().back();
  }

  showTip(msg: string) {
    this.getUIContext().getPromptAction()
      .showToast({
        message: msg,
        duration: 3000,
        bottom: 100,
        textColor: Color.Red,
        shadow: { radius: 2, offsetX: 3, offsetY: 3 }
      });
  }
}
