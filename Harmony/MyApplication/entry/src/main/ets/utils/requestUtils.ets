import { http } from '@kit.NetworkKit'

// 本机自测用 127.0.0.1；真机或机房按课件示例改成服务端所在机器的局域网 IP，
// 例如老师快照里写的是 http://10.2.64.151:3000
export const BASE_URL: string = 'http://127.0.0.1:3000'

// 对应服务端 products 表；模型命名按 5.4 任务演示规定的写法
// description / images / stock 在服务端可为 NULL
export interface ProductDataModel {
  id: number
  name: string
  description: string | null
  price: string
  stock: number
  category_id: number
  images: string | null
}

// 分页信息
export interface Pagination {
  total: number
  page: number
  limit: number
  totalPages: number
}

// 商品列表数据体
export interface GoodsDataModel {
  products: ProductDataModel[]
  pagination: Pagination
}

// 服务端统一响应包：{ code, message, data }
export interface ResponseData<T> {
  code: number
  message: string
  data: T
}

// 宫格点进商品列表时传的分类参数
export interface CategoryArg {
  categoryId: number
}

// 第 9 章要求的最小流程：createHttp -> request -> destroy
// 非 200 也照常返回正文，交给调用方按 code 分支显示服务端真实文案
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
    return response.result as string
  } finally {
    httpRequest.destroy()
  }
}

// images 字段是逗号分隔的相对路径，取第一张并拼成完整地址
export function firstImage(images: string | null): string {
  if (images === null || images === '') {
    return ''
  }
  const hit: string[] = images.split(',')
  return BASE_URL + hit[0]
}

// POST 用；服务端失败时也会回 { code, message }，所以非 200 也返回正文
export async function postJson(path: string, body: string): Promise<string> {
  const httpRequest: http.HttpRequest = http.createHttp()
  try {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      expectDataType: http.HttpDataType.STRING,
      header: { 'Content-Type': 'application/json' } as Record<string, string>,
      extraData: body,
      connectTimeout: 10000,
      readTimeout: 10000
    }
    const response: http.HttpResponse = await httpRequest.request(BASE_URL + path, options)
    return response.result as string
  } finally {
    httpRequest.destroy()
  }
}

// POST /api/auth/login 的成功响应：data = { user, token }
// phone / avatar 在服务端可为 NULL
export interface ApiUser {
  id: number
  username: string
  email: string
  phone: string | null
  avatar: string | null
  role: string
}

export interface LoginData {
  user: ApiUser
  token: string
}

export interface LoginPayload {
  code: number
  message: string
  data: LoginData
}

function authHeader(token: string): Record<string, string> {
  const header: Record<string, string> = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  }
  return header
}

// 带令牌的 GET：GET /api/auth/me
export async function getWithToken(path: string, token: string): Promise<string> {
  const httpRequest: http.HttpRequest = http.createHttp()
  try {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.STRING,
      header: authHeader(token),
      connectTimeout: 10000,
      readTimeout: 10000
    }
    const response: http.HttpResponse = await httpRequest.request(BASE_URL + path, options)
    return response.result as string
  } finally {
    httpRequest.destroy()
  }
}

// 带令牌的 PUT：PUT /api/users
export async function putWithToken(path: string, body: string, token: string): Promise<string> {
  const httpRequest: http.HttpRequest = http.createHttp()
  try {
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.PUT,
      expectDataType: http.HttpDataType.STRING,
      header: authHeader(token),
      extraData: body,
      connectTimeout: 10000,
      readTimeout: 10000
    }
    const response: http.HttpResponse = await httpRequest.request(BASE_URL + path, options)
    return response.result as string
  } finally {
    httpRequest.destroy()
  }
}

// 登录成功后跳回主页面时带的参数：id 就是要定位到的 tab 下标
export interface TabIndexArg {
  id: number
}

// 详情页统一参数：本地商品和服务端商品都转成它再传参
export interface DetailArg {
  title: string
  priceText: string
  content: string
  image: string
  stockText: string
}
