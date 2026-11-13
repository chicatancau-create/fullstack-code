@Component
export default struct Title{
  @State title:string=""
  @State arrow:boolean=false
  build() {
    Stack(){
      Row(){
        // 显示标题
        Text(this.title)
          .fontSize(20)
          .fontWeight(700)
      }
      // 判断是否有箭头
      if(this.arrow){
        Row(){
          Image($r('app.media.jiantouzuo'))
            .width(20).height(20)
            .onClick(()=>{
              this.getUIContext().getRouter().back()
            })
        }
        .width('100%')
        .padding({left:20})
      }
    }
    .margin({bottom:10})
  }
}