<template>
  <h3 class="title">用户管理</h3>
  <table>
    <thead>
      <tr>
        <th>编号</th>
        <th>姓名</th>
        <th>等级</th>
        <th>操作</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="user in users" :key="user.id">
        <td>{{ user.id }}</td>
        <td>{{ user.name }}</td>
        <td>{{ user.level }}</td>
        <td>
          <RouterLink :to="`/home/users/${user.id}`">详情</RouterLink>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
const users = [
  { id: 1, name: '小明', level: '一级客户' },
  { id: 2, name: '小红', level: '二级客户' },
  { id: 3, name: '小兰', level: '三级客户' },
  { id: 4, name: '小芳', level: '四级客户' },
]
</script>

<style scoped>
.title {
  margin: 20px 0;
  font-size: 22px;
  text-align: center;
}
table {
  margin: 0 auto;
  border-collapse: collapse;
}
th,
td {
  width: 130px;
  padding: 8px;
  border: 1px solid #333;
  text-align: center;
}
th {
  background: #f2f2f2;
}
td a {
  color: #333;
  text-decoration: none;
}
</style>
