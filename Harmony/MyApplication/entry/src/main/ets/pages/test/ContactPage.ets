import { Contact, contacts } from '../../data/interface'
import Title from '../component/Title'
import {
  BG_PAGE,
  CARD_BG,
  CARD_RADIUS,
  CARD_SHADOW_COLOR,
  CARD_SHADOW_OFFSET_Y,
  CARD_SHADOW_RADIUS,
  DANGER,
  FONT_CAPTION,
  FONT_SUBTITLE,
  IMAGE_RADIUS,
  MOTION_FAST,
  PRIMARY_TINT,
  SPACE_MD,
  TEXT_MAIN,
  TEXT_MUTED
} from '../../common/UiTokens'

@Entry
@Component
struct ContactPage {
  @State contactsList: Contact[] = contacts.slice()

  // 删除前先弹确认框
  private confirmDelete(item: Contact): void {
    this.getUIContext().showAlertDialog({
      title: '删除联系人',
      message: `确定删除${item.name}吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: DANGER,
        action: () => {
          const index: number = this.contactsList.indexOf(item)
          if (index >= 0) {
            this.contactsList.splice(index, 1)
          }
        }
      }
    })
  }

  // 侧滑后露出的删除按钮，危险红底
  @Builder itemEnd(item: Contact) {
    Column() {
      Image($r('app.media.delete_left'))
        .width(22)
        .height(22)
        .fillColor('#FFFFFF')
    }
    .width(56)
    .height(64)
    .borderRadius(IMAGE_RADIUS)
    .backgroundColor(DANGER)
    .justifyContent(FlexAlign.Center)
    .margin({ left: SPACE_MD })
    .stateStyles({
      pressed: {
        .opacity(0.7)
      },
      normal: {
        .opacity(1)
      }
    })
    .animation({ duration: MOTION_FAST, curve: Curve.EaseOut })
    .onClick(() => {
      this.confirmDelete(item)
    })
  }

  build() {
    Column() {
      Title({ title: '通讯录', isShow: true })
      List({ space: 10 }) {
        ForEach(this.contactsList, (item: Contact) => {
          ListItem() {
            Row({ space: SPACE_MD }) {
              // 圆形头像：取姓名第一个字，衬主色浅底
              Column() {
                Text(item.name.substring(0, 1))
                  .fontSize(FONT_SUBTITLE)
                  .fontColor(TEXT_MAIN)
              }
              .width(50)
              .height(50)
              .borderRadius(25)
              .backgroundColor(PRIMARY_TINT)
              .justifyContent(FlexAlign.Center)

              Text(item.name)
                .fontSize(FONT_SUBTITLE)
                .fontColor(TEXT_MAIN)
                .layoutWeight(2)

              Column({ space: 2 }) {
                Text(`电话：${item.phone}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MAIN)
                Text(`邮箱：${item.email}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MUTED)
                Text(`公司：${item.company}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MUTED)
                Text(`职位：${item.position}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MUTED)
                Text(`部门：${item.department}`)
                  .fontSize(FONT_CAPTION)
                  .fontColor(TEXT_MUTED)
              }
              .layoutWeight(5)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(SPACE_MD)
            .alignItems(VerticalAlign.Center)
          }
          .borderRadius(CARD_RADIUS)
          .backgroundColor(CARD_BG)
          .shadow({
            radius: CARD_SHADOW_RADIUS,
            color: CARD_SHADOW_COLOR,
            offsetX: 0,
            offsetY: CARD_SHADOW_OFFSET_Y
          })
          .stateStyles({
            pressed: {
              .opacity(0.85)
            },
            normal: {
              .opacity(1)
            }
          })
          .animation({ duration: MOTION_FAST, curve: Curve.EaseOut })
          .swipeAction({
            end: {
              builder: this.itemEnd(item)
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
      .padding({ left: SPACE_MD, right: SPACE_MD })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
