@Entry
@Component
struct GridPage {
  @State message: string = 'Hello World';

  build() {
  Column(){
    Text(this.message).fontSize(50)
      .onClick(()=>{
        this.getUIContext().showAlertDialog({
          title:"消息框",
          message:"111",
          confirm:{
            value:'确定',
            action:()=>{
              console.info("wobufu")
            }
          },
          cancel:()=>{
            console.info("wofule")
          }
        })
      })
    Text("菜单")
      .onClick(()=>{
        this.getUIContext().getPromptAction().showActionMenu({
          title:"菜单标题",
          buttons:[
            {text:"菜单1",color:"#666666"},
            {text:"菜单2",color:"#ff007dff"}
          ]
        })
      .then(res=>{
        if(res.index===0){
          console.info("你选择了菜单1")
        }
        if(res.index===1){
          console.info("你选择了菜单2")
        }
      })
      .catch(()=>{

      })
      })
    }
    .width('100%')
  }
}
