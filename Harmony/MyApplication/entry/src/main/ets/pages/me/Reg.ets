import Title from '../component/Title'
import { Account, findAccount } from '../../model/Data'

@Entry
@Component
struct Reg {
  @State account: string = ''
  @State phone: string = ''
  @State password: string = ''
  @State confirm: string = ''

  private check(): string {
    if (this.account === '' || this.password === '') {
      return '账号和密码不能为空'
    }
    if (!/^1\d{10}$/.test(this.phone)) {
      return '手机号格式不正确'
    }
    if (this.password.length < 6) {
      return '密码至少 6 位'
    }
    if (this.password !== this.confirm) {
      return '两次输入的密码不一致'
    }
    const list: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    if (findAccount(list, this.account) !== undefined) {
      return '账号已存在'
    }
    return ''
  }

  private save(): void {
    const accounts: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    accounts.push(new Account(this.account, this.password, this.phone))
    AppStorage.setOrCreate('accounts', accounts)
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '用户注册', arrow: true })

      Column({ space: 12 }) {
        TextInput({ placeholder: '账号', text: this.account })
          .onChange((value: string) => {
            this.account = value
          })
        TextInput({ placeholder: '手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .onChange((value: string) => {
            this.phone = value
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
        TextInput({ placeholder: '确认密码', text: this.confirm })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.confirm = value
          })
      }
      .width('90%')

      Button('注册')
        .width('90%')
        .onClick(() => {
          const msg: string = this.check()
          if (msg !== '') {
            this.getUIContext().getPromptAction().showToast({ message: msg })
            return
          }
          this.save()
          this.getUIContext().getPromptAction().showToast({ message: '注册成功，请用该账号登录' })
          this.getUIContext().getRouter().back()
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
