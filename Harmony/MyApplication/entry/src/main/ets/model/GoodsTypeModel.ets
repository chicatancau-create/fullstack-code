// 6.5 规定的宫格数据模型
export interface GoodsTypeData {
  id: number
  typeName: string
  icon: ResourceStr
  categoryId: number
}

export const GoodsTypeList: GoodsTypeData[] = [
  { id: 1, typeName: '电子', icon: $rawfile('dianzichanpin.png'), categoryId: 1 },
  { id: 2, typeName: '服装', icon: $rawfile('fuzhuangfushi.png'), categoryId: 2 },
  { id: 3, typeName: '书籍', icon: $rawfile('tushu.png'), categoryId: 3 },
  { id: 4, typeName: '家居', icon: $rawfile('jiadian.png'), categoryId: 4 },
  { id: 5, typeName: '美妆', icon: $rawfile('gerenhuli.png'), categoryId: 5 },
  { id: 6, typeName: '运动', icon: $rawfile('yundongjianshen.png'), categoryId: 6 },
  { id: 7, typeName: '玩具', icon: $rawfile('wanju.png'), categoryId: 7 },
  { id: 8, typeName: '食品', icon: $rawfile('shipinyinliao.png'), categoryId: 8 }
]
