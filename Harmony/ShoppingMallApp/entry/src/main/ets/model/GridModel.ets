export interface GridData {
  id: number;
  typeName: string;
  icon: ResourceStr;
}

export const gridDataList: GridData[] = [
  {
    id: 1,
    typeName: '家用电器',
    icon: $rawfile('jiadian.png')
  },
  {
    id: 2,
    typeName: '个人护理',
    icon: $rawfile('gerenhuli.png')
  },
  {
    id: 3,
    typeName: '电子产品',
    icon: $rawfile('dianzichanpin.png')
  },
  {
    id: 4,
    typeName: '食品饮料',
    icon: $rawfile('shipinyinliao.png')
  },
  {
    id: 5,
    typeName: '服装服饰',
    icon: $rawfile('fuzhuangfushi.png')
  },
  {
    id: 6,
    typeName: '运动健身',
    icon: $rawfile('yundongjianshen.png')
  },
  {
    id: 7,
    typeName: '书籍杂志',
    icon: $rawfile('tushu.png')
  },
  {
    id: 8,
    typeName: '儿童玩具',
    icon: $rawfile('wanju.png')
  }
];
