<template>
  <svg :width="size" :height="size * 0.78" viewBox="0 0 128 100" xmlns="http://www.w3.org/2000/svg">
    <path d="M0,0 L32,0 L64,56 L96,0 L128,0 L64,100 Z" fill="#41b883" />
    <path d="M32,0 L52,0 L64,21 L76,0 L96,0 L64,56 Z" fill="#35495e" />
  </svg>
</template>

<script setup>
defineProps({ size: { type: Number, default: 80 } })
</script>
