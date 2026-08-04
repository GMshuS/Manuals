# Vue3 语法使用教程

> 本系列教程全面介绍 Vue3 核心语法与生态，基于组合式 API（Composition API） + `<script setup>` 风格编写。

## 教程目录

### 🏗️ 基础入门

| 章节 | 内容 |
|------|------|
| [01-基础与环境搭建.md](./01-基础与环境搭建.md) | Vue3 简介、Vite + create-vue 项目搭建、createApp、模板语法、SFC 结构 |
| [02-响应式基础.md](./02-响应式基础.md) | ref、reactive、toRef、toRefs、shallowRef、readonly |
| [03-组合式API.md](./03-组合式API.md) | setup 函数、`<script setup>` 语法糖、defineComponent、composables |
| [04-模板指令详解.md](./04-模板指令详解.md) | v-bind/v-if/v-show/v-for/v-on/v-model/v-html 等指令 |

### ⚙️ 核心机制

| 章节 | 内容 |
|------|------|
| [05-计算属性与侦听器.md](./05-计算属性与侦听器.md) | computed、watch、watchEffect、三者对比 |
| [06-组件基础.md](./06-组件基础.md) | defineProps、defineEmits、slots、组件注册、递归组件 |
| [07-组件进阶.md](./07-组件进阶.md) | provide/inject、动态组件、异步组件、keep-alive、模板 ref |
| [08-生命周期.md](./08-生命周期.md) | 组合式生命周期钩子详解、错误捕获 |

### 🚀 生态与进阶

| 章节 | 内容 |
|------|------|
| [09-VueRouter路由.md](./09-VueRouter路由.md) | 路由配置、动态路由、嵌套路由、导航守卫、路由元信息 |
| [10-Pinia状态管理.md](./10-Pinia状态管理.md) | store 定义、state/getters/actions、组合式风格 store |
| [11-进阶特性.md](./11-进阶特性.md) | Teleport、Suspense、自定义指令、插件、过渡动画、渲染函数 |
| [12-TypeScript集成.md](./12-TypeScript集成.md) | 类型化 props/emits、模板 ref 类型、泛型组件、类型扩展 |

---

## 推荐学习路径

### 初学者

1. **[01-基础与环境搭建.md](./01-基础与环境搭建.md)** - 搭建项目，理解 SFC 和模板语法
2. **[02-响应式基础.md](./02-响应式基础.md)** - 掌握 Vue3 响应式核心
3. **[03-组合式API.md](./03-组合式API.md)** - 理解组合式 API 的写法
4. **[04-模板指令详解.md](./04-模板指令详解.md)** - 熟悉模板中所有指令的用法
5. **[05-计算属性与侦听器.md](./05-计算属性与侦听器.md)** - 学习派生状态和副作用
6. **[06-组件基础.md](./06-组件基础.md)** - 组件通信基础（props/emits/slots）

### 进阶开发者

1. **[07-组件进阶.md](./07-组件进阶.md)** - 依赖注入、动态组件、异步加载
2. **[08-生命周期.md](./08-生命周期.md)** - 生命周期钩子的使用场景
3. **[09-VueRouter路由.md](./09-VueRouter路由.md)** - 单页应用路由方案
4. **[10-Pinia状态管理.md](./10-Pinia状态管理.md)** - 全局状态管理
5. **[11-进阶特性.md](./11-进阶特性.md)** - 高级渲染能力与扩展机制
6. **[12-TypeScript集成.md](./12-TypeScript集成.md)** - TypeScript 类型安全

---

## 代码示例说明

- 示例默认使用 **Vue 3.4+** 和 `<script setup>` 语法
- 完整组件示例包含 `<template>`、`<script setup>`、`<style>` 三部分
- 非完整示例仅展示核心逻辑代码片段
- 建议配合 [Vue3 官方文档](https://cn.vuejs.org/guide/introduction.html) 阅读

---

## 附录

### 版本兼容性

| 特性 | 最低版本 |
|------|---------|
| `<script setup>` | 3.0 |
| `defineModel` | 3.4 |
| `toRef` / `toRefs` | 3.0 |
| Teleport | 3.0 |
| Suspense | 3.0 (实验性) |
| defineAsyncComponent | 3.0 |
| Vue Router 4 | 4.0 |
| Pinia | 2.0 |

### 参考资源

- [Vue3 官方文档](https://cn.vuejs.org/)
- [Vue3 官方文档 (英文)](https://vuejs.org/)
- [Vue Router 4 文档](https://router.vuejs.org/)
- [Pinia 文档](https://pinia.vuejs.org/)
- [Vite 文档](https://vitejs.dev/)
- [Vue3 在线演练场](https://play.vuejs.org/)

### 版本信息

- 手册版本：1.0
- 最后更新：2026-07
- Vue 目标版本：3.x
