|uni-list|[列表](https://ext.dcloud.net.cn/plugin?name=uni-list)|
|uni-load-more|[加载更多](https://ext.dcloud.net.cn/plugin?name=uni-load-more)|
|uni-nav-bar|[自定义导航栏](https://ext.dcloud.net.cn/plugin?name=uni-nav-bar)|
|uni-notice-bar|[通告栏](https://ext.dcloud.net.cn/plugin?name=uni-notice-bar)|
|uni-number-box|[数字输入框](https://ext.dcloud.net.cn/plugin?name=uni-number-box)|
|uni-pagination|[分页器](https://ext.dcloud.net.cn/plugin?name=uni-pagination)|
|uni-popup|[弹出层](https://ext.dcloud.net.cn/plugin?name=uni-popup)|
|uni-rate|[评分](https://ext.dcloud.net.cn/plugin?name=uni-rate)|
|uni-row|[布局-行](https://ext.dcloud.net.cn/plugin?name=uni-row)|
|uni-search-bar|[搜索栏](https://ext.dcloud.net.cn/plugin?name=uni-search-bar)|
|uni-segmented-control|[分段器](https://ext.dcloud.net.cn/plugin?name=uni-segmented-control)|
|uni-steps|[步骤条](https://ext.dcloud.net.cn/plugin?name=uni-steps)|
|uni-swipe-action|[滑动操作](https://ext.dcloud.net.cn/plugin?name=uni-swipe-action)|
|uni-swiper-dot|[轮播图指示点](https://ext.dcloud.net.cn/plugin?name=uni-swiper-dot)|
|uni-table|[表格](https://ext.dcloud.net.cn/plugin?name=uni-table)|
|uni-tag|[标签](https://ext.dcloud.net.cn/plugin?name=uni-tag)|
|uni-title|[章节标题](https://ext.dcloud.net.cn/plugin?name=uni-title)|
|uni-transition|[过渡动画](https://ext.dcloud.net.cn/plugin?name=uni-transition)|


使用 `uni_modules` 方式安装组件库，可以直接通过插件市场导入，通过右键菜单快速更新组件，不需要引用、注册，直接在页面中使用 `uni-ui` 组件。[点击安装 uni-ui 组件库](https://ext.dcloud.net.cn/plugin?id=55)

**注意：下载最新的组件目前仅支持 uni_modules ,非 uni_modules 版本最高支持到组件的1.2.10版本**

如不能升级到 `uni_modules` 版本，可以使用 `uni_modules` 安装好对应组件，将组件拷贝到对应目录。

例如需更新 `uni-list`和`uni-badge` ,将 `uni_modules>uni-list>components`和`uni_modules>uni-badege>components`下所有目录拷贝到如下目录即可：


**目录示例**

```json
┌─components              组件目录
│  ├─uni-list             list 列表目录
│  │  └─uni-list.vue      list 组件文件
│  ├─uni-list-item        list-item 列表目录
│  │  └─uni-list-item.vue list 组件文件
│  ├─uni-badge         	  badge 角标目录
│  │  └─uni-badge.vue     badge 组件文件
│  └─ //....              更多组件文件
├─pages                   业务页面文件存放的目录
│  ├─index
│  │  └─index.vue         index示例页面
├─main.js                 Vue初始化入口文件
├─App.vue                 应用配置，用来配置App全局样式以及监听 应用生命周期
├─manifest.json           配置应用名称、appid、logo、版本等打包信息，详见
└─pages.json              配置页

```

### 通过  `uni_modules` 导入全部组件
如果想一次把所有uni-ui组件导入到项目中，只需要导入一个 `uni-ui` 组件即可 [点击去导入](https://ext.dcloud.net.cn/plugin?id=55)。

如果没有自动导入其他组件，可以在 uni-ui 组件目录上右键选择 `安装三方插件依赖` 即可。



### npm安装 
在 `vue-cli` 项目中可以使用 `npm` 安装 `uni-ui` 库 ，或者直接在 `HBuilderX` 项目中使用 `npm` 。

> **注意**
> cli 项目默认是不编译 `node_modules` 下的组件的，导致条件编译等功能失效 ，导致组件异常
> 需要在根目录创建 `vue.config.js` 文件 ，增加 `@dcloudio/uni-ui` 包的编译即可正常
> ```javascript
> // vue.config.js
> module.exports = {
> 		transpileDependencies:['@dcloudio/uni-ui']
> }
> ```



**准备 sass**

`vue-cli` 项目请先安装 sass 及 sass-loader，如在 HBuliderX 中使用，可跳过此步。

- 安装 sass
```
 npm i sass -D   或   yarn add sass -D  
```

- 安装 sass-loader
```
npm i sass-loader@10.1.1 -D   或   yarn add sass-loader@10.1.1 -D
```

> 如果 `node` 版本小于 16 ，sass-loader 请使用低于 @11.0.0 的版本，[sass-loader@11.0.0 不支持 vue@2.6.12 ](https://stackoverflow.com/questions/66082397/typeerror-this-getoptions-is-not-a-function)
> 如果 `node` 版本大于 16 ， `sass-loader` 建议使用 `v8.x` 版本

**安装 uni-ui**

```
npm i @dcloudio/uni-ui   或   yarn add @dcloudio/uni-ui
```



**配置easycom**

使用 `npm` 安装好 `uni-ui` 之后，需要配置 `easycom` 规则，让 `npm` 安装的组件支持  `easycom`

打开项目根目录下的 `pages.json` 并添加 `easycom` 节点：

```javascript
// pages.json
{
	"easycom": {
		"autoscan": true,
		"custom": {
			// uni-ui 规则如下配置
			"^uni-(.*)": "@dcloudio/uni-ui/lib/uni-$1/uni-$1.vue"
		}
	},
	
	// 其他内容
	pages:[
		// ...
	]
}

```

在 ``template`` 中使用组件： 

```html
<uni-badge text="1"></uni-badge>
<uni-badge text="2" type="success" @click="bindClick"></uni-badge>
<uni-badge text="3" type="primary" :inverted="true"></uni-badge>
```

 **注意**
 - uni-ui 现在只推荐使用 `easycom` ，如自己引用组件，可能会出现组件找不到的问题
