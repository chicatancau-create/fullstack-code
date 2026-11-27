		<uni-list-chat title="uni-app" avatar="https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png" note="您收到一条新的消息" time="2020-02-02 20:20" badge-text="12" :badge-style="{backgroundColor:'#FF80AB'}"></uni-list-chat>
		<!-- 头像显示圆点 -->
		<uni-list-chat title="uni-app" avatar="https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png" note="您收到一条新的消息" time="2020-02-02 20:20" badge-positon="left" badge-text="dot"></uni-list-chat>
		<!-- 头像显示角标 -->
		<uni-list-chat title="uni-app" avatar="https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png" note="您收到一条新的消息" time="2020-02-02 20:20" badge-positon="left" badge-text="99"></uni-list-chat>
		<!-- 显示多头像 -->
		<uni-list-chat title="uni-app" :avatar-list="avatarList" note="您收到一条新的消息" time="2020-02-02 20:20" badge-positon="left" badge-text="dot"></uni-list-chat>
		<!-- 自定义右侧内容 -->
		<uni-list-chat title="uni-app" :avatar-list="avatarList" note="您收到一条新的消息" time="2020-02-02 20:20" badge-positon="left" badge-text="dot">
			<view class="chat-custom-right">
				<text class="chat-custom-text">刚刚</text>
				<!-- 需要使用 uni-icons 请自行引入 -->
				<uni-icons type="star-filled" color="#999" size="18"></uni-icons>
			</view>
		</uni-list-chat>
	</uni-list>
</uni-list>

```

```javascript

export default {
	components: {},
	data() {
		return {
			avatarList: [{
				url: 'https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png'
			}, {
				url: 'https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png'
			}, {
				url: 'https://vkceyugu.cdn.bspapp.com/VKCEYUGU-dc-site/460d46d0-4fcc-11eb-8ff1-d5dcf8779628.png'
			}]
		}
	}
}

```


```css

.chat-custom-right {
	flex: 1;
	/* #ifndef APP-NVUE */
	display: flex;
	/* #endif */
	flex-direction: column;
	justify-content: space-between;
	align-items: flex-end;
}

.chat-custom-text {
	font-size: 12px;
	color: #999;
}

```

## API

### List Props

属性名			|类型		|默认值		|	说明																									
:-:				|:-:		|:-:		|	:-:	
border			|Boolean	|true		|	是否显示边框


### ListItem Props

属性名			|类型		|默认值		|	说明																					
:-:				|:-:		|:-:		|	:-:	
title			|String		|-			|	标题
note			|String		|-			|	描述
ellipsis		|Number		|0			|	title 是否溢出隐藏，可选值，0:默认;  1:显示一行;	2:显示两行;【nvue 暂不支持】
thumb			|String		|-			|	左侧缩略图，若thumb有值，则不会显示扩展图标
thumbSize		|String 	|medium 	|	略缩图尺寸，可选值，lg:大图;  medium:一般;	sm:小图;
showBadge		|Boolean	|false		|	是否显示数字角标	
badgeText		|String		|-			|	数字角标内容
badgeType		|String		|-			|	数字角标类型，参考[uni-icons](https://ext.dcloud.net.cn/plugin?id=21)	
badgeStyle  |Object   |-      | 数字角标样式，使用uni-badge的custom-style参数
rightText		|String		|-			|	右侧文字内容
disabled		|Boolean	|false		|	是否禁用	
showArrow 		|Boolean	|true		|	是否显示箭头图标			
link			|String 	|navigateTo	|	新页面跳转方式，可选值见下表
to				|String		|-			|	新页面跳转地址，如填写此属性，click 会返回页面是否跳转成功			
clickable		|Boolean	|false		|	是否开启点击反馈
showSwitch	    |Boolean	|false		|	是否显示Switch																			
switchChecked	|Boolean	|false		|	Switch是否被选中																			
showExtraIcon   |Boolean	|false		|	左侧是否显示扩展图标																		
extraIcon		|Object		|-			|	扩展图标参数，格式为 ``{color: '#4cd964',size: '22',type: 'spinner'}``，参考 [uni-icons](https://ext.dcloud.net.cn/plugin?id=28)	
direction		| String	|row		|	排版方向，可选值，row:水平排列;  column:垂直排列; 3个插槽是水平排还是垂直排，也受此属性控制


#### Link Options

属性名				|	说明
:-:					|	:-:
navigateTo 	| 	同 uni.navigateTo()
redirectTo 	|	同 uni.reLaunch()
reLaunch		|	同 uni.reLaunch()
switchTab  	|	同 uni.switchTab()

### ListItem Events

事件称名			|说明									|返回参数			
:-:				|:-:									|:-:				
click			|点击 uniListItem 触发事件，需开启点击反馈	|-					
switchChange	|点击切换 Switch 时触发，需显示 switch		|e={value:checked}	



### ListItem Slots

名称	 	|	说明					
:-:		|	:-:						
header	|	左/上内容插槽，可完全自定义默认显示
body	|	中间内容插槽，可完全自定义中间内容				
footer	|	右/下内容插槽，可完全自定义右侧内容		


> **通过插槽扩展**
> 需要注意的是当使用插槽时，内置样式将会失效，只保留排版样式，此时的样式需要开发者自己实现
> 如果	`uni-list-item` 组件内置属性样式无法满足需求，可以使用插槽来自定义uni-list-item里的内容。
