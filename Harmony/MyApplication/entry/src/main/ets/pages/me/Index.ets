import Title from '../component/Title'
import { connectUser, User } from '../../model/User'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  FONT_BODY,
  FONT_SUBTITLE,
  PRIMARY,
  PRIMARY_TINT,
  SPACE_MD,
  SPACE_SM,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

@ComponentV2
export default struct Index {
  @Local user: User = connectUser()

  // 6.5 同款写法：把一行入口提炼成 @Builder。target 为空表示课件里只做静态展示的行
  @Builder
  rowCell(icon: Resource, label: string, target: string) {
    Row({ space: SPACE_SM }) {
      Column() {
        Image(icon)
          .width(18)
          .height(18)
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor(PRIMARY_TINT)
      .justifyContent(FlexAlign.Center)

      Text(label)
        .fontSize(FONT_SUBTITLE)
        .fontColor(TEXT_MAIN)
        .layoutWeight(1)

      if (target !== '') {
        Image($r('app.media.jiantouyou'))
          .width(14)
          .height(14)
          .fillColor(TEXT_MUTED)
      }
    }
    .width('100%')
    .height(44)
    .onClick(() => {
      if (target !== '') {
        this.getUIContext().getRouter().pushUrl({ url: target })
      }
    })
  }

  build() {
    Column({ space: SPACE_SM }) {
      Title({ title: '个人中心', isShow: false })

      // 账号状态：未登录给登录/注册两个入口，已登录给退出登录
      if (!this.user.isLoggedIn) {
        Row({ space: SPACE_MD }) {
          Text('未登录')
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MUTED)
            .layoutWeight(1)
          Text('登录')
            // 响应事件
            .fontSize(FONT_BODY)
            .fontColor(PRIMARY)
            .onClick(() => {
              // this.getUIContext() 获取当前的上下文
              this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Login' })
            })
          Text('注册')
            .fontSize(FONT_BODY)
            .fontColor(PRIMARY)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: 'pages/me/Reg' })
            })
        }
        .width('92%')
        .height(28)
      } else {
        Row({ space: SPACE_MD }) {
          Text(`已登录：${this.user.name}`)
            .fontSize(FONT_BODY)
            .fontColor(TEXT_MAIN)
            .layoutWeight(1)
          Text('退出登录')
            .fontSize(FONT_BODY)
            .fontColor(PRIMARY)
            .onClick(() => {
              this.user.isLoggedIn = false
              this.user.name = ''
            })
        }
        .width('92%')
        .height(28)
      }

      // 十行入口一屏放不下时靠这层滚动，写法与首页一致
      Scroll() {
        Column() {
          // 本周作业入口：收货地址列表页
          this.rowCell($r('app.media.daohangdizhi'), '收货地址', 'pages/test/AddressPage')
          Divider()
          // 5.5 通讯录作业入口
          this.rowCell($r('app.media.liulan'), '通讯录', 'pages/test/ContactPage')
          Divider()
          // 第 5 章商品列表练习入口
          this.rowCell($r('app.media.liulan'), '商品列表', 'pages/test/ListPage')
          Divider()
          // 第 10 章 Navigation 商品详情入口
          this.rowCell($r('app.media.liulan'), '商品详情', 'pages/goods/NavPage')
          Divider()
          // 第 9 章网络商品列表入口（需先启动课件服务端）
          this.rowCell($r('app.media.liulan'), '网络商品列表', 'pages/test/NetGoodsPage')
          Divider()
          // 第 11 章服务端登录入口，和本地登录互不影响
          this.rowCell($r('app.media.denglu'),
            this.user.isLoggedIn ? `服务端已登录：${this.user.name}` : '网络登录（服务端）', 'pages/me/LoginApi')
          Divider()
          // 修改个人信息入口（第 12 章）
          this.rowCell($r('app.media.pingjia'), '修改信息', 'pages/me/Edit')
          Divider()
          // 以下三行按课件只做静态展示，暂无对应页面
          this.rowCell($r('app.media.shoucang'), '我的收藏', '')
          Divider()
          this.rowCell($r('app.media.shimingrenzheng'), '修改密码', '')
          Divider()
          this.rowCell($r('app.media.kefu'), '联系客服', '')
        }
        .width('92%')
        .padding({ left: SPACE_MD, right: SPACE_MD })
        .borderRadius(CARD_RADIUS)
        .backgroundColor(CARD_BG)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .padding({ left: SPACE_MD, right: SPACE_MD, top: SPACE_MD })
    .backgroundColor(BG_PAGE)
  }
}
