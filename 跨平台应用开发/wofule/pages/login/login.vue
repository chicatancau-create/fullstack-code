<template>
	<view class="content">
		<image class="logo" src="/static/head_icon.png" mode="aspectFill"></image>
		<view class="form">
			<uni-forms ref="form" :model="user" :rules="rules">
				<uni-forms-item label="用户名" name="username">
					<uni-easyinput v-model="user.username" placeholder="请输入用户名" />
				</uni-forms-item>
				<uni-forms-item label="密码" name="password">
					<uni-easyinput type="password" v-model="user.password" placeholder="请输入密码"/>
				</uni-forms-item>
				<uni-forms-item label="" name="">
					<button type="primary" @click="login">登录</button>  <!-- 设置click事件方法 -->
					<button @click="toRegister">注册账号</button>
				</uni-forms-item>
			</uni-forms>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				user:{
					username:"tom",
					password:"123"
				},
				rules: {
					username: {
						rules: [{
							required: true,
							errorMessage: '请输入用户名'
						}]
					},
					password: {
						rules: [{
							required: true,
							errorMessage: '请输入密码'
						}]
					}
				}
			}
		},
		onLoad() {

		},
		methods: {
			login(){
				this.$refs.form.validate().then(res=>{
					uni.request({
						url:'http://localhost:8090/foodapp/user/login',
						method:'POST',
						data:this.user,
						success: res => {
							console.log(res.data);
							if(res.data.success == true){
								uni.setStorageSync('user', res.data.data);
								uni.showToast({
									title:'login success',
									icon:'none',
								});
								uni.switchTab({
									url:'/pages/my/my'
								});
							}else{
								uni.showToast({
									title:res.data.msg,
									icon:'error',
								});
							}
						},
						fail: () => {
							console.log('login fail');
						},
						complete: () => {
						}
					});
				}).catch(err=>{
					console.log(err);
				});
			},
			toRegister(){
				uni.navigateTo({
					url:'/pages/register/register'
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
		padding: 40rpx;
	}

	.logo {
		width: 200rpx;
		height: 200rpx;
		margin-bottom: 40rpx;
	}

	.form {
		width: 100%;
	}
</style>
