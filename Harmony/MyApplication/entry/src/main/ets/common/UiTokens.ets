// 全局视觉令牌：颜色和圆角、间距、字号都从这里取，页面里不再手写色值。
// 只有压在深色底上的半透明白衬色例外，alpha 各页不同，直接写在页面里。
// 主色只有一个 PRIMARY，标题条、价格条、选中态都用它。

// 颜色
export const PRIMARY: string = '#1698CE'
export const DANGER: string = '#E64545'
export const TEXT_MAIN: string = '#1A1A1A'
export const TEXT_SECONDARY: string = '#6B6B6B'
export const TEXT_MUTED: string = '#9B9B9B'
export const BG_PAGE: string = '#F5F6F7'
export const CARD_BG: string = '#FFFFFF'
export const INPUT_BG: string = '#F2F3F5'
// 商品图的浅底，图没加载满时不至于露白边
export const IMAGE_BG: string = '#F7F8FA'
export const TAB_ACTIVE_BG: string = 'rgba(22,152,206,0.12)'
// 主色底上的半透明白块，用来衬住首页用户区与搜索框
export const GLASS_BG: string = 'rgba(255,255,255,0.18)'
// 主色的浅底块，用来衬住宫格图标
export const PRIMARY_TINT: string = '#EAF3FB'
export const TEXT_ON_PRIMARY: string = '#FFFFFF'
// 输入框默认描边
export const BORDER_LIGHT: string = '#E5E7EA'

// 圆角
export const CARD_RADIUS: number = 16
export const CHIP_RADIUS: number = 14
export const IMAGE_RADIUS: number = 10

// 间距
export const SPACE_XS: number = 8
export const SPACE_SM: number = 12
export const SPACE_MD: number = 16

// 字号
export const FONT_CAPTION: number = 12
export const FONT_BODY: number = 14
export const FONT_SUBTITLE: number = 16
export const FONT_PRICE: number = 18
export const FONT_TITLE: number = 20
export const FONT_DISPLAY: number = 26


