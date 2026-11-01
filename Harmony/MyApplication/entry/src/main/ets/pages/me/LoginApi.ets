import { ApiUser, LoginPayload, postJson } from '../../utils/requestUtils'
import { setApiToken } from '../../model/Token'
import { connectUser, User } from '../../model/User'
import Title from '../component/Title'

@Entry
@ComponentV2
struct LoginApi {
  @Local email: string = ''
  @Local password: string = ''
  @Local busy: boolean = false
  private user: User = connectUser()

  // 服务端契约：POST /api/auth/login  body { email, password }
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
        const api: ApiUser = payload.data.user
        // 11.4 步骤3：登录成功后用 AppStorageV2 保存用户信息与令牌
        setApiToken(payload.data.token)
        this.user.id = api.id
        this.user.name = api.username
        this.user.email = api.email
        this.user.avatar = api.avatar === null ? '' : api.avatar
        this.user.isLoggedIn = true
        this.getUIContext().getPromptAction().showToast({ message: `欢迎，${api.username}` })
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
      Title({ title: '网络登录', isShow: true })

      Text('第 11 章：调用课件服务端 /api/auth/login，登录状态用 AppStorageV2 全局共享')
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
