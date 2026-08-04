# 12 - TypeScript 集成

Vue3 对 TypeScript 有**一等支持**，组合式 API 天然具有优秀的类型推导能力。

## 项目搭建

```bash
npm create vite@latest my-app -- --template vue-ts
```

## 类型化 Props

### 运行时声明 + 类型推导

```vue
<script setup lang="ts">
const props = defineProps({
  title: { type: String, required: true },
  count: { type: Number, default: 0 },
  items: { type: Array as PropType<string[]>, default: () => [] },
  callback: { type: Function as PropType<(id: number) => void>, default: null }
})
</script>
```

### 纯类型声明（推荐，3.3+）

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
  items?: string[]
  callback?: (id: number) => void
  status?: 'active' | 'inactive'
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
  items: () => [],
  status: 'active'
})
</script>
```

### 解构 props 保持响应式（3.5+）

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
}

// Vue 3.5+ 支持解构 props 并保持响应性
const { title, count = 0 } = defineProps<Props>()

watchEffect(() => {
  console.log(title, count)  // 响应式
})
</script>
```

## 类型化 Emits

```vue
<script setup lang="ts">
// 运行时声明
const emit = defineEmits<{
  'update': [id: number]
  'delete': [id: number]
  'change': [value: string]
}>()

// 使用带参数名（推荐）
const emit = defineEmits<{
  update: [id: number]
  delete: [id: number]
  change: [value: string]
}>()

emit('update', 1)      // ✅ 正确
emit('update', '1')    // ❌ 类型错误
</script>
```

## 类型化 Ref

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

// 自动推导
const count = ref(0)           // Ref<number>
const name = ref('')           // Ref<string>
const isDone = ref(false)      // Ref<boolean>

// 显式指定
const data = ref<string[]>(['a', 'b'])
const user = ref<{ id: number; name: string } | null>(null)

// 模板 ref
const inputRef = ref<HTMLInputElement | null>(null)
const divRef = ref<HTMLElement | null>(null)

// computed
const double = computed<number>(() => count.value * 2)
</script>
```

## 类型化模板 Ref

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import ChildComp from './ChildComp.vue'

// DOM 元素
const inputRef = ref<HTMLInputElement | null>(null)

onMounted(() => {
  inputRef.value?.focus()       // ✅
})

// 子组件实例
const childRef = ref<InstanceType<typeof ChildComp> | null>(null)

onMounted(() => {
  childRef.value?.exposedMethod()  // ✅
})
</script>

<template>
  <input ref="inputRef" />
  <ChildComp ref="childRef" />
</template>
```

```vue
<!-- ChildComp.vue -->
<script setup lang="ts">
function exposedMethod() {
  console.log('exposed')
}

defineExpose({ exposedMethod })
</script>
```

## 类型化 Provide / Inject

```typescript
// types/injection-keys.ts
import type { InjectionKey, Ref } from 'vue'

export const themeKey = Symbol() as InjectionKey<Ref<'light' | 'dark'>>
export const userKey = Symbol() as InjectionKey<{
  id: number
  name: string
  role: 'admin' | 'user'
}>
```

```vue
<!-- Provider.vue -->
<script setup lang="ts">
import { ref, provide } from 'vue'
import { themeKey, userKey } from './types/injection-keys'

const theme = ref<'light' | 'dark'>('light')
provide(themeKey, theme)
provide(userKey, { id: 1, name: 'Alice', role: 'admin' })
</script>
```

```vue
<!-- Injector.vue -->
<script setup lang="ts">
import { inject } from 'vue'
import { themeKey, userKey } from './types/injection-keys'

const theme = inject(themeKey)   // Ref<'light' | 'dark'> | undefined
const user = inject(userKey)     // { id: number; name: string; role: 'admin' | 'user' } | undefined

// 带默认值
const locale = inject('locale', 'zh-CN')  // string
</script>
```

### 使用 InjectionKey 的另一种方式（3.3+）

```typescript
// 直接使用泛型
import { type InjectionKey } from 'vue'

export const MY_KEY = 'my-key' as InjectionKey<string>
```

## 泛型组件

```vue
<!-- List.vue -->
<script setup lang="ts" generic="T extends { id: string | number }">
interface Props {
  items: T[]
  keyProp?: keyof T
}

const props = withDefaults(defineProps<Props>(), {
  keyProp: 'id' as keyof T
})
</script>

<template>
  <ul>
    <li v-for="item in items" :key="item.id">
      <slot :item="item" />
    </li>
  </ul>
</template>
```

### 使用泛型组件

```vue
<script setup lang="ts">
interface User {
  id: number
  name: string
  email: string
}

const users = ref<User[]>([
  { id: 1, name: 'Alice', email: 'alice@example.com' }
])
</script>

<template>
  <List :items="users" v-slot="{ item }">
    <span>{{ item.name }} - {{ item.email }}</span>
  </List>

  <!-- 类型推导：item 自动推断为 User 类型 -->
</template>
```

### 多泛型参数

```vue
<script setup lang="ts" generic="T, U extends Record<string, any>">
interface Props {
  data: T
  config: U
}

defineProps<Props>()
</script>
```

## 类型化 v-model

```vue
<!-- InputWrapper.vue -->
<script setup lang="ts">
const model = defineModel<string>({ required: true })

// 多个 v-model
const search = defineModel<string>('search', { required: true })
const filter = defineModel<string>('filter')
</script>

<template>
  <input :value="model" @input="model = ($event.target as HTMLInputElement).value" />
</template>
```

## 类型化 Event Handler

```vue
<script setup lang="ts">
function handleClick(event: MouseEvent) {
  // event.target 类型为 EventTarget | null
  const target = event.target as HTMLElement
}

function handleInput(event: Event) {
  const value = (event.target as HTMLInputElement).value
}

function handleChange(value: string) {
  // 自定义事件的类型
}
</script>

<template>
  <button @click="handleClick">点击</button>
  <input @input="handleInput" />
  <MyComponent @change="handleChange" />
</template>
```

## 扩展全局类型

```typescript
// types/global.d.ts
import 'vue'
import 'vue-router'
import 'pinia'

// 扩展全局属性
declare module 'vue' {
  interface ComponentCustomProperties {
    $t: (key: string) => string
    $format: (date: Date) => string
  }
}

// 扩展路由元信息
declare module 'vue-router' {
  interface RouteMeta {
    title?: string
    requiresAuth?: boolean
    roles?: string[]
  }
}

// 扩展 Pinia
declare module 'pinia' {
  export interface PiniaCustomProperties {
    $resetAll: () => void
  }
}

export {}
```

## 类型断言与安全

```typescript
// 模板 ref — 确定非空时用断言
const el = ref<HTMLElement>(null!)
onMounted(() => {
  el.value.focus()  // 无需可选链
})

// 非空断言
const user = ref<IUser | null>(null)
user.value!.name  // 确定不为 null 时使用
```

## tsconfig.json 推荐配置

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "jsx": "preserve",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "noEmit": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.vue"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```
