import { AppStorageV2 } from '@kit.ArkUI'

// 第 12 章课件要求：用状态管理 V2 的应用级存储保存服务端 token
@ObservedV2
export class Token {
  @Trace token: string = ''
}

export function setApiToken(value: string): void {
  const store: Token | undefined = AppStorageV2.connect<Token>(Token, (): Token => new Token())
  if (store !== undefined) {
    store.token = value
  }
}

export function getApiToken(): string {
  const store: Token | undefined = AppStorageV2.connect<Token>(Token, (): Token => new Token())
  return store === undefined ? '' : store.token
}
