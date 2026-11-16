import { Goods, listGoods } from '../../data/interface';
import Title from '../component/Title';

@Entry
@Component
struct ListPage {
  @State goodsList: Array<Goods> = listGoods;
  // 刷新的状态变量
  @State isRefreshing: boolean = false;

  // 构建侧滑的删除按钮
  @Builder itemEnd(index: number) {
    Row() {
      Image($r('app.media.delete_left'))
        .width(40)
        .height(40)
        .fillColor(Color.Red)
        .margin({ left: 20, right: 20 })
        .onClick(() => {
          this.goodsList.splice(index, 1);
        })
    }
    .backgroundColor(0xF1F3F5)
  }

  build() {
    Column() {
      Title({ title: '商品列表', arrow: true })
      // $$双向绑定刷新状态
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 10 }) {
          ForEach(this.goodsList, (item: Goods, index: number) => {
            // 侧滑绑定到列表元素上
            ListItem() {
              Row({ space: 20 }) {
                Image($rawfile(item.icon))
                  .width(100)
                  .height(100)
                Column() {
                  Text(item.goodsName)
                    .fontSize(20)
                  Text(`价格${item.goodsPrice}元`)
                    .fontColor(Color.Red)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(10)
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(index)
                }
              }
            })
          }, (item: Goods, index: number) => JSON.stringify(item))
            .onMove((from: number, to: number) => {
              // 保持原来的元素
              let item = this.goodsList[from];
              // 删除需要移动的元素
              this.goodsList.splice(from, 1);
              // 将保存的元素添加到目标位置
              this.goodsList.splice(to, 0, item);
            })
        }
        .width('100%')
        .height('100%')
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Auto)
      }
      .layoutWeight(1)
      // 下拉刷新时恢复初始数据
      .onRefreshing(() => {
        setTimeout(() => {
          this.goodsList = [...listGoods];
          this.isRefreshing = false;
        }, 1500);
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xF1F3F5)
  }
}
