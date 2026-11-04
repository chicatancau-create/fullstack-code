<template>
	<view class="page">
		<image class="ph" src="/static/no-image.png" mode="widthFix"></image>
		<view class="cry">😢</view>
		<view class="tip">同学列表还没图，先哭一下</view>
	</view>
</template>

<script>
</script>

<style>
	.page {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 40rpx 30rpx;
	}

	.ph {
		width: 100%;
		border: 1px solid #cdcdcd;
		border-radius: 8rpx;
	}

	.cry {
		margin-top: 20rpx;
		font-size: 80rpx;
		line-height: 1;
	}

	.tip {
		margin-top: 10rpx;
		font-size: 26rpx;
		color: #999999;
	}
</style>
