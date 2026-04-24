# Node.js 编程语法使用手册

> 本系列手册对比 Python 语言，全面介绍 Node.js 编程语法和最佳实践

## 手册目录

### 📚 核心语法

| 手册 | 描述 |
|------|------|
| [基础语法手册](./nodejs 基础语法手册.md) | 变量、数据类型、运算符、流程控制、字符串操作 |
| [数据结构手册](./nodejs 数据结构手册.md) | Array、Map、Set、Object、TypedArray |
| [函数与模块手册](./nodejs 函数与模块手册.md) | 函数定义、箭头函数、作用域、CommonJS/ESM 模块系统 |

### 🏗️ 高级主题

| 手册 | 描述 |
|------|------|
| [面向对象编程手册](./nodejs 面向对象编程手册.md) | 类与对象、继承、原型链、this 绑定 |
| [异常处理手册](./nodejs 异常处理手册.md) | try-catch-finally、Error 对象、自定义异常、最佳实践 |
| [文件操作手册](./nodejs 文件操作手册.md) | fs 模块、path 模块、流式读写、Buffer |
| [高级特性手册](./nodejs 高级特性手册.md) | Promise、async/await、生成器、迭代器、装饰器 |
| [并发编程手册](./nodejs 并发编程手册.md) | 事件循环、异步编程、Worker Threads、Cluster |

### 🔧 其他手册

| 手册 | 描述 |
|------|------|
| [项目全流程：npm](./nodejs 项目全流程：npm 使用详解.md) | 包管理、package.json、脚本命令 |

---

## 快速索引

### 基础概念

- [变量声明](./nodejs 基础语法手册.md#变量声明)
- [基本数据类型](./nodejs 基础语法手册.md#基本数据类型)
- [类型转换](./nodejs 基础语法手册.md#类型转换)
- [运算符](./nodejs 基础语法手册.md#运算符)
- [流程控制](./nodejs 基础语法手册.md#流程控制)
- [字符串操作](./nodejs 基础语法手册.md#字符串操作)

### 数据结构

- [数组 (Array)](./nodejs 数据结构手册.md#数组-array)
- [对象 (Object)](./nodejs 数据结构手册.md#对象-object)
- [Map](./nodejs 数据结构手册.md#map)
- [Set](./nodejs 数据结构手册.md#set)
- [TypedArray](./nodejs 数据结构手册.md#typedarray)
- [数据结构对比](./nodejs 数据结构手册.md#数据结构对比)

### 函数与模块

- [函数定义](./nodejs 函数与模块手册.md#函数定义)
- [箭头函数](./nodejs 函数与模块手册.md#箭头函数)
- [参数传递](./nodejs 函数与模块手册.md#参数传递)
- [作用域](./nodejs 函数与模块手册.md#作用域)
- [闭包](./nodejs 函数与模块手册.md#闭包)
- [CommonJS 模块](./nodejs 函数与模块手册.md#commonjs 模块)
- [ESM 模块](./nodejs 函数与模块手册.md#esm 模块)
- [常用内置函数](./nodejs 函数与模块手册.md#常用内置函数)

### 面向对象

- [类与对象](./nodejs 面向对象编程手册.md#类与对象)
- [构造函数](./nodejs 面向对象编程手册.md#构造函数)
- [实例方法和静态方法](./nodejs 面向对象编程手册.md#实例方法和静态方法)
- [访问修饰符](./nodejs 面向对象编程手册.md#访问修饰符)
- [继承](./nodejs 面向对象编程手册.md#继承)
- [原型链](./nodejs 面向对象编程手册.md#原型链)
- [this 绑定](./nodejs 面向对象编程手册.md#this 绑定)
- [Getter/Setter](./nodejs 面向对象编程手册.md#gettersetter)

### 异常处理

- [try-catch 语句](./nodejs 异常处理手册.md#try-catch-语句)
- [finally 子句](./nodejs 异常处理手册.md#finally 子句)
- [抛出异常](./nodejs 异常处理手册.md#抛出异常)
- [自定义异常](./nodejs 异常处理手册.md#自定义异常)
- [Error 对象](./nodejs 异常处理手册.md#error 对象)
- [常见内置异常](./nodejs 异常处理手册.md#常见内置异常)
- [最佳实践](./nodejs 异常处理手册.md#异常处理最佳实践)

### 文件操作

- [fs 模块基础](./nodejs 文件操作手册.md#fs 模块基础)
- [文件读取](./nodejs 文件操作手册.md#文件读取)
- [文件写入](./nodejs 文件操作手册.md#文件写入)
- [路径操作](./nodejs 文件操作手册.md#路径操作)
- [流式读写](./nodejs 文件操作手册.md#流式读写)
- [Buffer 操作](./nodejs 文件操作手册.md#buffer 操作)
- [文本与二进制文件](./nodejs 文件操作手册.md#文本与二进制文件)

### 高级特性

- [Promise](./nodejs 高级特性手册.md#promise)
- [async/await](./nodejs 高级特性手册.md#asyncawait)
- [生成器](./nodejs 高级特性手册.md#生成器)
- [迭代器](./nodejs 高级特性手册.md#迭代器)
- [装饰器](./nodejs 高级特性手册.md#装饰器)
- [Proxy](./nodejs 高级特性手册.md#proxy)
- [Reflect](./nodejs 高级特性手册.md#reflect)
- [类型注解 (TypeScript)](./nodejs 高级特性手册.md#类型注解)

### 并发编程

- [事件循环](./nodejs 并发编程手册.md#事件循环)
- [异步编程基础](./nodejs 并发编程手册.md#异步编程基础)
- [Promise 并发控制](./nodejs 并发编程手册.md#promise 并发控制)
- [Worker Threads](./nodejs 并发编程手册.md#worker-threads)
- [Cluster 模块](./nodejs 并发编程手册.md#cluster 模块)
- [child_process](./nodejs 并发编程手册.md#child_process)

---

## Node.js vs Python 快速对照

### 语法差异

| 特性 | Node.js (JavaScript) | Python |
|------|---------------------|--------|
| 变量声明 | `let x = 1`, `const x = 1` | `x = 1` |
| 类型系统 | 动态类型 (可选 TypeScript) | 动态类型 (可选类型注解) |
| 代码块 | 花括号 `{}` | 缩进 |
| 布尔值 | `true`, `false` | `True`, `False` |
| 空值 | `null`, `undefined` | `None` |
| 逻辑运算符 | `&&`, `\|\|`, `!` | `and`, `or`, `not` |
| 相等比较 | `===` (严格), `==` (宽松) | `==` (值), `is` (引用) |
| 注释 | `//`, `/* */` | `#`, `""" """` |

### 数据结构对照

| Node.js | Python |
|---------|--------|
| Array | list |
| Object | dict |
| Map | dict (ordered) |
| Set | set |
| TypedArray | array.array / numpy |
| string | str |

### 函数定义对照

| Node.js | Python |
|---------|--------|
| `function foo() {}` | `def foo():` |
| `const foo = () => {}` | `foo = lambda: ...` |
| `async function foo() {}` | `async def foo():` |
| `await promise` | `await coroutine` |

### 模块系统对照

| Node.js (CommonJS) | Node.js (ESM) | Python |
|-------------------|---------------|--------|
| `const mod = require('mod')` | `import mod from 'mod'` | `import mod` |
| `module.exports = {}` | `export default {}` | (module level) |
| - | `export { name }` | `from mod import name` |

### 并发模型对照

| Node.js | Python |
|---------|--------|
| Promise | asyncio.Future |
| async/await | async/await |
| EventEmitter | asyncio events |
| Worker Threads | threading / multiprocessing |
| Cluster | multiprocessing |
| child_process | subprocess |

---

## 学习路径建议

### 初学者

1. 📖 [基础语法手册](./nodejs 基础语法手册.md) - 掌握 JavaScript 基本语法
2. 📦 [数据结构手册](./nodejs 数据结构手册.md) - 理解内置数据结构
3. 🔧 [函数与模块手册](./nodejs 函数与模块手册.md) - 学习函数定义和模块使用
4. 📝 [文件操作手册](./nodejs 文件操作手册.md) - 掌握文件读写
5. ⚠️ [异常处理手册](./nodejs 异常处理手册.md) - 学会错误处理

### 进阶开发者

1. 🏗️ [面向对象编程手册](./nodejs 面向对象编程手册.md) - 深入理解 OOP
2. 🚀 [高级特性手册](./nodejs 高级特性手册.md) - 掌握 Promise、async/await 等
3. 🔀 [并发编程手册](./nodejs 并发编程手册.md) - 学习异步编程和事件循环

### 项目实战

1. 📦 [npm 使用详解](./nodejs 项目全流程：npm 使用详解.md) - 包管理和项目构建

---

## 代码示例索引

### 常用代码片段

#### 数组推导 (map/filter)
```javascript
const squares = Array.from({ length: 10 }, (_, i) => i ** 2);
const evens = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].filter(x => x % 2 === 0);
```

#### 对象解构
```javascript
const { name, age } = person;
const { x = 0, y = 0 } = options;
```

#### 展开运算符
```javascript
const merged = { ...obj1, ...obj2 };
const arr = [1, ...otherArr, 2];
```

#### Promise
```javascript
fetch('/api/data')
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

#### async/await
```javascript
async function fetchData() {
  try {
    const res = await fetch('/api/data');
    const data = await res.json();
    return data;
  } catch (err) {
    console.error(err);
  }
}
```

#### 类定义
```javascript
class Person {
  constructor(name) {
    this.name = name;
  }
  
  greet() {
    console.log(`Hello, I'm ${this.name}`);
  }
  
  static create(name) {
    return new Person(name);
  }
}
```

#### 事件发射器
```javascript
const EventEmitter = require('events');

class MyEmitter extends EventEmitter {}

const emitter = new MyEmitter();
emitter.on('event', (arg) => console.log(arg));
emitter.emit('event', 'hello');
```

---

## 附录

### Node.js 版本兼容性

本手册主要基于 Node.js 18+ (LTS) 编写，部分特性需要更新版本：

- Optional Chaining (`?.`)：Node.js 14+
- Nullish Coalescing (`??`)：Node.js 14+
- Top-level await：Node.js 14+ (ESM)
- Array.prototype.at()：Node.js 16+
- Object.hasOwn()：Node.js 16+

### 参考资源

- [Node.js 官方文档](https://nodejs.org/docs/)
- [MDN Web Docs](https://developer.mozilla.org/)
- [npm 文档](https://docs.npmjs.com/)
- [Node.js Design Patterns](https://nodejsdesignpatterns.com/)

### 版本信息

- 手册版本：1.0
- 最后更新：2026
- Node.js 目标版本：18+ (LTS)
- Python 对比版本：3.8+
