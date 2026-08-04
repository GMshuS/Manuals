# 03 - 组合式 API (Composition API)

Vue3 的组合式 API 是一组基于函数的 API，允许你按逻辑关注点组织代码，替代选项式 API 的 `data` / `methods` / `computed` 等选项。

## `<script setup>` 语法糖（推荐）

`<script setup>` 是组合式 API 的编译时语法糖，无需 `return`，代码更简洁。

```vue
<script setup>
import { ref, onMounted } from 'vue'

const count = ref(0)

function increment() {
  count.value++
}

onMounted(() => {
  console.log('组件已挂载')
})
</script>

<template>
  <button @click="increment">{{ count }}</button>
</template>
```

### 特性

| 特性 | 说明 |
|------|------|
| 顶层变量可直接在模板使用 | 无需 return |
| 自动暴露给模板 | 默认关闭，通过 `defineExpose` 手动暴露 |
| 支持顶层 await | 组件自动变为异步依赖 |
| 可导入的顶层绑定 | 不会被编译为局部变量 |

### defineExpose — 暴露属性和方法给父组件

```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
const reset = () => { count.value = 0 }

defineExpose({ count, reset })
</script>
```

## setup 函数（传统写法）

```vue
<script>
import { ref, onMounted } from 'vue'

export default {
  setup(props, context) {
    const count = ref(0)

    function increment() {
      count.value++
    }

    onMounted(() => {
      console.log('mounted')
    })

    // 必须 return
    return { count, increment }
  }
}
</script>
```

### setup 函数参数

```javascript
export default {
  setup(props, context) {
    // props    : 响应式，不含 defineProps 的校验
    // context.attrs    - 非 props 属性
    // context.slots    - 插槽
    // context.emit     - 触发事件
    // context.expose   - 暴露属性（替代 defineExpose）

    context.expose({ key: 'value' })
  }
}
```

## 组合式 vs 选项式 对比

### 选项式 API (Options API)

```vue
<script>
export default {
  data() { return { count: 0 } },
  computed: {
    double() { return this.count * 2 }
  },
  methods: {
    increment() { this.count++ }
  },
  watch: { count(val) { console.log(val) } },
  mounted() { console.log('mounted') }
}
</script>
```

### 组合式 API

```vue
<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const count = ref(0)
const double = computed(() => count.value * 2)

function increment() { count.value++ }

watch(count, (val) => { console.log(val) })

onMounted(() => { console.log('mounted') })
</script>
```

| 对比项 | 选项式 | 组合式 |
|--------|-------|--------|
| 代码组织 | 按选项类型 | 按逻辑关注点 |
| 逻辑复用 | mixins（问题多） | composables |
| TypeScript | `this.xxx` 类型推导困难 | 天然类型友好 |
| 学习曲线 | 较低 | 需理解响应式概念 |
| 适用场景 | 简单组件 | 所有场景 |

## Composables — 组合式函数

将组件逻辑提取到可复用的函数中。

```typescript
// useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initial = 0) {
  const count = ref(initial)
  const double = computed(() => count.value * 2)

  function increment() { count.value++ }
  function decrement() { count.value-- }
  function reset() { count.value = initial }

  return { count, double, increment, decrement, reset }
}
```

### 在组件中使用

```vue
<script setup>
import { useCounter } from './composables/useCounter'
import { useMouse } from './composables/useMouse'

const { count, double, increment } = useCounter(10)
const { x, y } = useMouse()
</script>

<template>
  <p>{{ count }} x 2 = {{ double }}</p>
  <button @click="increment">+</button>
  <p>鼠标位置: {{ x }}, {{ y }}</p>
</template>
```

### 常用 composables 示例

```typescript
// useMouse.ts — 追踪鼠标位置
import { ref, onMounted, onUnmounted } from 'vue'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)

  function update(e: MouseEvent) {
    x.value = e.pageX
    y.value = e.pageY
  }

  onMounted(() => window.addEventListener('mousemove', update))
  onUnmounted(() => window.removeEventListener('mousemove', update))

  return { x, y }
}
```

```typescript
// useLocalStorage.ts — 响应式 localStorage
import { ref, watch } from 'vue'

export function useLocalStorage<T>(key: string, defaultValue: T) {
  const data = ref<T>(JSON.parse(localStorage.getItem(key) || JSON.stringify(defaultValue)))

  watch(data, () => {
    localStorage.setItem(key, JSON.stringify(data.value))
  }, { deep: true })

  return data
}
```

### Composables 约定

- 函数名以 `use` 开头
- 入参如果有 ref，可使用 `unref()` 兼容普通值和 ref
- 返回值推荐使用 `ref` 而非 `reactive`，便于解构
- 副作用（事件监听、定时器）应在 `onUnmounted` 中清理

## defineComponent — 类型推导辅助

在 JS 中提供更好的 TS 类型推导（非必需，但推荐）。

```vue
<script lang="ts">
import { defineComponent, ref } from 'vue'

export default defineComponent({
  props: { msg: String },
  setup(props) {
    const count = ref(0)
    return { count }
  }
})
</script>
```

## 顶层 await

```vue
<script setup>
const res = await fetch('/api/data')
const data = await res.json()
</script>

<template>
  <pre>{{ data }}</pre>
</template>
```

注意：使用顶层 await 时，组件会成为异步依赖，需配合 `<Suspense>` 使用。
