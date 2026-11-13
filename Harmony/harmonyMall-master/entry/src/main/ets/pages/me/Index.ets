import Title from '../component/Title'
@Component
export default struct Index{
  @State logged:string="登录"
  build() {
    Column(){
      Title({ title: '用户中心' })
      Image($r('app.media.denglu')).width(80).margin({top:100,bottom:20})
      Row({space:20}){
        Text(`${this.logged}`)
          .onClick(()=>{
            this.getUIContext().getRouter().pushUrl({url:'pages/me/Login'}).catch(() => {
              // TODO: Implement error handling.
            })
          })
        Text("点击注册")
          .onClick(()=>{
            this.getUIContext().getRouter().pushUrl({url:'pages/me/RegPage'}).catch(() => {
              // TODO: Implement error handling.
            })
          })
      }
      Row(){
        Column({space:20}){
          Row({space:20}){
            Image($r('app.media.shoucang')).width(20)
            Text("我的收藏").fontSize(15)
          }.width('90%')
          Divider()
          Row({space:20}){
            Image($r('app.media.shimingrenzheng')).width(20)
            Text("修改密码").fontSize(15)
          }.width('90%')
          Divider()
          Row({space:20}){
            Image($r('app.media.pingjia')).width(20)
            Text("修改信息").fontSize(15)
          }.width('90%')
          Divider()
          Row({space:20}){
            Image($r('app.media.daohangdizhi')).width(20)
            Text("收货地址").fontSize(15)
          }.width('90%')
          Divider()
          Row({space:20}){
            Image($r('app.media.kefu')).width(20)
            Text("联系客服").fontSize(15)
          }.width('90%')
        }
      }
      .margin({top:30})
    }
    .height('100%')

  }
}