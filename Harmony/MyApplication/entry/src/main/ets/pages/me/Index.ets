import Title from '../component/Title'
@Component
export default struct Index{
  @StorageLink('loginUser') loginUser: string = ''
  build() {
    Column({space:12}){
      Title({title:"个人中心"})
      if(this.loginUser === ''){
        Text("登录")
          //响应事件
          .onClick(()=>{
            //this.getUIContext()获取当前的上下文
            this.getUIContext().getRouter().pushUrl({url:"pages/me/Login"})
          })
        Text("注册")
        //响应事件
          .onClick(()=>{
            //this.getUIContext()获取当前的上下文
            this.getUIContext().getRouter().pushUrl({url:"pages/me/Reg"})
          })
      }else{
        Text(`已登录：${this.loginUser}`)
        Text("退出登录")
          .onClick(()=>{
            this.loginUser = ''
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
