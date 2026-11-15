<template>
	<view class="container">
		<swiper :indicator-dots="true" :autoplay="true" :interval="3000" :duration="1000" :circular="true" style="height: 300rpx;">
			<swiper-item v-for="(item,index) in list" :key="index">
				<view class="swiper-item"><image :src="'../../static' + item.icon" mode="aspectFill" style="width:100%; height:100%;"></image></view>
			</swiper-item>
		</swiper>
		<view class="home-title">功能列表</view>
		<swiper :indicator-dots="true" :circular="true" style="height: 240rpx;">
			<swiper-item>
				<uni-grid :column="5" :show-border="true">
					<uni-grid-item v-for="(item,index) in typelist" :key="index">
						<view style="display: flex; flex-direction: column; align-items: center; padding-top: 10rpx;">
							<image :src="'../../static' + item.icon" style="width: 60rpx; height: 60rpx;" mode="aspectFill"></image>
							<view style="font-size: 24rpx;">{{item.typename}}</view>
						</view>
					</uni-grid-item>
				</uni-grid>
			</swiper-item>
			<swiper-item>
				<uni-grid :column="5" :show-border="true">
					<uni-grid-item v-for="(item,index) in typelist2" :key="index">
						<view style="display: flex; flex-direction: column; align-items: center; padding-top: 10rpx;">
							<image :src="'../../static' + item.icon" style="width: 60rpx; height: 60rpx;" mode="aspectFill"></image>
							<view style="font-size: 24rpx;">{{item.typename}}</view>
						</view>
					</uni-grid-item>
				</uni-grid>
			</swiper-item>
		</swiper>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				list: [{
						id: 1,
						icon: "/images/1.jpg"
					},
					{
						id: 2,
						icon: "/images/2.jpg"
					},
					{
						id: 3,
						icon: "/images/3.jpg"
					},
					{
						id: 4,
						icon: "/images/4.jpg"
					}
				],
				typelist: [{
						id: 1,
						typename: "新闻",
						icon: "/images/news.png"
					},
					{
						id: 2,
						typename: "公告",
						icon: "/images/notice.png"
					},
					{
						id: 3,
						typename: "同学",
						icon: "/images/classmate.png"
					},
					{
						id: 4,
						typename: "电话",
						icon: "/images/phone.png"
					},
					{
						id: 5,
						typename: "留言",
						icon: "/images/message.png"
					}
				],
				typelist2: [{
						id: 6,
						typename: "图书馆",
						icon: "/images/library.png"
					},
					{
						id: 7,
						typename: "成绩",
						icon: "/images/score.png"
					},
					{
						id: 8,
						typename: "课表",
						icon: "/images/calendar.png"
					},
					{
						id: 9,
						typename: "校园卡",
						icon: "/images/card.png"
					},
					{
						id: 10,
						typename: "设置",
						icon: "/images/setting.png"
					}
				]
			}
		},
		methods: {

		}
	}
</script>

<style>
	.container {
		padding: 20rpx;
	}

	.swiper-item {
		height: 300rpx;
	}

	.home-title {
		font-size: 28rpx;
		margin-top: 20rpx;
		margin-bottom: 10rpx;
	}
</style>
