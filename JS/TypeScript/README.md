# TypeScript 编程语法使用手册

> 本系列手册全面介绍 TypeScript 编程语法和最佳实践

## 手册目录

### 📚 第1-4章 核心语法

| 手册 | 描述 |
|------|------|
| [第1章 基础语法手册](./第1章%20TypeScript%20基础语法手册.md) | 变量声明、基本类型、运算符、流程控制、字符串操作 |
| [第2章 类型系统手册](./第2章%20TypeScript%20类型系统手册.md) | 静态类型、接口、类型别名、联合/交叉类型、类型守卫、工具类型 |
| [第3章 数据结构手册](./第3章%20TypeScript%20数据结构手册.md) | 数组、元组、枚举、Object、Map、Set、类型化数组 |
| [第4章 函数与模块手册](./第4章%20TypeScript%20函数与模块手册.md) | 函数定义、箭头函数、重载、参数、ESM 模块系统、声明文件 |

### 🏗️ 第5-8章 高级主题

| 手册 | 描述 |
|------|------|
| [第6章 面向对象编程手册](./第6章%20TypeScript%20面向对象编程手册.md) | 类与对象、接口实现、继承、访问修饰符、抽象类、混入 |
| [第7章 泛型编程手册](./第7章%20TypeScript%20泛型编程手册.md) | 泛型函数、泛型约束、条件类型、映射类型、模板字面量类型 |
| [第5章 异常处理手册](./第5章%20TypeScript%20异常处理手册.md) | try-catch-finally、Error 层级、自定义异常、类型化错误 |
| [第8章 异步编程手册](./第8章%20TypeScript%20异步编程手册.md) | Promise、async/await、事件循环、并发控制、类型安全异步 |

### 🔧 第9章 工程化

| 手册 | 描述 |
|------|------|
| [第9章 项目全流程手册](./第9章%20TypeScript%20项目全流程手册.md) | tsconfig 配置、npm 包管理、构建工具、ESLint、调试 |

---

## 快速索引

### 基础概念

- [变量声明](./第1章%20TypeScript%20基础语法手册.md#变量声明)
- [基本数据类型](./第1章%20TypeScript%20基础语法手册.md#基本数据类型)
- [类型注解](./第1章%20TypeScript%20基础语法手册.md#类型注解)
- [类型推断](./第1章%20TypeScript%20基础语法手册.md#类型推断)
- [运算符](./第1章%20TypeScript%20基础语法手册.md#运算符)
- [流程控制](./第1章%20TypeScript%20基础语法手册.md#流程控制)
- [字符串操作](./第1章%20TypeScript%20基础语法手册.md#字符串操作)

### 类型系统

- [原始类型](./第2章%20TypeScript%20类型系统手册.md#原始类型)
- [接口 (Interface)](./第2章%20TypeScript%20类型系统手册.md#接口-interface)
- [类型别名 (Type Alias)](./第2章%20TypeScript%20类型系统手册.md#类型别名-type-alias)
- [联合类型](./第2章%20TypeScript%20类型系统手册.md#联合类型)
- [交叉类型](./第2章%20TypeScript%20类型系统手册.md#交叉类型)
- [类型守卫](./第2章%20TypeScript%20类型系统手册.md#类型守卫)
- [工具类型](./第2章%20TypeScript%20类型系统手册.md#工具类型)

### 数据结构

- [数组 (Array)](./第3章%20TypeScript%20数据结构手册.md#数组-array)
- [元组 (Tuple)](./第3章%20TypeScript%20数据结构手册.md#元组-tuple)
- [枚举 (Enum)](./第3章%20TypeScript%20数据结构手册.md#枚举-enum)
- [对象 (Object)](./第3章%20TypeScript%20数据结构手册.md#对象-object)
- [Map / Set](./第3章%20TypeScript%20数据结构手册.md#map--set)
- [数据结构对比](./第3章%20TypeScript%20数据结构手册.md#数据结构对比)

### 函数与模块

- [函数定义](./第4章%20TypeScript%20函数与模块手册.md#函数定义)
- [箭头函数](./第4章%20TypeScript%20函数与模块手册.md#箭头函数)
- [函数重载](./第4章%20TypeScript%20函数与模块手册.md#函数重载)
- [参数处理](./第4章%20TypeScript%20函数与模块手册.md#参数处理)
- [ESM 模块](./第4章%20TypeScript%20函数与模块手册.md#esm-模块)
- [声明文件 (.d.ts)](./第4章%20TypeScript%20函数与模块手册.md#声明文件-dts)

### 面向对象

- [类定义](./第6章%20TypeScript%20面向对象编程手册.md#类定义)
- [访问修饰符](./第6章%20TypeScript%20面向对象编程手册.md#访问修饰符)
- [接口实现](./第6章%20TypeScript%20面向对象编程手册.md#接口实现)
- [继承](./第6章%20TypeScript%20面向对象编程手册.md#继承)
- [抽象类](./第6章%20TypeScript%20面向对象编程手册.md#抽象类)
- [静态成员](./第6章%20TypeScript%20面向对象编程手册.md#静态成员)
- [Getter/Setter](./第6章%20TypeScript%20面向对象编程手册.md#gettersetter)
- [混入 (Mixin)](./第6章%20TypeScript%20面向对象编程手册.md#混入-mixin)

### 泛型编程

- [泛型函数](./第7章%20TypeScript%20泛型编程手册.md#泛型函数)
- [泛型接口](./第7章%20TypeScript%20泛型编程手册.md#泛型接口)
- [泛型约束](./第7章%20TypeScript%20泛型编程手册.md#泛型约束)
- [条件类型](./第7章%20TypeScript%20泛型编程手册.md#条件类型)
- [映射类型](./第7章%20TypeScript%20泛型编程手册.md#映射类型)
- [模板字面量类型](./第7章%20TypeScript%20泛型编程手册.md#模板字面量类型)

### 异常处理

- [try-catch 语句](./第5章%20TypeScript%20异常处理手册.md#try-catch-语句)
- [finally 子句](./第5章%20TypeScript%20异常处理手册.md#finally-子句)
- [抛出异常](./第5章%20TypeScript%20异常处理手册.md#抛出异常)
- [自定义异常类](./第5章%20TypeScript%20异常处理手册.md#自定义异常类)
- [类型化错误处理](./第5章%20TypeScript%20异常处理手册.md#类型化错误处理)
- [异步错误处理](./第5章%20TypeScript%20异常处理手册.md#异步错误处理)

### 异步编程

- [Promise](./第8章%20TypeScript%20异步编程手册.md#promise)
- [async/await](./第8章%20TypeScript%20异步编程手册.md#asyncawait)
- [Promise 并发控制](./第8章%20TypeScript%20异步编程手册.md#promise-并发控制)
- [类型安全异步](./第8章%20TypeScript%20异步编程手册.md#类型安全异步)
---

## 学习路径建议

### 初学者

1. 📖 [第1章 基础语法手册](./第1章%20TypeScript%20基础语法手册.md) - 掌握 TypeScript 基本语法和类型注解
2. 🏷️ [第2章 类型系统手册](./第2章%20TypeScript%20类型系统手册.md) - 理解 TypeScript 类型系统的核心
3. 📦 [第3章 数据结构手册](./第3章%20TypeScript%20数据结构手册.md) - 学习内置数据结构和类型
4. 🔧 [第4章 函数与模块手册](./第4章%20TypeScript%20函数与模块手册.md) - 函数定义和模块系统
5. ⚠️ [第5章 异常处理手册](./第5章%20TypeScript%20异常处理手册.md) - 学会错误处理

### 进阶开发者

1. 🏗️ [第6章 面向对象编程手册](./第6章%20TypeScript%20面向对象编程手册.md) - 深入理解 OOP
2. 🧬 [第7章 泛型编程手册](./第7章%20TypeScript%20泛型编程手册.md) - 掌握泛型、条件类型、映射类型
3. ⚡ [第8章 异步编程手册](./第8章%20TypeScript%20异步编程手册.md) - 学习异步编程和类型安全

### 项目实战

1. 📦 [第9章 项目全流程手册](./第9章%20TypeScript%20项目全流程手册.md) - tsconfig、npm、构建工具

---

## 代码示例索引

### 常用代码片段

#### 类型注解
```typescript
let name: string = "Alice";
let age: number = 25;
let isActive: boolean = true;
let data: unknown = JSON.parse('{}');
```

#### 接口定义
```typescript
interface User {
  id: number;
  name: string;
  email?: string;        // 可选属性
  readonly createdAt: Date;  // 只读
}

function greet(user: User): string {
  return `Hello, ${user.name}`;
}
```

#### 泛型函数
```typescript
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

const num = first([1, 2, 3]);  // number | undefined
const str = first(["a", "b"]); // string | undefined
```

#### 联合类型与类型守卫
```typescript
type Shape = 
  | { kind: "circle"; radius: number }
  | { kind: "square"; side: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.side ** 2;
  }
}
```

#### async/await
```typescript
async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error("Failed to fetch");
  return res.json();
}
```

#### 类定义
```typescript
class Counter {
  private count = 0;
  
  increment(): void {
    this.count++;
  }
  
  get value(): number {
    return this.count;
  }
  
  static create(): Counter {
    return new Counter();
  }
}
```

---

## 附录

### TypeScript 版本兼容性

本手册主要基于 TypeScript 5.x 编写，部分特性需要特定版本：

- `const` 类型参数：TypeScript 5.0+
- 装饰器（新标准）：TypeScript 5.0+
- `satisfies` 运算符：TypeScript 4.9+
- 模板字面量类型：TypeScript 4.1+
- 条件类型：TypeScript 2.8+
- 映射类型：TypeScript 2.1+
- `unknown` 类型：TypeScript 3.0+

### 参考资源

- [TypeScript 官方文档](https://www.typescriptlang.org/docs/)
- [TypeScript Playground](https://www.typescriptlang.org/play/)
- [Type Challenges](https://github.com/type-challenges/type-challenges)
- [MDN JavaScript Reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)
- [Node.js 官方文档](https://nodejs.org/docs/)

### 版本信息

- 手册版本：1.0
- 最后更新：2026
- TypeScript 目标版本：5.x

