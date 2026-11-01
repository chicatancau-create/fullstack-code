import { ApiUser, UserPayload, getWithToken, putWithToken } from '../../utils/requestUtils'
import Title from '../component/Title'

@Entry
@Component
struct Edit {
  @State username: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State tip: string = ''
  @StorageLink('apiToken') apiToken: string = ''
  @StorageLink('apiUser') apiUser: string = ''

  aboutToAppear(): void {
    this.load()
  }

  // 第 12 章：GET /api/auth/me 取回当前用户，回填表单
  private async load(): Promise<void> {
    if (this.apiToken === '') {
      this.tip = '请先在「我的」里用网络登录登录一次'
      return
    }
    try {
      const text: string = await getWithToken('/api/auth/me', this.apiToken)
      const payload: UserPayload = JSON.parse(text) as UserPayload
      if (payload.code === 200 && payload.data !== undefined) {
        const user: ApiUser = payload.data
        this.username = user.username
        this.email = user.email
        this.phone = user.phone === null ? '' : user.phone
        this.tip = ''
      } else {
        this.tip = payload.message
      }
    } catch (err) {
      this.tip = '连不上服务端，请先启动 shopmall-api-v2-server'
    }
  }

  // 第 12 章：PUT /api/users  body { username, email, phone }
  private async save(): Promise<void> {
    if (this.apiToken === '') {
      this.getUIContext().getPromptAction().showToast({ message: '请先用网络登录登录' })
      return
    }
    if (this.username === '' || this.email === '') {
      this.getUIContext().getPromptAction().showToast({ message: '用户名和邮箱不能为空' })
      return
    }
    try {
      const body: Record<string, string> = {
        'username': this.username,
        'email': this.email,
        'phone': this.phone
      }
      const text: string = await putWithToken('/api/users', JSON.stringify(body), this.apiToken)
      const payload: UserPayload = JSON.parse(text) as UserPayload
      if (payload.code === 200) {
        this.apiUser = this.username
        this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
        this.getUIContext().getRouter().back()
      } else {
        this.getUIContext().getPromptAction().showToast({ message: payload.message })
      }
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败，服务端未响应' })
    }
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '修改个人信息', arrow: true })

      if (this.tip !== '') {
        Text(this.tip)
          .fontSize(13)
          .fontColor('#9B9B9B')
          .width('90%')
      }

      Column({ space: 12 }) {
        TextInput({ placeholder: '用户名', text: this.username })
          .onChange((value: string) => {
            this.username = value
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
      }
      .width('90%')

      Button('保存')
        .width('90%')
        .onClick(() => {
          this.save()
        })

      Text('头像上传（POST /api/users/avatar）未实现：需要相册选图与文件上传写法，暂不加入基础作业')
        .fontSize(12)
        .fontColor('#9B9B9B')
        .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
