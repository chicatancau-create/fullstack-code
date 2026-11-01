import Title from '../component/Title'
import { connectUser, User } from '../../model/User'

@ComponentV2
export default struct Index {
  @Local user: User = connectUser()

  build() {
    Column({ space: 12 }) {
      Title({ title: '个人中心' })
      if (!this.user.isLoggedIn) {
        Text('登录')
          // 响应事件
          .onClick(() => {
            // this.getUIContext() 获取当前的上下文
            this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Login' })
          })
        Text('注册')
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Reg' })
          })
      } else {
        Text(`已登录：${this.user.name}`)
        Text('退出登录')
          .onClick(() => {
            this.user.isLoggedIn = false
            this.user.name = ''
          })
      }
      // 本周作业入口：收货地址列表页
      Row({ space: 20 }) {
        Image($r('app.media.daohangdizhi')).width(20)
        Text('收货地址').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/test/AddressPage' })
      })
      // 5.5 通讯录作业入口
      Row({ space: 20 }) {
        Image($r('app.media.liulan')).width(20)
        Text('通讯录').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/test/ContactPage' })
      })
      // 第 5 章商品列表练习入口
      Row({ space: 20 }) {
        Image($r('app.media.liulan')).width(20)
        Text('商品列表').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/test/ListPage' })
      })
      // 第 10 章 Navigation 商品详情入口
      Row({ space: 20 }) {
        Image($r('app.media.liulan')).width(20)
        Text('商品详情').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/goods/NavPage' })
      })
      // 第 9 章网络商品列表入口（需先启动课件服务端）
      Row({ space: 20 }) {
        Image($r('app.media.liulan')).width(20)
        Text('网络商品列表').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/test/NetGoodsPage' })
      })
      // 第 11 章服务端登录入口，和本地登录互不影响
      Row({ space: 20 }) {
        Image($r('app.media.denglu')).width(20)
        Text(this.user.isLoggedIn ? `服务端/本地已登录：${this.user.name}` : '网络登录（服务端）').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/me/LoginApi' })
      })
      // 以下三行按课件只做静态展示，暂无对应页面
      Row({ space: 20 }) {
        Image($r('app.media.shoucang')).width(20)
        Text('我的收藏').fontSize(15)
      }
      .width('90%')
      Divider()
      Row({ space: 20 }) {
        Image($r('app.media.shimingrenzheng')).width(20)
        Text('修改密码').fontSize(15)
      }
      .width('90%')
      Divider()
      Row({ space: 20 }) {
        Image($r('app.media.pingjia')).width(20)
        Text('修改信息').fontSize(15)
      }
      .width('90%')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Edit' })
      })
      Divider()
      Row({ space: 20 }) {
        Image($r('app.media.kefu')).width(20)
        Text('联系客服').fontSize(15)
      }
      .width('90%')
    }
    .width('100%')
    .height('100%')
  }
}
