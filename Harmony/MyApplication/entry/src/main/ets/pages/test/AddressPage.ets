import { Address, listAddress } from '../../data/interface'

@Entry
@Component
struct AddressPage {
  @State addressList: Address[] = listAddress.slice()
  @State isRefreshing: boolean = false

  // 任务三：侧滑后露出的删除按钮
  @Builder itemEnd(index: number) {
    Image($r('app.media.delete_left'))
      .width(40)
      .height(40)
      .fillColor(Color.Red)
      .margin({ left: 20, right: 20 })
      .onClick(() => {
        this.addressList.splice(index, 1)
      })
  }

  build() {
    Column() {
      // 任务四：Refresh 包住 List，$$ 把转圈状态双向绑给 isRefreshing
      Refresh({ refreshing: $$this.isRefreshing }) {
        List() {
          ForEach(this.addressList, (item: Address, index: number) => {
            // 任务二：一条地址 = 姓名 / 地址 / 电话 三行
            ListItem() {
              Column() {
                Text(`姓名：${item.name}`).fontSize(16)
                Text(`地址：${item.address}`).fontSize(14)
                Text(`电话：${item.phone}`).fontSize(14)
              }
              .padding(12)
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .swipeAction({
              end: {
                builder: this.itemEnd(index)
              }
            })
          }, (item: Address) => JSON.stringify(item))
            // 任务五：长按列表项拖到新位置
            .onMove((from: number, to: number) => {
              const item: Address = this.addressList[from]
              this.addressList.splice(from, 1)
              this.addressList.splice(to, 0, item)
            })
        }
        .width('100%')
        .height('100%')
        .alignListItem(ListItemAlign.Center)
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.addressList = listAddress.slice()
          this.isRefreshing = false
        }, 1500)
      })
    }
    .width('100%')
    .height('100%')
  }
}
