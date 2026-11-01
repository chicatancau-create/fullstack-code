import Title from '../component/Title'
import { Account, findAccountByEmail, isEmail } from '../../model/Data'

@Entry
@Component
struct Login {
  @State email: string = ''
  @State password: string = ''
  @StorageLink('loginUser') loginUser: string = ''

  // 第 7 章规定：邮箱格式正确且密码不少于 6 位才允许点登录
  private canSubmit(): boolean {
    return isEmail(this.email) && this.password.length >= 6
  }

  private login(): string {
    if (!isEmail(this.email)) {
      return '请输入有效邮箱'
    }
    if (this.password.length < 6) {
      return '密码至少 6 位'
    }
    const list: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    const hit: Account | undefined = findAccountByEmail(list, this.email)
    if (hit === undefined) {
      return '该邮箱未注册，请先注册'
    }
    if (hit.password !== this.password) {
      return '密码错误'
    }
    this.loginUser = hit.account
    return ''
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '用户登录', arrow: true })

      Column({ space: 12 }) {
        TextInput({ placeholder: '请输入您的邮箱', text: this.email })
          .type(InputType.Email)
          .onChange((value: string) => {
            this.email = value
          })
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
      }
      .width('90%')

      Button('登录')
        .width('90%')
        .enabled(this.canSubmit())
        .onClick(() => {
          const msg: string = this.login()
          if (msg !== '') {
            this.getUIContext().getPromptAction().showToast({ message: msg })
            return
          }
          this.getUIContext().getPromptAction().showToast({ message: `欢迎，${this.loginUser}` })
          this.getUIContext().getRouter().back()
        })

      Text('还没有账号？去注册')
        .fontSize(14)
        .fontColor('#1698CE')
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Reg' })
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
