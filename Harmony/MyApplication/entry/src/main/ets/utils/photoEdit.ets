import { common } from '@kit.AbilityKit'
import { picker, fileIo } from '@kit.CoreFileKit'
import { request } from '@kit.BasicServicesKit'
import { AppStorageV2 } from '@kit.ArkUI'
import { ApiUser, BASE_URL } from './requestUtils'
import { Token } from '../model/Token'

// 第 12 章规定的写法：文件选择器选图 -> 复制进应用缓存 -> uploadFile 带 Bearer 令牌
// 服务端 PUT 成功后从 headerReceive 的 body 里取回最新 user
export function photoEdit(context: common.Context): Promise<ApiUser> {
  const options: picker.DocumentSelectOptions = new picker.DocumentSelectOptions()
  const documentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context)
  const store: Token | undefined = AppStorageV2.connect<Token>(Token, (): Token => new Token())
  const token: string = store === undefined ? '' : store.token

  const promise: Promise<ApiUser> = new Promise((resolve: (user: ApiUser) => void,
    reject: (reason: string) => void) => {
    documentPicker.select(options).then((result: Array<string>) => {
      const uri: string = result[0]
      const fileName: string = uri.split('/').pop() ?? ''
      const imgData = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      const newDir: string = context.cacheDir + '/' + fileName
      fileIo.copyFileSync(imgData.fd, newDir)

      const uploadConfig: request.UploadConfig = {
        url: BASE_URL + '/api/users/avatar',
        header: {
          'Accept': '*/*',
          'Content-type': 'multipart/form-data',
          'Authorization': 'Bearer ' + token
        } as Record<string, string>,
        method: 'POST',
        files: [{
          filename: fileName,
          name: 'avatar',
          uri: 'internal://cache/' + fileName,
          type: 'image/jpeg'
        }],
        data: []
      }
      request.uploadFile(context, uploadConfig).then((uploadTask: request.UploadTask) => {
        uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
          console.log('头像上传成功')
        })
        uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
          reject('头像上传失败')
        })
        const headerCallback = (headers: object) => {
          try {
            const bag: Record<string, string> = headers as Record<string, string>
            const payload: object = JSON.parse(bag['body']) as object
            const data: Record<string, object> = payload as Record<string, object>
            const user: ApiUser = data['data'] as ApiUser
            if (user !== undefined) {
              resolve(user)
            }
          } catch (e) {
            reject('上传响应解析失败')
          }
        }
        uploadTask.on('headerReceive', headerCallback)
      })
    }).catch((err: Error) => {
      reject('未选择图片')
    })
  })
  return promise
}
