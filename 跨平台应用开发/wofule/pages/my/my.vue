<template>
	<view class="content">
		<view class="header">
			<image class="headicon" v-bind:src="userinfo.headicon" mode="aspectFill"></image>
			<text class="title">{{userinfo.username}}</text>
		</view>
		<view class="entry-wrap">
			<view class="entry">个人信息</view>
			<view class="entry">订单列表</view>
			<view class="entry">修改密码</view>
			<view class="entry">意见反馈</view>
		</view>
		<button class="button" type="primary" @click="logout">退出登录</button>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				title: '我服了',
				userinfo:{
					userid:"001",
					headicon:"/static/head_icon.png",
					username:"tom"
				}
			}
		},
		onShow() {
			var user = uni.getStorageSync('user');
			if(user){
				this.userinfo.username = user.username;
			}else{
				uni.reLaunch({
					url:'/pages/login/login'
				});
			}
		},
		methods: {
			logout(){
				uni.removeStorageSync('user');
				uni.reLaunch({
					url:'/pages/login/login'
				});
			}
		}
	}
</script>

<style>
	.content {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: flex-start;
	}

	.header {
		display: flex;
		align-items: center;
		width: 90%;
		margin-top: 50rpx;
		margin-bottom: 40rpx;
	}

	.headicon {
		width: 120rpx;
		height: 120rpx;
		margin-left: 60rpx;
		margin-right: 40rpx;
		border-radius: 50%;
	}
	
	.title {
		font-size: 36rpx;
	}
	
	.entry-wrap {
		width:90%;
		margin-top: 30rpx;
		margin-bottom: 30rpx;
		
	}
	
	.entry {
		height: 3em;
		line-height: 3em;
		text-align: left;
		padding-left: 80rpx;
		border-bottom: 1px solid #ccc;
		position: relative;
	}

	.entry::before {
		content: "";
		width: 50rpx;
		height: 50rpx;
		background-size: contain;
		position: absolute;
		left: 0rpx;
		top: 50%;
		margin-top: -25rpx;
	}

	.entry:nth-child(1)::before {
		background-image: url("/static/info.png");
	}

	.entry:nth-child(2)::before {
		background-image: url("/static/list.png");
	}

	.entry:nth-child(3)::before {
		background-image: url("/static/password.png");
	}

	.entry:nth-child(4)::before {
		background-image: url("/static/feedback.png");
	}
	
	.entry::after {
		content: "";
		width: 50rpx;
		height: 50rpx;
		background-image: url("/static/more.png");
		background-size: contain;
		position: absolute;
		right: 0rpx;
		top: 50%;
		margin-top: -25rpx;
	}
	
	.entry:first-child {
		border-top: 1px solid #ccc;
	}
	
	.button {
		width: 90%;
	}
</style>
