import Title from '../component/Title';
import { AdvertisementData, AdvertisementDataList } from '../../model/SwipeModel';
import { GridData, gridDataList } from '../../model/GridModel';
import { Goods, listGoods } from '../../data/interface';

@Component
export struct Index {
  @State swiperList: AdvertisementData[] = [];
  @State gridList: GridData[] = [];
  @State productList: Goods[] = [];

  // 生命周期函数,自动执行，一般用来获取初始数据
  aboutToAppear(): void {
    this.swiperList = AdvertisementDataList;
    this.gridList = gridDataList;
    this.productList = listGoods;
  }

  build() {
    Scroll() {
      Column() {
        // 页面标题
        Title({ title: '首页', arrow: false })
        // 轮播图
        Swiper() {
          ForEach(this.swiperList, (item: AdvertisementData) => {
            Image(item.icon)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          }, (item: AdvertisementData) => JSON.stringify(item))
        }
        .width('100%')
        .height(200)
        .autoPlay(true)
        .interval(4000)
        .loop(true)
        // 宫格
        Grid() {
          ForEach(this.gridList, (item: GridData) => {
            GridItem() {
              Column({ space: 5 }) {
                Image(item.icon)
                  .width(60)
                  .height(60)
                Text(item.typeName)
                  .fontSize(14)
              }
            }
          }, (item: GridData) => JSON.stringify(item))
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(10)
        .margin({ top: 10 })
        .height(200)
        // 爆款推荐
        Row() {
          Text('爆款推荐')
        }
        .width('90%')
        List() {
          ForEach(this.productList, (item: Goods) => {
            ListItem() {
              Column() {
                Image($rawfile(item.icon))
                  .width(100)
                  .height(100)
                Text(item.goodsName)
              }
              .width('100%')
              .padding(10)
              .alignItems(HorizontalAlign.Center)
            }
          }, (item: Goods) => JSON.stringify(item))
        }
        .lanes(2)
        .height(this.productList.length * 75)
      }
    }
  }
}
