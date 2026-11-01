import { ApiUser, LoginPayload, postJson } from '../../utils/requestUtils'
import { setApiToken } from '../../model/Token'
import Title from '../component/Title'

@Entry
@Component
struct LoginApi {
  @State email: string = ''
  @State password: string = ''
  @State busy: boolean = false
  @StorageLink('apiUser') apiUser: string = ''
  @StorageLink('apiToken') apiToken: string = ''

  // 服务端契约：POST /api/auth/login  body { email, password }
  // 成功 { code:200, message:'登录成功', data:{ user, token } }
  private async doLogin(): Promise<void> {
    if (this.email === '' || this.password === '') {
      this.getUIContext().getPromptAction().showToast({ message: '邮箱和密码不能为空' })
      return
    }
    this.busy = true
    try {
      const body: Record<string, string> = { 'email': this.email, 'password': this.password }
      const text: string = await postJson('/api/auth/login', JSON.stringify(body))
      const payload: LoginPayload = JSON.parse(text) as LoginPayload
      if (payload.code === 200 && payload.data !== undefined && payload.data.token !== '') {
        const user: ApiUser = payload.data.user
        this.apiToken = payload.data.token
        setApiToken(payload.data.token)
        this.apiUser = user.username
        this.getUIContext().getPromptAction().showToast({ message: `欢迎，${user.username}` })
        this.getUIContext().getRouter().back()
      } else {
        this.getUIContext().getPromptAction().showToast({ message: payload.message })
      }
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '连不上服务端，请先启动 shopmall-api-v2-server' })
    } finally {
      this.busy = false
    }
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '网络登录', arrow: true })

      Text('第 11 章：调用课件服务端 /api/auth/login，与本地登录互不影响')
        .fontSize(13)
        .fontColor('#9B9B9B')
        .width('90%')

      Column({ space: 12 }) {
        TextInput({ placeholder: '邮箱', text: this.email })
          .type(InputType.Email)
          .onChange((value: string) => {
            this.email = value
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
      }
      .width('90%')

      Button(this.busy ? '登录中…' : '登录')
        .width('90%')
        .enabled(!this.busy)
        .onClick(() => {
          this.doLogin()
        })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
