export interface Goods{
  id:number,
  goodsName:string,
  goodsContent:string,
  goodsQuantity:number,
  icon:string,
  goodsPrice:number
}
export const listGoods:Goods[]=[
  {
    "id": 1,
    "goodsName": "Huawei/华为 P30",
    "goodsContent": "华为P30，是华为公司旗下一款手机。手机搭载海思Kirin 980处理器，屏幕为6.1英寸，分辨率2340*1080像素。 摄像头最大30倍数码变焦。玻璃机身，直板，6+128G内存，机身颜色：亮黑色，珠光贝母，天空之境，赤茶橘，极光色。出厂系统内核：Android 9.0",
    "icon": "01.png",
    "goodsQuantity": 3,
    "goodsPrice": 4288
  },
  {
    "id": 2,
    "goodsName": "Xiaomi/小米 Redmi K20",
    "goodsContent": "Redmi K20 Pro搭载高通骁龙855处理器。后置三摄，采用索尼4800万主摄，800万人像镜头，1300万防畸变超广角，智能识别场景；前置2000万弹出相机，大广角全景合影；手持超级夜景，960帧慢动作等功能。机身容量有64GB、128GB、256GB三种。华为P30，是华为公司旗下一款手机。手机搭载海思Kirin 980处理器，屏幕为6.1英寸，分辨率2340*1080像素。 摄像头最大30倍数码变焦。玻璃机身，直板，6+128G内存，机身颜色：亮黑色，珠光贝母，天空之境，赤茶橘，极光色。出厂统内核：Android 9.0",
    "icon": "02.png",
    "goodsQuantity": 3,
    "goodsPrice": 2799
  },
  {
    "id": 3,
    "goodsName": "Huawei/华为 Mate 20 ",
    "goodsContent": "Huawei/华为 Mate 20 全面屏超大广角徕卡三镜头麒麟980人工智能芯片手机         \r\r\n",
    "icon": "03.png",
    "goodsQuantity": 3,
    "goodsPrice": 3299
  },
  {
    "id": 4,
    "goodsName": "Huawei/华为 nova 4",
    "goodsContent": "【6+128G直降100】Huawei/华为 nova 4 自拍极点全面屏超广角三摄正品智能易烊",
    "icon": "04.png",
    "goodsQuantity": 3,
    "goodsPrice": 2599
  }
]
export interface Contact {
  id: number;
  name: string;
  phone: string;
  email: string;
  company: string;
  position: string;
  department: string;
}

export const contacts: Contact[] = [
  { id: 1, name: "张伟", phone: "13800138001", email: "zhangwei@example.com", company: "华信科技", position: "技术总监", department: "研发部" },
  { id: 2, name: "李娜", phone: "13900139002", email: "lina@example.com", company: "华信科技", position: "产品经理", department: "产品部" },
  { id: 3, name: "王强", phone: "13700137003", email: "wangqiang@example.com", company: "远大集团", position: "销售经理", department: "销售部" },
  { id: 4, name: "刘洋", phone: "13600136004", email: "liuyang@example.com", company: "远大集团", position: "财务主管", department: "财务部" },
  { id: 5, name: "陈静", phone: "13500135005", email: "chenjing@example.com", company: "蓝海传媒", position: "市场专员", department: "市场部" },
  { id: 6, name: "杨帆", phone: "13400134006", email: "yangfan@example.com", company: "蓝海传媒", position: "创意总监", department: "设计部" },
  { id: 7, name: "赵敏", phone: "13300133007", email: "zhaomin@example.com", company: "中恒建筑", position: "项目经理", department: "工程部" },
  { id: 8, name: "黄磊", phone: "13200132008", email: "huanglei@example.com", company: "中恒建筑", position: "安全员", department: "工程部" },
  { id: 9, name: "周涛", phone: "13100131009", email: "zhoutao@example.com", company: "星辰教育", position: "教研组长", department: "教学部" },
  { id: 10, name: "吴婷", phone: "13000130010", email: "wuting@example.com", company: "星辰教育", position: "课程顾问", department: "咨询部" },
  { id: 11, name: "徐明", phone: "18900189011", email: "xuming@example.com", company: "恒通物流", position: "运营经理", department: "运营部" },
  { id: 12, name: "孙丽", phone: "18800188012", email: "sunli@example.com", company: "恒通物流", position: "客服主管", department: "客服部" },
  { id: 13, name: "马超", phone: "18700187013", email: "machao@example.com", company: "锐达电子", position: "硬件工程师", department: "研发部" },
  { id: 14, name: "朱琳", phone: "18600186014", email: "zhulin@example.com", company: "锐达电子", position: "测试工程师", department: "质量部" },
  { id: 15, name: "胡军", phone: "18500185015", email: "hujun@example.com", company: "天成金融", position: "风控经理", department: "风控部" },
  { id: 16, name: "郭雪", phone: "18400184016", email: "guoxue@example.com", company: "天成金融", position: "客户经理", department: "业务部" },
  { id: 17, name: "林峰", phone: "18300183017", email: "linfeng@example.com", company: "绿源环保", position: "环境工程师", department: "技术部" },
  { id: 18, name: "何芳", phone: "18200182018", email: "hefang@example.com", company: "绿源环保", position: "行政专员", department: "行政部" },
  { id: 19, name: "高鹏", phone: "18100181019", email: "gaopeng@example.com", company: "云智网络", position: "后端开发", department: "技术部" },
  { id: 20, name: "罗霞", phone: "18000180020", email: "luoxia@example.com", company: "云智网络", position: "UI设计师", department: "设计部" },
];
