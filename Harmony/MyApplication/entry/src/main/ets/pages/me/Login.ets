import Title from '../component/Title'
import { Account, findAccount } from '../../model/Data'

@Entry
@Component
struct Login {
  @State account: string = ''
  @State password: string = ''
  @StorageLink('loginUser') loginUser: string = ''

  private login(): string {
    if (this.account === '' || this.password === '') {
      return '账号和密码不能为空'
    }
    const list: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    const hit: Account | undefined = findAccount(list, this.account)
    if (hit === undefined) {
      return '账号不存在，请先注册'
    }
    if (hit.password !== this.password) {
      return '密码错误'
    }
    this.loginUser = this.account
    return ''
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '用户登录', arrow: true })

      Column({ space: 12 }) {
        TextInput({ placeholder: '账号', text: this.account })
          .onChange((value: string) => {
            this.account = value
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
      }
      .width('90%')

      Button('登录')
        .width('90%')
        .onClick(() => {
          const msg: string = this.login()
          if (msg !== '') {
            this.getUIContext().getPromptAction().showToast({ message: msg })
            return
          }
          this.getUIContext().getPromptAction().showToast({ message: `欢迎，${this.account}` })
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
