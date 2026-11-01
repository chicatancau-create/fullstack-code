import Title from '../component/Title'
import { Account, findAccount, findAccountByEmail, isEmail } from '../../model/Data'

@Entry
@Component
struct Reg {
  @State account: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State password: string = ''
  @State confirm: string = ''

  // 第 8 章规定的校验项：用户名 4-10 位、邮箱格式、11 位手机号、密码至少 6 位、两次一致
  private check(): string {
    if (this.account.length < 4 || this.account.length > 10) {
      return '用户名必须在 4-10 位之间'
    }
    if (!isEmail(this.email)) {
      return '请输入有效邮箱'
    }
    if (!/^1\d{10}$/.test(this.phone)) {
      return '手机号必须是 11 位且以 1 开头'
    }
    if (this.password.length < 6) {
      return '密码至少 6 位'
    }
    if (this.password !== this.confirm) {
      return '两次输入的密码不一致'
    }
    const list: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    if (findAccount(list, this.account) !== undefined) {
      return '该用户名已存在'
    }
    if (findAccountByEmail(list, this.email) !== undefined) {
      return '该邮箱已注册'
    }
    return ''
  }

  private canSubmit(): boolean {
    return this.account.length >= 4 && this.account.length <= 10 && isEmail(this.email)
      && /^1\d{10}$/.test(this.phone) && this.password.length >= 6 && this.password === this.confirm
  }

  private save(): void {
    const accounts: Account[] = AppStorage.get<Account[]>('accounts') ?? []
    accounts.push(new Account(this.account, this.email, this.password, this.phone))
    AppStorage.setOrCreate('accounts', accounts)
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '用户注册', arrow: true })

      Column({ space: 12 }) {
        TextInput({ placeholder: '用户名（4-10 位）', text: this.account })
          .onChange((value: string) => {
            this.account = value
          })
        TextInput({ placeholder: '邮箱', text: this.email })
          .type(InputType.Email)
          .onChange((value: string) => {
            this.email = value
          })
        TextInput({ placeholder: '手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .onChange((value: string) => {
            this.phone = value
          })
        TextInput({ placeholder: '密码（至少 6 位）', text: this.password })
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
        .enabled(this.canSubmit())
        .onClick(() => {
          const msg: string = this.check()
          if (msg !== '') {
            this.getUIContext().getPromptAction().showToast({ message: msg })
            return
          }
          this.save()
          this.getUIContext().getPromptAction().showToast({ message: '注册成功，请用该邮箱登录' })
          this.getUIContext().getRouter().back()
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
