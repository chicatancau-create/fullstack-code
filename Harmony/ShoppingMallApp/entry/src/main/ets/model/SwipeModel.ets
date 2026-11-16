export interface AdvertisementData {
  id: number;
  name: string;
  topic: string;
  icon: ResourceStr;
}

export const AdvertisementDataList: AdvertisementData[] = [
  {
    id: 1,
    name: '宏村',
    topic: '宏村古意',
    icon: $rawfile('01.jpeg')
  },
  {
    id: 2,
    name: '霞浦',
    topic: '霞浦风光',
    icon: $rawfile('02.jpeg')
  },
  {
    id: 3,
    name: '武功山',
    topic: '武功美景',
    icon: $rawfile('03.jpeg')
  },
  {
    id: 4,
    name: '千岛湖',
    topic: '千岛湖景',
    icon: $rawfile('04.jpeg')
  },
  {
    id: 5,
    name: '婺源',
    topic: '婺源生机',
    icon: $rawfile('05.jpeg')
  },
  {
    id: 6,
    name: '武汉',
    topic: '一朝花枝俏',
    icon: $rawfile('06.jpeg')
  }
];
