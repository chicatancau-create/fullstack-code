import { Contact, contacts } from '../../data/interface'
import Title from '../component/Title'

@Entry
@Component
struct ContactPage {
  @State contactsList: Contact[] = contacts.slice()

  // 侧滑后露出的删除按钮
  @Builder itemEnd(index: number) {
    Image($r('app.media.delete_left'))
      .width(40)
      .height(40)
      .fillColor(Color.Red)
      .margin({ left: 20, right: 20 })
      .onClick(() => {
        this.contactsList.splice(index, 1)
      })
  }

  build() {
    Column() {
      Title({ title: '通讯录', arrow: true })
      List({ space: 10 }) {
        ForEach(this.contactsList, (item: Contact, index: number) => {
          ListItem() {
            Row({ space: 7 }) {
              // 圆形头像：取姓名第一个字
              Column() {
                Text(item.name.substring(0, 1))
              }
              .width(50)
              .height(50)
              .borderRadius(25)
              .backgroundColor('#E8F1FD')
              .justifyContent(FlexAlign.Center)

              Text(item.name)
                .layoutWeight(2)

              Column({ space: 2 }) {
                Text(`电话：${item.phone}`).fontSize(13)
                Text(`邮箱：${item.email}`).fontSize(13)
                Text(`公司：${item.company}`).fontSize(13)
                Text(`职位：${item.position}`).fontSize(13)
                Text(`部门：${item.department}`).fontSize(13)
              }
              .layoutWeight(5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(10)
          }
          .swipeAction({
            end: {
              builder: this.itemEnd(index)
            }
          })
        }, (item: Contact) => item.phone)
          // 长按拖拽换序
          .onMove((from: number, to: number) => {
            const item: Contact = this.contactsList[from]
            this.contactsList.splice(from, 1)
            this.contactsList.splice(to, 0, item)
          })
      }
      .width('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
