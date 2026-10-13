<template>
  <h1>商品管理</h1>
  <table>
    <thead>
      <tr>
        <th class="add-goods" title="点击新增一个商品" @click="addGoods">#</th>
        <th>商品名称</th>
        <th>价格</th>
        <th>标签</th>
        <th>操作</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="(goods, index) in goodsList" :key="goods.id">
        <td>{{ index + 1 }}</td>
        <td>{{ goods.name }}</td>
        <td>¥{{ goods.price }}</td>
        <td class="tags">
          <!-- 输入框出现时靠 v-focus 自动获取焦点 -->
          <input
            v-if="editingId === goods.id"
            v-model="newTag"
            v-focus
            @keyup.enter="addTag(goods)"
            @blur="addTag(goods)"
          />
          <button v-else class="add" @click="showInput(goods)">+Tag</button>
          <span v-for="tag in goods.tags" :key="tag" class="tag">{{ tag }}</span>
        </td>
        <td>{{ goods.tags }}</td>
        <td>
          <button class="del" @click="removeGoods(index)">删除</button>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { ref } from 'vue'

//私有自定义指令:元素一挂载就自动获取焦点
const vFocus = {
  mounted: (el) => el.focus(),
}

const goodsList = ref([
  { id: 1, name: '夏季专柜同款女鞋', price: 298, tags: ['舒适', '透气'] },
  { id: 2, name: '冬季保暖女士休闲雪地靴 舒适加绒防水短靴 防滑棉鞋', price: 89, tags: ['保暖', '防滑'] },
  { id: 3, name: '秋冬新款女士毛衣 套头宽松针织衫 简约上衣', price: 199, tags: ['秋冬', '毛衣'] },
  { id: 4, name: '2023春秋装新款大码女装 衬衫 上衣', price: 19, tags: ['雪纺衫', '打底'] },
  { id: 5, name: '长款长袖圆领女士毛衣 2022秋装新款假两件连衣裙', price: 178, tags: ['圆领', '连衣裙'] },
])

const editingId = ref(null)
const newTag = ref('')

const showInput = (goods) => {
  editingId.value = goods.id
  newTag.value = ''
}
const addTag = (goods) => {
  const text = newTag.value.trim()
  if (text && !goods.tags.includes(text)) goods.tags.push(text)
  editingId.value = null
  newTag.value = ''
}
const removeGoods = (index) => {
  goodsList.value.splice(index, 1)
}

let id = goodsList.value.length
//点表头的 # 新增一条空商品
const addGoods = () => {
  goodsList.value.push({ id: ++id, name: '未命名商品', price: 0, tags: [] })
}
</script>

<style scoped>
h1 {
  font-size: 32px;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th,
td {
  padding: 10px 12px;
  border: 1px solid #ccc;
  text-align: left;
}
thead th {
  background: #f2f2f2;
}
.add-goods {
  cursor: pointer;
  user-select: none;
}
.add-goods:hover {
  color: #0d6efd;
}
tbody tr:nth-child(even) {
  background: #fafafa;
}
.add {
  padding: 2px 12px;
  border: 1px solid #0d6efd;
  border-radius: 999px;
  background: none;
  color: #0d6efd;
  cursor: pointer;
}
.tags input {
  width: 90px;
  padding: 2px 6px;
}
.tag {
  margin-left: 6px;
  padding: 2px 10px;
  border: 1px solid #333;
  border-radius: 4px;
}
.del {
  padding: 2px 10px;
  border: 1px solid #dc3545;
  border-radius: 4px;
  background: none;
  color: #dc3545;
  cursor: pointer;
}
</style>
