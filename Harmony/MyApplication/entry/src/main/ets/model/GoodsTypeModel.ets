// 6.5 规定的宫格数据模型
export interface GoodsTypeData {
  id: number
  typeName: string
  icon: ResourceStr
  categoryId: number
}

// 名称与图标按 5.4/6.5 课件规定；categoryId 是服务端 product_categories 的 id，
// 两边口径不同（课件宫格叫「家用电器」，服务端叫「家居」），这里按含义对齐
export const GoodsTypeList: GoodsTypeData[] = [
  { id: 1, typeName: '家用电器', icon: $rawfile('jiadian.png'), categoryId: 4 },
  { id: 2, typeName: '个人护理', icon: $rawfile('gerenhuli.png'), categoryId: 5 },
  { id: 3, typeName: '电子产品', icon: $rawfile('dianzichanpin.png'), categoryId: 1 },
  { id: 4, typeName: '食品饮料', icon: $rawfile('shipinyinliao.png'), categoryId: 8 },
  { id: 5, typeName: '服装服饰', icon: $rawfile('fuzhuangfushi.png'), categoryId: 2 },
  { id: 6, typeName: '运动健身', icon: $rawfile('yundongjianshen.png'), categoryId: 6 },
  { id: 7, typeName: '书籍杂志', icon: $rawfile('tushu.png'), categoryId: 3 },
  { id: 8, typeName: '儿童玩具', icon: $rawfile('wanju.png'), categoryId: 7 }
]
