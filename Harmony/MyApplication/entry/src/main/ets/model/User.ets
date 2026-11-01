// 11.4 步骤1：登录状态用状态管理 V2 的数据类，属性可被观测
import { AppStorageV2 } from '@kit.ArkUI'

@ObservedV2
export class User {
  @Trace id: number = 0
  @Trace name: string = ''
  @Trace email: string = ''
  @Trace avatar: string = ''
  @Trace isLoggedIn: boolean = false
}

export function connectUser(): User {
  return AppStorageV2.connect<User>(User, (): User => new User())!
}
