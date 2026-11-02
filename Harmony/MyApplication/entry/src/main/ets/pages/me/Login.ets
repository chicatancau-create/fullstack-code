import Title from '../component/Title'
import { BG_PAGE, BORDER_LIGHT, CHIP_RADIUS, INPUT_BG, PRIMARY } from '../../common/UiTokens'
import { Account, findAccountByEmail, isEmail } from '../../model/Data'
import { connectUser, User } from '../../model/User'
import { TabIndexArg } from '../../utils/requestUtils'

@Entry
@ComponentV2
struct Login {
  @Local email: string = ''
  @Local password: string = ''
  private user: User = connectUser()

  // 7.4 步骤4：用 @Styles 重用输入框样式（浅灰底 + 细描边 + 圆角）
  @Styles
  inputStyle() {
    .backgroundColor(INPUT_BG)
    .border({ color: BORDER_LIGHT, width: 1 })
    .borderRadius(CHIP_RADIUS)
  }

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
    // 本地登录也写进同一个全局状态，首页与购物车都能读到
    this.user.name = hit.account
    this.user.email = hit.email
    this.user.isLoggedIn = true
    return ''
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '用户登录', isShow: true })

      Column({ space: 12 }) {
        TextInput({ placeholder: '请输入您的邮箱', text: this.email })
          .type(InputType.Email)
          .inputStyle()
          .onChange((value: string) => {
            this.email = value
          })
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .inputStyle()
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
          this.getUIContext().getPromptAction().showToast({ message: `欢迎，${this.user.name}` })
          // 第 8 章：登录成功后带参数跳回主页面，id 3 就是「我的」这个 tab
          setTimeout(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Index', params: { id: 3 } as TabIndexArg })
          }, 500)
        })

      Text('还没有账号？去注册')
        .fontSize(14)
        .fontColor(PRIMARY)
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Reg' })
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
    .backgroundColor(BG_PAGE)
  }
}
