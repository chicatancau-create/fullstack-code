import Title from '../component/Title'
import { Account, findAccount, findAccountByEmail, isEmail } from '../../model/Data'
import { BG_PAGE, PRIMARY_END, PRIMARY_START } from '../../common/UiTokens'

@Entry
@ComponentV2
struct Reg {
  @Local account: string = ''
  @Local email: string = ''
  @Local phone: string = ''
  @Local password: string = ''
  @Local confirm: string = ''
  // 8.4 规定注册页还要收集性别(Radio)、爱好(Checkbox)、出生日期(日历选择)
  @Local gender: string = ''
  @Local hobby: string[] = []
  @Local birthday: string = ''
  @Local birthdayDate: Date = new Date()

  private toggleHobby(name: string, on: boolean): void {
    const i: number = this.hobby.indexOf(name)
    if (on && i < 0) {
      this.hobby.push(name)
    }
    if (!on && i >= 0) {
      this.hobby.splice(i, 1)
    }
  }

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
      Title({ title: '用户注册', isShow: true })

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

        Row() {
          Text('请选择性别')
            .fontSize(14)
          Blank()
          Radio({ value: '男', group: 'gender' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.gender = '男'
              }
            })
          Text('男')
            .fontSize(14)
          Blank()
          Radio({ value: '女', group: 'gender' })
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.gender = '女'
              }
            })
          Text('女')
            .fontSize(14)
        }
        .width('100%')

        Row() {
          Text('请选择爱好')
            .fontSize(14)
          Blank()
          Checkbox({ name: '足球', group: 'hobby' })
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onChange((value: boolean) => {
              this.toggleHobby('足球', value)
            })
          Text('足球')
            .fontSize(14)
          Blank()
          Checkbox({ name: '篮球', group: 'hobby' })
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onChange((value: boolean) => {
              this.toggleHobby('篮球', value)
            })
          Text('篮球')
            .fontSize(14)
        }
        .width('100%')

        // 8.4 规定的日历弹窗：点输入框弹 CalendarPickerDialog，确认后回填日期
        TextInput({ placeholder: '请选择出生日期', text: this.birthday })
          .onChange((value: string) => {
            this.birthday = value
          })
          .onClick(() => {
            // 8.4 规定的日历弹窗：本 SDK 里 CalendarPickerDialog 是静态方法 show()
            CalendarPickerDialog.show({
              selected: this.birthdayDate,
              onAccept: (value: Date) => {
                this.birthdayDate = value
                this.birthday = `${value.getFullYear()}-${value.getMonth() + 1}-${value.getDate()}`
              },
              onCancel: () => {
              }
            })
          })
      }
      .width('90%')

      Button('注册')
        .width('90%')
        .linearGradient({
          angle: 135,
          colors: [[PRIMARY_START, 0], [PRIMARY_END, 1]]
        })
        .enabled(this.canSubmit())
        .onClick(() => {
          const msg: string = this.check()
          if (msg !== '') {
            this.getUIContext().getPromptAction().showToast({ message: msg })
            return
          }
          this.save()
          this.getUIContext().getPromptAction().showToast({
            message: `注册成功：${this.gender} ${this.hobby.join('/')} ${this.birthday}`
          })
          this.getUIContext().getRouter().back()
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
    .backgroundColor(BG_PAGE)
  }
}
