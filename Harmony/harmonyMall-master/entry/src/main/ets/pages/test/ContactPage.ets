import { Contact, contacts } from '../../data/interface'
import Title from '../component/Title'

@Entry
@Component
struct ContactPage {
  @State contactsList: Contact[] = contacts
  @State refreshing: boolean = false

  @Builder
  itemEnd(index: number) {
    Image($r('app.media.delete_left'))
      .width(40)
      .height(40)
      .margin({ right: 40 })
      .fillColor(Color.Red)
      .onClick(() => {
        // this.messages为列表数据源，可根据实际场景构造。点击后从数据源删除指定数据项。
        this.contactsList.splice(index, 1);
      })
  }

  build() {
    Column() {
      Title({ title: "通讯录", arrow: true })
        List({ space: 10 }) {
          ForEach(this.contactsList, (item: Contact, index: number) => {
            ListItem() {
              Row({ space: 7 }) {
                Column({}) {
                  Text(item.name.split("")[0])
                }
                .layoutWeight(1.5)
                .width(50)
                .height(50)
                .borderRadius('50%')
                .backgroundColor(0xe8f1fd)
                .justifyContent(FlexAlign.Center)

                Text(item.name).layoutWeight(1.5)
                Column() {
                  Text(`P: ${item.phone}`)
                  Text(`E: ${item.email}`)
                  Text(`C: ${item.company}`)
                }.alignItems(HorizontalAlign.Start)
                .layoutWeight(7)
              }
              .width('100%')
            }
            .swipeAction({ end: { builder: this.itemEnd(index) } })
          },(item: Contact, index: number): string => item.phone)
            .onMove((from:number,to:number)=>{
              let item=this.contactsList[from]
              this.contactsList.splice(from,1)
              this.contactsList.splice(to,0,item)
            })

        }
        .height('100%')
        .width('100%')
        .alignListItem(ListItemAlign.Center)
    }
    .height('100%')
    .width('100%')
  }
}