// 全局视觉令牌：颜色、圆角、间距、字号、阴影都从这里取，页面里不再手写色值。
// 主色是蓝色渐变，起色 PRIMARY_START、止色 PRIMARY_END，用到渐变的组件把两者一起写进 colors。

// 颜色
export const PRIMARY_START: string = '#2B7FF3'
export const PRIMARY_END: string = '#1698CE'
export const PRIMARY: string = '#1698CE'
export const DANGER: string = '#E64545'
export const TEXT_MAIN: string = '#1A1A1A'
export const TEXT_SECONDARY: string = '#6B6B6B'
export const TEXT_MUTED: string = '#9B9B9B'
export const BG_PAGE: string = '#F5F6F7'
export const CARD_BG: string = '#FFFFFF'
export const INPUT_BG: string = '#F2F3F5'
export const TAB_ACTIVE_BG: string = 'rgba(22,152,206,0.12)'

// 圆角
export const CARD_RADIUS: number = 16
export const CHIP_RADIUS: number = 14
export const IMAGE_RADIUS: number = 10

// 间距
export const SPACE_XS: number = 8
export const SPACE_SM: number = 12
export const SPACE_MD: number = 16
export const SPACE_LG: number = 24

// 字号
export const FONT_CAPTION: number = 12
export const FONT_BODY: number = 14
export const FONT_SUBTITLE: number = 16
export const FONT_TITLE: number = 20
export const FONT_DISPLAY: number = 26

// 阴影（卡片用，页面里配 .shadow({ radius, color, offsetX, offsetY })）
export const CARD_SHADOW_RADIUS: number = 12
export const CARD_SHADOW_COLOR: string = 'rgba(0,0,0,0.06)'
export const CARD_SHADOW_OFFSET_Y: number = 4

// 动效时长
export const MOTION_FAST: number = 150
export const MOTION_NORMAL: number = 250
