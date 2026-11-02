<template>
  <form class="habit-form" @submit.prevent="onSubmit">
    <h3 class="form-title">{{ isEdit ? '编辑习惯' : '新增习惯' }}</h3>

    <div class="field">
      <label class="field-label" for="habit-name">
        习惯名称
        <span class="char-count" :class="{ over: nameLength > 20 }">{{ nameLength }}/20</span>
      </label>
      <input
        id="habit-name"
        v-model="form.name"
        class="field-input"
        type="text"
        placeholder="例如：专注阅读（不超过 20 字）"
      />
      <p v-if="errors.name" class="field-error">{{ errors.name }}</p>
    </div>

    <div class="field">
      <label class="field-label" for="habit-target">每周目标天数（1–7）</label>
      <input
        id="habit-target"
        v-model.number="form.target"
        class="field-input"
        type="number"
        min="1"
        max="7"
        step="1"
      />
      <p v-if="errors.target" class="field-error">{{ errors.target }}</p>
    </div>

    <div class="field">
      <span class="field-label">颜色标签</span>
      <div class="swatches" role="radiogroup" aria-label="选择颜色标签">
        <button
          v-for="color in COLORS"
          :key="color"
          type="button"
          class="swatch"
          role="radio"
          :aria-checked="form.color === color"
          :class="{ selected: form.color === color }"
          :style="{ background: color }"
          :title="color"
          @click="form.color = color"
        ></button>
      </div>
      <p v-if="errors.color" class="field-error">{{ errors.color }}</p>
    </div>

    <div class="form-actions">
      <button class="btn-primary" type="submit">{{ isEdit ? '保存修改' : '添加习惯' }}</button>
      <button class="btn-plain" type="button" @click="emit('cancel')">取消</button>
    </div>
  </form>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'

const COLORS = ['#2f6b52', '#d97745', '#6874b8', '#b58a32', '#b65c68']

const props = defineProps({
  initial: { type: Object, default: null },
})

const emit = defineEmits(['submit', 'cancel'])

const form = reactive({ name: '', target: 1, color: COLORS[0] })
const errors = ref({})

const isEdit = computed(() => Boolean(props.initial))
const nameLength = computed(() => form.name.length)

function fillForm() {
  const source = props.initial
  form.name = source ? source.name : ''
  form.target = source ? source.target : 1
  form.color = source && COLORS.includes(source.color) ? source.color : COLORS[0]
  errors.value = {}
}

// initial 由父页切换（新增 / 编辑某个习惯 / 关闭）时同步重置表单，属于真实联动场景
watch(() => props.initial, fillForm, { immediate: true })

function validate() {
  const next = {}
  const name = form.name.trim()
  if (!name) next.name = '请输入习惯名称'
  else if (name.length > 20) next.name = '习惯名称不能超过 20 字'
  if (!Number.isInteger(form.target) || form.target < 1 || form.target > 7) {
    next.target = '每周目标天数必须是 1–7 的整数'
  }
  if (!COLORS.includes(form.color)) next.color = '请从色板中选择一个颜色标签'
  return next
}

function onSubmit() {
  const next = validate()
  errors.value = next
  if (Object.keys(next).length) return
  emit('submit', { name: form.name.trim(), target: form.target, color: form.color })
}
</script>

<style scoped>
.habit-form {
  display: grid;
  gap: 14px;
}
.form-title {
  margin: 0;
  font-size: 14.5px;
  color: var(--brand);
}
.form-title::before {
  content: '▍';
  color: var(--accent);
}
.field {
  display: grid;
  gap: 6px;
}
.field-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  color: var(--text);
}
.char-count {
  font-size: 11.5px;
  color: var(--muted);
}
.char-count.over {
  color: var(--danger);
  font-weight: 700;
}
.field-input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--line);
  border-radius: 8px;
  font: inherit;
  color: var(--text);
  background: #fff;
  box-sizing: border-box;
}
.field-input:focus {
  outline: 2px solid var(--accent);
  outline-offset: 1px;
}
.field-error {
  margin: 0;
  font-size: 12.5px;
  color: var(--danger);
}
.swatches {
  display: flex;
  gap: 10px;
}
.swatch {
  width: 30px;
  height: 30px;
  border: 2px solid transparent;
  border-radius: 10px;
  cursor: pointer;
  padding: 0;
}
.swatch.selected {
  border-color: var(--brand);
  box-shadow: 0 0 0 2px #fff inset;
}
.swatch:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
.form-actions {
  display: flex;
  gap: 10px;
}
.btn-primary {
  padding: 8px 18px;
  border: none;
  border-radius: 8px;
  background: var(--accent);
  color: #fff;
  font: inherit;
  cursor: pointer;
}
.btn-plain {
  padding: 8px 18px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fff;
  color: var(--muted);
  font: inherit;
  cursor: pointer;
}
</style>
