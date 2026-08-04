# 10 - Pinia 状态管理

Pinia 是 Vue3 官方推荐的状态管理库，替代 Vuex。

## 安装与配置

```bash
npm install pinia
```

```typescript
// main.ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)
app.use(createPinia())
app.mount('#app')
```

## 定义 Store

Pinia 支持两种定义风格：选项式（Options API）和组合式（Composition API）。

### 选项式 Store

```typescript
// stores/counter.ts
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', {
  state: () => ({
    count: 0,
    name: '计数器'
  }),
  getters: {
    doubleCount: (state) => state.count * 2,
    // 通过 this 访问其他 getter
    doublePlusOne(): number {
      return this.doubleCount + 1
    }
  },
  actions: {
    increment() {
      this.count++
    },
    async fetchAndSet() {
      const res = await fetch('/api/count')
      this.count = await res.json()
    }
  }
})
```

### 组合式 Store（推荐）

```typescript
// stores/counter.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCounterStore = defineStore('counter', () => {
  // state
  const count = ref(0)
  const name = ref('计数器')

  // getters
  const doubleCount = computed(() => count.value * 2)
  const doublePlusOne = computed(() => doubleCount.value + 1)

  // actions
  function increment() {
    count.value++
  }

  async function fetchAndSet() {
    const res = await fetch('/api/count')
    count.value = await res.json()
  }

  return { count, name, doubleCount, doublePlusOne, increment, fetchAndSet }
})
```

## 在组件中使用

```vue
<script setup>
import { useCounterStore } from '@/stores/counter'
import { storeToRefs } from 'pinia'

const store = useCounterStore()

// ❌ 解构会丢失响应性
const { count, doubleCount } = store

// ✅ 使用 storeToRefs 保持响应性
const { count, doubleCount, name } = storeToRefs(store)

// actions 可直接解构
const { increment, fetchAndSet } = store
</script>

<template>
  <p>{{ count }} × 2 = {{ doubleCount }}</p>
  <button @click="increment">+1</button>
  <button @click="store.increment">直接调用 action</button>
</template>
```

## State

### 修改 state

```typescript
const store = useCounterStore()

// 直接修改
store.count++

// 批量修改
store.$patch({
  count: store.count + 1,
  name: '新名字'
})

// 函数式 patch
store.$patch((state) => {
  state.count++
  state.name = '新名字'
})

// 重置为初始值
store.$reset()
```

### 监听 state

```typescript
const store = useCounterStore()

// 监听整个 store
store.$subscribe((mutation, state) => {
  console.log('mutated:', mutation.storeId, mutation.type)
  localStorage.setItem('counter', JSON.stringify(state))
})

// watch 单个属性
watch(() => store.count, (val) => {
  console.log('count changed:', val)
})
```

## Getters

```typescript
export const useUserStore = defineStore('user', {
  state: () => ({
    users: [
      { id: 1, name: 'Alice', active: true },
      { id: 2, name: 'Bob', active: false }
    ]
  }),
  getters: {
    // 箭头函数
    activeUsers: (state) => state.users.filter(u => u.active),

    // 函数形式 - 可传参
    getUserById: (state) => {
      return (id: number) => state.users.find(u => u.id === id)
    },

    // 使用其他 getter
    activeCount(): number {
      return this.activeUsers.length
    }
  }
})
```

## Actions

```typescript
export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(null)

  async function login(credentials: { email: string; password: string }) {
    const res = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
    const data = await res.json()
    user.value = data.user
    token.value = data.token
  }

  function logout() {
    user.value = null
    token.value = null
  }

  // 调用其他 store 的 action
  async function register(data: any) {
    const res = await fetch('/api/register', { method: 'POST', body: JSON.stringify(data) })
    const result = await res.json()

    // 调用其他 store
    const counterStore = useCounterStore()
    counterStore.count++

    return result
  }

  return { user, token, login, logout, register }
})
```

## State 持久化

手动实现 localStorage 持久化：

```typescript
// stores/counter.ts
export const useCounterStore = defineStore('counter', () => {
  // 从 localStorage 恢复
  const saved = localStorage.getItem('counter')
  const count = ref(saved ? JSON.parse(saved).count : 0)

  // 自动保存
  watch(count, (val) => {
    localStorage.setItem('counter', JSON.stringify({ count: val }))
  })

  return { count }
})
```

使用 pinia-plugin-persistedstate：

```bash
npm install pinia-plugin-persistedstate
```

```typescript
// main.ts
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)
```

```typescript
export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  return { count }
}, {
  persist: true  // 自动持久化
})
```

## 选项式 vs 组合式 Store

| 对比项 | 选项式 | 组合式 |
|--------|--------|--------|
| 语法 | 类似 Vuex | 类似 Composition API |
| 类型推导 | 自动 | 自动 |
| 灵活性 | 固定结构 | 灵活（可嵌套 watch） |
| 学习成本 | 低 | 需理解组合式 API |
| 推荐度 | 简单场景 | **通用推荐** |

## 最佳实践

- 每个 store 文件只导出一个 store
- 使用 `storeToRefs` 解构 state 和 getters
- actions 可直接解构，不会丢失上下文
- 组合式 store 中可以使用 `watch` 实现自动持久化
- 避免在 store 中引用组件实例
