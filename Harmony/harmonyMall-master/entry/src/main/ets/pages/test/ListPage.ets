import {Goods,listGoods} from '../../data/interface'
@Entry
@Component
struct ListPage {
// @State goodsList:Goods[]=[]
//   20261029
  @State goodsList:Array<Goods>=listGoods
  // 1.刷新的状态变量
  @State isRefreshing:boolean=false
  // 构建侧滑的UI组件
  @Builder itemEnd(index:number){
    Row(){
      Image($r('app.media.delete_left'))
        .width(40)
        .height(40)
        .fillColor(Color.Red)
        .margin({left:20,right:20})
        .onClick(()=>{
          this.goodsList.splice(index,1)
        })
    }
    .backgroundColor(0xeeeeee)
  }
  build() {
    Column() {
      // $$双向绑定
      Refresh({refreshing:$$this.isRefreshing}){
        List({ space: 10 }) {
          ForEach(this.goodsList, (item: Goods, index: number) => {
            // 侧滑是绑定到列表元素上
            ListItem() {
              Row() {
                Image($rawfile(item.icon)).width(35)
                Text(item.goodsName)
                Text(`￥${item.goodsPrice}`)
              }
              .width('95%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            // 列表项侧滑功能
            .swipeAction({
              end: {
                builder: this.itemEnd(index)
              }
            })
          },
            (item:Goods,index:number)=>JSON.stringify(item))
            .onMove((from:number,to:number)=>{
            //   保持原来的元素
              let item=this.goodsList[from]
            //   删除需要移动的元素
              this.goodsList.splice(from,1)
            //   将保存的元素添加到目标位置
              this.goodsList.splice(to,0,item)
            })
        }
        .width('100%').height('100%')
        .alignListItem(ListItemAlign.Center)
      }
      // 当被刷新时
      .onRefreshing(()=>{
        setTimeout(()=>{
          this.goodsList.push(...this.goodsList)
          this.isRefreshing=false
        },1500)
      })
    }
    .height('100%')
    .width('100%')
  }
}