import { AppStorageV2 } from '@kit.ArkUI'

// 11.4 步骤1：登录态数据类用 @ObservedV2 + @Trace，属性变化可被 UI 观测
@ObservedV2
export class Token {
  @Trace token: string = ''
  @Trace expireTime: number = 0
}

export function connectToken(): Token {
  return AppStorageV2.connect<Token>(Token, (): Token => new Token())!
}

// 11.4 步骤3：登录成功后把 token 与有效期一起存进全局状态
export function setApiToken(value: string): void {
  const store: Token = connectToken()
  store.token = value
  store.expireTime = Date.now() + 7 * 24 * 60 * 60 * 1000
}

export function getApiToken(): string {
  const store: Token | undefined = AppStorageV2.connect<Token>(Token, (): Token => new Token())
  return store === undefined ? '' : store.token
}
