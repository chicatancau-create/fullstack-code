<template>
	<view class="content">
		<view class="form">
			<uni-forms ref="form" :model="user" :rules="rules">
				<uni-forms-item label="用户名" name="username">
					<uni-easyinput v-model="user.username" placeholder="请输入用户名" />
				</uni-forms-item>
				<uni-forms-item label="密码" name="password">
					<uni-easyinput v-model="user.password" placeholder="请输入密码" />
				</uni-forms-item>
				<uni-forms-item label="学院" name="college">
					<picker mode="selector" :range="colleges" @change="collegeChange">
						<view :style="user.college==''?'color:#999':''">{{user.college==''?'请选择学院':user.college}}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="专业" name="major">
					<picker mode="selector" :range="majors" @change="majorChange">
						<view :style="user.major==''?'color:#999':''">{{user.major==''?'请选择专业':user.major}}</view>
					</picker>
				</uni-forms-item>
				<uni-forms-item label="电话" name="phone">
					<uni-easyinput v-model="user.phone" placeholder="请输入电话" />
				</uni-forms-item>
				<uni-forms-item label="姓名" name="name">
					<uni-easyinput v-model="user.name" placeholder="请输入姓名" />
				</uni-forms-item>
				<uni-forms-item label="邮箱" name="email">
					<uni-easyinput v-model="user.email" placeholder="请输入邮箱" />
				</uni-forms-item>
				<uni-forms-item label="" name="">
					<button type="primary" @click="register">注册</button>
					<button @click="toLogin">去登录</button>
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
					username:'zhagnsan',
					password:'123',
					college:'',
					major:'',
					phone:'13800138000',
					name:'张三',
					email:'demo@example.com'
				},
				colleges:['信息工程学院','机械工程学院','经济管理学院','外国语学院'],
				majors:['软件工程','计算机科学与技术','物联网工程','大数据技术'],
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
					},
					college: {
						rules: [{
							required: true,
							errorMessage: '请选择学院'
						}]
					},
					major: {
						rules: [{
							required: true,
							errorMessage: '请选择专业'
						}]
					},
					phone: {
						rules: [{
							required: true,
							errorMessage: '请输入电话'
						}, {
							pattern: /^1[3-9]\d{9}$/,
							errorMessage: '请输入正确的电话'
						}]
					},
					name: {
						rules: [{
							required: true,
							errorMessage: '请输入姓名'
						}]
					},
					email: {
						rules: [{
							required: true,
							errorMessage: '请输入邮箱'
						}, {
							pattern: /^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/,
							errorMessage: '请输入正确的邮箱'
						}]
					}
				}
			}
		},
		onLoad() {

		},
		methods: {
			collegeChange(e){
				this.user.college = this.colleges[e.detail.value]
			},
			majorChange(e){
				this.user.major = this.majors[e.detail.value]
			},
			register(){
				this.$refs.form.validate().then(res=>{
					uni.request({
						url:'http://localhost:8090/foodapp/user/register',
						method:'POST',
						data:this.user,
						success: res => {
							console.log(res.data);
							if(res.data.success == true){
								uni.showToast({
									title:'注册成功',
									icon:'none',
								});
								uni.navigateTo({
									url:'/pages/login/login'
								});
							}else{
								uni.showToast({
									title:res.data.msg,
									icon:'error',
								});
							}
						},
						fail: () => {
							console.log('register fail');
						},
						complete: () => {
						}
					});
				}).catch(err=>{
					console.log(err);
				});
			},
			toLogin(){
				uni.navigateTo({
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
		padding: 40rpx;
	}

	.form {
		width: 100%;
	}
</style>
