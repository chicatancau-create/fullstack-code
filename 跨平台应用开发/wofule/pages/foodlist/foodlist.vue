<template>
	<view>
		<uni-list>
			<uni-list-item v-for="item in list"
				:thumb="'/static' + item.icon"
				:key="item.id"
				:title="item.name"
				:note="item.note"
				thumbSize="lg"
				:showBadge="true"
				:badgeText="item.num"
				badgeType="error"
				:showArrow="false"></uni-list-item>
		</uni-list>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				list: [{
						id: 1,
						name: "张三",
						icon: "/hamburger.jpg",
						note: "信息工程学院",
						num: "4"
					},
					{
						id: 2,
						name: "李四",
						icon: "/uni-logo.png",
						note: "信息工程学院",
						num: "2"
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
