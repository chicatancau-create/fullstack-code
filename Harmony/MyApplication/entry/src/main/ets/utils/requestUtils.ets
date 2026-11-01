import { http } from '@kit.NetworkKit'

// 真机联调时把这里换成运行服务端那台电脑的局域网 IP，例如 http://192.168.1.5:3000
export const BASE_URL: string = 'http://127.0.0.1:3000'

// 对应服务端 products 表（GET /api/products 返回 data 数组）
export interface ProductRow {
  id: number
  name: string
  description: string
  price: string
  stock: number
  images: string
}

// 服务端统一响应包：{ code, message, data }
export interface ProductsPayload {
  code: number
  message: string
  data: ProductRow[]
}

// 第 9 章要求的最小流程：createHttp -> request -> destroy
export async function getJson(path: string): Promise<string> {
  const httpRequest: http.HttpRequest = http.createHttp()
  try {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.STRING,
      header: { 'Content-Type': 'application/json' } as Record<string, string>,
      connectTimeout: 10000,
      readTimeout: 10000
    }
    const response: http.HttpResponse = await httpRequest.request(BASE_URL + path, options)
    if (response.responseCode !== 200) {
      throw new Error('HTTP ' + response.responseCode.toString())
    }
    return response.result as string
  } finally {
    httpRequest.destroy()
  }
}

// images 字段是逗号分隔的相对路径，取第一张并拼成完整地址
export function firstImage(images: string): string {
  if (images === '') {
    return ''
  }
  const hit: string[] = images.split(',')
  return BASE_URL + hit[0]
}
