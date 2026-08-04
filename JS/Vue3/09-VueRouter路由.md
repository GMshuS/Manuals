# 09 - Vue Router 路由

Vue Router 4 是 Vue3 的官方路由库。

## 安装与配置

```bash
npm install vue-router@4
```

### 基本配置

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import About from '../views/About.vue'

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/about', name: 'About', component: About },
  {
    path: '/user',
    name: 'User',
    component: () => import('../views/User.vue')  // 懒加载
  }
]

const router = createRouter({
  history: createWebHistory(),  // HTML5 模式（需要服务端支持）
  routes
})

export default router
```

### 在 main.ts 中注册

```typescript
// main.ts
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.use(router)
app.mount('#app')
```

### 路由出口

```vue
<!-- App.vue -->
<template>
  <router-view />
</template>
```

## 路由模式

```typescript
// HTML5 History 模式（推荐）
createWebHistory()

// Hash 模式（无需服务端配置）
createWebHashHistory()

// Memory 模式（非浏览器环境）
createMemoryHistory()
```

## 动态路由

```typescript
const routes = [
  // 基础动态路由
  { path: '/user/:id', component: User },

  // 多个参数
  { path: '/post/:year/:month/:slug', component: Post },

  // 通配（匹配所有）
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: NotFound }
]
```

### 获取路由参数

```vue
<!-- User.vue -->
<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()
const userId = computed(() => route.params.id)
</script>

<template>
  <p>用户 ID: {{ userId }}</p>
</template>
```

### 监听参数变化

```vue
<script setup>
import { useRoute } from 'vue-router'
import { watch } from 'vue'

const route = useRoute()

watch(() => route.params.id, async (newId) => {
  // 同一组件内路由参数变化时重新获取数据
  const user = await fetch(`/api/users/${newId}`)
})
</script>
```

## 嵌套路由

```typescript
const routes = [
  {
    path: '/user',
    component: UserLayout,
    children: [
      { path: '', component: UserProfile },           // /user
      { path: 'profile', component: UserProfile },    // /user/profile
      { path: 'settings', component: UserSettings },  // /user/settings
      { path: ':id', component: UserDetail }          // /user/123
    ]
  }
]
```

```vue
<!-- UserLayout.vue -->
<template>
  <div class="user-layout">
    <nav>
      <router-link to="/user/profile">个人资料</router-link>
      <router-link to="/user/settings">设置</router-link>
    </nav>
    <router-view />  <!-- 嵌套路由出口 -->
  </div>
</template>
```

## 命名路由

```typescript
const routes = [
  {
    path: '/user/:id',
    name: 'UserDetail',   // 命名路由
    component: UserDetail
  }
]
```

```vue
<!-- 通过 name 导航 -->
<router-link :to="{ name: 'UserDetail', params: { id: 123 } }">
  用户详情
</router-link>
```

## 命名视图

在同一个路由下渲染多个组件。

```typescript
const routes = [
  {
    path: '/',
    components: {
      default: Home,
      sidebar: Sidebar,
      header: Header
    }
  }
]
```

```vue
<template>
  <router-view name="header" />
  <router-view name="sidebar" />
  <router-view />  <!-- 默认视图 -->
</template>
```

## 编程式导航

```vue
<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

// 字符串路径
router.push('/user/123')

// 对象
router.push({ path: '/user/123' })
router.push({ name: 'UserDetail', params: { id: 123 } })
router.push({ path: '/user', query: { page: 1, sort: 'desc' } })

// 替换当前历史（不产生新记录）
router.replace('/login')

// 后退
router.back()

// 前进
router.forward()

// 指定步数
router.go(-2)
</script>
```

### <router-link>

```vue
<template>
  <router-link to="/">首页</router-link>
  <router-link :to="{ name: 'About' }">关于</router-link>
  <router-link to="/user/123" replace>替换导航</router-link>

  <!-- 激活状态 -->
  <router-link to="/about" active-class="active">关于</router-link>
  <router-link to="/about" exact-active-class="exact-active">关于</router-link>
</template>
```

## 导航守卫

### 全局守卫

```typescript
// router/index.ts
const router = createRouter({ ... })

// 全局前置守卫
router.beforeEach(async (to, from) => {
  const isAuthenticated = localStorage.getItem('token')

  if (to.meta.requiresAuth && !isAuthenticated) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }
})

// 全局解析守卫（所有组件内守卫和异步路由组件解析后）
router.beforeResolve((to) => { /* ... */ })

// 全局后置钩子
router.afterEach((to, from, failure) => {
  if (failure) { /* 导航失败 */ }
  // 页面埋点等
})
```

### 路由独享守卫

```typescript
const routes = [
  {
    path: '/admin',
    component: Admin,
    beforeEnter: (to, from) => {
      if (!hasPermission('admin')) {
        return { name: 'Forbidden' }
      }
    }
  }
]
```

### 组件内守卫

```vue
<script setup>
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router'

// 离开当前路由前
onBeforeRouteLeave((to, from) => {
  const answer = window.confirm('有未保存的更改，确定离开？')
  if (!answer) return false
})

// 路由更新时（同一组件参数变化）
onBeforeRouteUpdate(async (to, from) => {
  await fetchUser(to.params.id)
})
</script>
```

## 路由元信息

```typescript
const routes = [
  {
    path: '/admin',
    meta: {
      requiresAuth: true,
      roles: ['admin'],
      title: '管理后台'
    },
    component: Admin
  }
]

// 在守卫中访问
router.beforeEach((to) => {
  document.title = to.meta.title || '默认标题'

  if (to.meta.requiresAuth && !isLoggedIn()) {
    return '/login'
  }
})
```

## 滚动行为

```typescript
const router = createRouter({
  history: createWebHistory(),
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition  // 回退/前进时恢复位置
    }
    if (to.hash) {
      return { el: to.hash }  // 滚动到锚点
    }
    return { top: 0 }  // 默认滚动到顶部
  }
})
```

## 路由懒加载

```typescript
const routes = [
  {
    path: '/dashboard',
    component: () => import('../views/Dashboard.vue')
  }
]
```

## useRouter vs useRoute

| | useRouter | useRoute |
|--|-----------|----------|
| 用途 | 执行导航操作 | 读取当前路由信息 |
| 常用方法 | push, replace, back, go, forward | params, query, meta, path, name, fullPath |
| 响应式 | 否 | 是（watch 可监听变化） |
