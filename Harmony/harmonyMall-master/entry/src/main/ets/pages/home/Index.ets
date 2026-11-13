import Title from "../component/Title"
import {AdvertisementData,AdvertisementDataList} from '../../model/SwipeModel'
import {GridData,gridDataList} from '../../model/GridModel'
import {ProductData,productDataList} from '../../model/ProductModel'


@Component
export struct Index{
  @State swiperList:AdvertisementData[]=[]
  @State gridList:GridData[]=[]
  @State productList:ProductData[]=[]
  // 生命周期函数,自动执行，一般用来获取初始数据
  aboutToAppear(): void {
    // 以后AdvertisementDataList是通过网络请求获取
    this.swiperList=AdvertisementDataList
    this.gridList=gridDataList
    this.productList=productDataList
  }
  build() {
    Scroll(){
      Column(){
        // 页面标题
        Title({title:'首页',arrow:false})
        // 轮播图
        Swiper(){
          ForEach(this.swiperList,(item:AdvertisementData)=>{
            Image(item.icon)
          })
        }
        .width('100%')
        .height(200)
        //   宫格
        Grid(){
          ForEach(this.gridList,(item:GridData,index:number)=>{
            GridItem(){
              Column({space:5}){
                Image(item.icon).width(60).height(60)
                Text(item.typeName)
              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(10)
        .margin({top:10})
        .height(200)
        Row(){
          Text("爆款推荐")
        }.width('90%')
        //   爆款推荐
        List(){
          ForEach(this.productList,(item:ProductData)=>{
            ListItem(){
              Column(){
                Image($rawfile(item.icon)).width(100).height(100)
                Text(item.goodsName)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
          })
        }
        // 列数
        .lanes(2)
      }
    }
  }
}