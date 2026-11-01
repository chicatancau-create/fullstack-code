import { ApiUser, BASE_URL, getWithToken, putWithToken, ResponseData } from '../../utils/requestUtils'
import { getApiToken } from '../../model/Token'
import { connectUser, User } from '../../model/User'
import { photoEdit } from '../../utils/photoEdit'
import { common } from '@kit.AbilityKit'
import Title from '../component/Title'

@Entry
@Component
struct Edit {
  @State username: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State avatar: string = ''
  @State tip: string = ''

  aboutToAppear(): void {
    this.load()
  }

  // 第 12 章：GET /api/auth/me 取回当前用户，回填表单
  private async load(): Promise<void> {
    const token: string = getApiToken()
    if (token === '') {
      this.tip = '请先在「我的」里用网络登录登录一次'
      return
    }
    try {
      const text: string = await getWithToken('/api/auth/me', token)
      const res: ResponseData<ApiUser> = JSON.parse(text) as ResponseData<ApiUser>
      if (res.code === 200 && res.data !== undefined) {
        const user: ApiUser = res.data
        this.username = user.username
        this.email = user.email
        this.phone = user.phone === null ? '' : user.phone
        this.avatar = user.avatar === null ? '' : user.avatar
        this.tip = ''
      } else {
        this.tip = res.message
      }
    } catch (err) {
      this.tip = '连不上服务端，请先启动 shopmall-api-v2-server'
    }
  }

  // 第 12 章：PUT /api/users  body { username, email, phone }
  private async save(): Promise<void> {
    const token: string = getApiToken()
    if (token === '') {
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
      const text: string = await putWithToken('/api/users', JSON.stringify(body), token)
      const res: ResponseData<ApiUser> = JSON.parse(text) as ResponseData<ApiUser>
      if (res.code === 200) {
        const global: User = connectUser()
        global.name = this.username
        this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
        this.getUIContext().getRouter().back()
      } else {
        this.getUIContext().getPromptAction().showToast({ message: res.message })
      }
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败，服务端未响应' })
    }
  }

  // 12.1 规定的头像上传写法：选图 -> 复制进缓存 -> uploadFile 带令牌 -> headerReceive 取回 user
  private async uploadAvatar(): Promise<void> {
    if (getApiToken() === '') {
      this.getUIContext().getPromptAction().showToast({ message: '请先用网络登录登录' })
      return
    }
    const ctx: common.Context = this.getUIContext().getHostContext() as common.Context
    try {
      const user: ApiUser = await photoEdit(ctx)
      this.avatar = user.avatar === null || user.avatar === undefined ? '' : user.avatar
      connectUser().avatar = this.avatar
      this.getUIContext().getPromptAction().showToast({ message: '头像已更新' })
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '头像上传失败' })
    }
  }

  build() {
    Column({ space: 16 }) {
      Title({ title: '修改个人信息', isShow: true })

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

      Row({ space: 12 }) {
        Image(this.avatar === '' ? $r('app.media.denglu') : BASE_URL + this.avatar)
          .width(60)
          .height(60)
          .borderRadius(30)
          .objectFit(ImageFit.Cover)
        Button('选择并上传头像')
          .fontSize(14)
          .onClick(() => {
            this.uploadAvatar()
          })
      }
      .width('90%')
      .justifyContent(FlexAlign.Start)

      Text('服务端未启动时，以上网络功能会提示连不上，属正常现象')
        .fontSize(12)
        .fontColor('#9B9B9B')
        .width('90%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 16 })
  }
}
