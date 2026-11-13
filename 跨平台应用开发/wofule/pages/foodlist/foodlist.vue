<template>
	<view>
		<uni-list>
			<uni-list-item v-for="item in list"
				:thumb="'/static' + item.icon"
				:key="item.id" :title="item.name"></uni-list-item>
		</uni-list>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				list: [{
						id: 1,
						name: "烤鸭",
						type: "肉类",
						icon: "/images/1.png",
						description: "烤鸭是北京和南京的一道特色名菜,属于北京菜或金陵菜,该菜品以色泽红艳,肉质细嫩,味道醇厚,肥而不腻的特色,被誉为“天下美味”而驰名中外,其色泽略黄,柔软淡香,夹卷其他荤素食物食用,为宴席常用菜点,更是家常风味美食。",
						price: 88.5
					},
					{
						id: 2,
						name: "回锅肉",
						type: "肉类",
						icon: "/images/2.png",
						description: "回锅肉，是一种四川传统菜式中家常（味型）菜肴的代表菜肴之一，属于川菜系列。制作原料主要有猪后臀肉（二刀肉）、青椒、蒜苗等，口味独特，色泽红亮，肥而不腻。回锅肉起源四川农村地区。古代时期称作油爆锅，四川地区大部分家庭都会制作。所谓回锅，就是再次烹调的意思。",
						price: 12.5
					},
					{
						id: 3,
						name: "茄子",
						type: "蔬菜",
						icon: "/images/3.png",
						description: "油淋茄子以茄子、鸡蛋、肉末、粉丝等为食材制成的一道精美的平民美食。",
						price: 20.5
					},
					{
						id: 4,
						name: "宫保鸡丁",
						type: "肉类",
						icon: "/images/4.png",
						description: "宫保鸡丁选用鸡肉为主料，佐以花生米、辣椒等辅料烹制而成；红而不辣、辣而不猛、香辣味浓、肉质滑脆；其入口鲜辣，鸡肉的鲜嫩可以配合花生的香脆。",
						price: 34.5
					}
				]
			}
		},
		methods: {

		}
	}
</script>

<style>

</style>
