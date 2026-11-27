> uni-list-item提供了3个可扩展的插槽：`header`、`body`、`footer`
> - 当 `direction` 属性为 `row` 时表示水平排列，此时 `header` 表示列表的左边部分，`body` 表示列表的中间部分，`footer` 表示列表的右边部分
> - 当 `direction` 属性为 `column` 时表示垂直排列，此时 `header` 表示列表的上边部分，`body` 表示列表的中间部分，`footer` 表示列表的下边部分
> 开发者可以只用1个插槽，也可以3个一起使用。在插槽中可自主编写view标签，实现自己所需的效果。

	
**示例**

```html
<uni-list>
	<uni-list-item title="自定义右侧插槽" note="列表描述信息" link>
		<template slot="header">
			<image class="slot-image" src="/static/logo.png" mode="widthFix"></image>
		</template>
	</uni-list-item>
	<uni-list-item>
		<!-- 自定义 header -->
		<view slot="header" class="slot-box"><image class="slot-image" src="/static/logo.png" mode="widthFix"></image></view>
		<!-- 自定义 body -->
		<text slot="body" class="slot-box slot-text">自定义插槽</text>
		<!-- 自定义 footer-->
		<template slot="footer">
			<image class="slot-image" src="/static/logo.png" mode="widthFix"></image>
		</template>
	</uni-list-item>
</uni-list>
```





### ListItemChat Props

属性名			|类型		|默认值		|	说明																		
:-:				|:-:		|:-:		|	:-:	
title 			|String		|-			|	标题
note 			|String		|-			|	描述
clickable		|Boolean	|false		|	是否开启点击反馈
badgeText		|String		|-			|	数字角标内容，设置为 `dot` 将显示圆点
badgePositon 	|String		|right		|	角标位置
link			|String 	|navigateTo	|	是否展示右侧箭头并开启点击反馈，可选值见下表
clickable		|Boolean	|false		|	是否开启点击反馈
to				|String		|-			|	跳转页面地址，如填写此属性，click 会返回页面是否跳转成功	
time			|String 	|-			|	右侧时间显示
avatarCircle 	|Boolean 	|false		|	是否显示圆形头像
avatar			|String 	|-			|	头像地址，avatarCircle 不填时生效
avatarList 		|Array	 	|-			|	头像组，格式为 [{url:''}]

#### Link Options

属性名		|	说明
:-:			|	:-:
navigateTo 	| 	同 uni.navigateTo()
redirectTo 	|	同 uni.reLaunch()
reLaunch	|	同 uni.reLaunch()
switchTab  	|	同 uni.switchTab()

### ListItemChat Slots

名称	 	|	说明					
:-		|	:-						
default	|	自定义列表右侧内容（包括时间和角标显示）

### ListItemChat Events
事件称名			|	说明						|	返回参数			
:-:				|	:-:						|	:-:	
@click			|	点击 uniListChat 触发事件	|	{data:{}}	，如有 to 属性，会返回页面跳转信息	






## 基于uni-list扩展的页面模板

通过扩展插槽，可实现多种常见样式的列表

**新闻列表类**

1. 云端一体混合布局：[https://ext.dcloud.net.cn/plugin?id=2546](https://ext.dcloud.net.cn/plugin?id=2546)
2. 云端一体垂直布局，大图模式：[https://ext.dcloud.net.cn/plugin?id=2583](https://ext.dcloud.net.cn/plugin?id=2583)
3. 云端一体垂直布局，多行图文混排：[https://ext.dcloud.net.cn/plugin?id=2584](https://ext.dcloud.net.cn/plugin?id=2584)
4. 云端一体垂直布局，多图模式：[https://ext.dcloud.net.cn/plugin?id=2585](https://ext.dcloud.net.cn/plugin?id=2585)
5. 云端一体水平布局，左图右文：[https://ext.dcloud.net.cn/plugin?id=2586](https://ext.dcloud.net.cn/plugin?id=2586)
6. 云端一体水平布局，左文右图：[https://ext.dcloud.net.cn/plugin?id=2587](https://ext.dcloud.net.cn/plugin?id=2587)
7. 云端一体垂直布局，无图模式，主标题+副标题：[https://ext.dcloud.net.cn/plugin?id=2588](https://ext.dcloud.net.cn/plugin?id=2588)

**商品列表类**

1. 云端一体列表/宫格视图互切：[https://ext.dcloud.net.cn/plugin?id=2651](https://ext.dcloud.net.cn/plugin?id=2651)
2. 云端一体列表（宫格模式）：[https://ext.dcloud.net.cn/plugin?id=2671](https://ext.dcloud.net.cn/plugin?id=2671)
3. 云端一体列表（列表模式）：[https://ext.dcloud.net.cn/plugin?id=2672](https://ext.dcloud.net.cn/plugin?id=2672)

## 组件示例

点击查看：[https://hellouniapp.dcloud.net.cn/pages/extUI/list/list](https://hellouniapp.dcloud.net.cn/pages/extUI/list/list)