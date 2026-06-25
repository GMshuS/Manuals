# 第4章 TypeScript 函数与模块手册

> 本手册详细介绍 TypeScript 的函数定义、参数处理和模块系统

## 目录

1. [函数定义](#函数定义)
2. [箭头函数](#箭头函数)
3. [函数重载](#函数重载)
4. [参数处理](#参数处理)
5. [函数类型](#函数类型)
6. [作用域与闭包](#作用域与闭包)
7. [ESM 模块系统](#esm-模块系统)
8. [声明文件 (.d.ts)](#声明文件-dts)
9. [常用内置函数](#常用内置函数)

---

## 函数定义

### 函数声明

```typescript
// 命名函数（函数声明）
function add(a: number, b: number): number {
  return a + b;
}

// 可选参数
function greet(name: string, greeting?: string): string {
  return `${greeting ?? "Hello"}, ${name}!`;
}

// 默认参数
function createUser(
  name: string,
  age: number = 18,
  active: boolean = true
): { name: string; age: number; active: boolean } {
  return { name, age, active };
}

// 剩余参数
function sum(...numbers: number[]): number {
  return numbers.reduce((acc, n) => acc + n, 0);
}
```

### 函数表达式

```typescript
// 匿名函数表达式
const add2 = function (a: number, b: number): number {
  return a + b;
};

// 函数表达式支持类型注解
const multiply: (a: number, b: number) => number = function (a, b) {
  return a * b;
};
```

---

## 箭头函数

### 基本语法

```typescript
// 完整形式
const add3 = (a: number, b: number): number => {
  return a + b;
};

// 简写形式（单表达式自动 return）
const add4 = (a: number, b: number): number => a + b;

// 单参数可省略括号
const double = (x: number): number => x * 2;
const double2: (x: number) => number = x => x * 2;

// 无参数
const logTime = () => console.log(new Date());

// 返回对象字面量需加括号
const createPoint = (x: number, y: number): { x: number; y: number } => ({ x, y });
```

### 箭头函数特点

```typescript
// 1. 没有自己的 this，继承外层 this
class Timer {
  private count = 0;
  
  start() {
    // 传统函数：需要保存 this
    const self = this;
    setInterval(function () {
      self.count++;
    }, 1000);
    
    // 箭头函数：this 来自外层
    setInterval(() => {
      this.count++;  // 指向 Timer 实例
    }, 1000);
  }
}

// 2. 没有 arguments 对象
const foo = () => {
  // console.log(arguments);  // Error: arguments is not defined
  // 使用剩余参数代替
};

// 3. 不能作为构造函数
// const obj = new foo();  // Error: foo is not a constructor
```

---

## 函数重载

### TypeScript 函数重载

TypeScript 的函数重载是通过多个签名声明实现的（编译时检查）：

```typescript
// 重载签名（不包含实现）
function process(value: string): string;
function process(value: number): number;
function process(value: boolean): boolean;

// 实现签名（必须兼容所有重载）
function process(value: string | number | boolean): string | number | boolean {
  if (typeof value === "string") {
    return value.toUpperCase();
  } else if (typeof value === "number") {
    return value * 2;
  }
  return !value;
}

// 使用
const r1 = process("hello");  // string
const r2 = process(42);       // number
const r3 = process(true);     // boolean
// const r4 = process([]);    // Error: 没有匹配的重载

// 另一种方式：条件返回类型
function process2<T extends string | number | boolean>(
  value: T
): T extends string ? string : T extends number ? number : boolean {
  if (typeof value === "string") return value.toUpperCase() as any;
  if (typeof value === "number") return (value * 2) as any;
  return !value as any;
}
```

---

## 参数处理

### 参数解构

```typescript
// 对象参数解构
function printUser({ name, age, email }: { name: string; age: number; email?: string }): void {
  console.log(`${name} (${age})${email ? ` - ${email}` : ""}`);
}

// 带默认值的解构
function printConfig({
  host = "localhost",
  port = 3000,
  ssl = false,
}: {
  host?: string;
  port?: number;
  ssl?: boolean;
} = {}): void {
  console.log(`${host}:${port} (${ssl ? "HTTPS" : "HTTP"})`);
}

// 数组参数解构
function processPair([first, second]: [string, number]): string {
  return `${first}: ${second}`;
}
```

### 参数装饰器

```typescript
// 参数默认值
function multiply2(a: number, b: number = 10): number {
  return a * b;
}

// rest 参数
function buildName(firstName: string, ...restNames: string[]): string {
  return [firstName, ...restNames].join(" ");
}

// 参数展开
const nums = [1, 2, 3, 4, 5];
console.log(Math.max(...nums));  // 展开数组

// this 参数（TypeScript 特有）
interface Button {
  text: string;
  onClick(this: Button, event: MouseEvent): void;
}
```

---

## 函数类型

### 函数类型签名

```typescript
// 函数类型变量
type MathOperation = (a: number, b: number) => number;

const add_op: MathOperation = (a, b) => a + b;
const sub_op: MathOperation = (a, b) => a - b;

// 带属性的函数
type Greeter = {
  (name: string): string;
  readonly defaultGreeting: string;
};

function createGreeter(): Greeter {
  const greeter = ((name: string) => {
    return `${greeter.defaultGreeting}, ${name}!`;
  }) as Greeter;
  greeter.defaultGreeting = "Hello";
  return greeter;
}

// 构造函数类型
type PointConstructor = new (x: number, y: number) => { x: number; y: number };

class Point2 {
  constructor(public x: number, public y: number) {}
}

const createPoint2: PointConstructor = Point2;
```

### Callable / 方法签名

```typescript
// Callable 接口
interface CallableFunction {
  (...args: unknown[]): unknown;
}

// 方法签名接口
interface Stringifier {
  (value: unknown): string;
  format: "json" | "string";
}

const toJSON: Stringifier = Object.assign(
  (value: unknown) => JSON.stringify(value),
  { format: "json" as const }
);
```

---

## 作用域与闭包

### 作用域规则

```typescript
// 全局作用域
const globalVar = "global";

function outer() {
  // 函数作用域
  const outerVar = "outer";
  
  function inner() {
    // 内层函数作用域
    const innerVar = "inner";
    console.log(globalVar);  // "global"
    console.log(outerVar);   // "outer"
  }
  
  // console.log(innerVar);  // Error: 无法访问
  inner();
}

// 块级作用域
if (true) {
  const blockVar = "block";
  let blockLet = "also block";
}
// console.log(blockVar);  // Error
// console.log(blockLet);  // Error
```

### 闭包

```typescript
// 闭包：函数 + 其词法环境
function createCounter(): () => number {
  let count = 0;
  return () => {
    count++;
    return count;
  };
}

const counter = createCounter();
console.log(counter());  // 1
console.log(counter());  // 2
console.log(counter());  // 3

// 闭包实现工厂函数
function createGreeter2(greeting: string): (name: string) => string {
  return (name: string) => `${greeting}, ${name}!`;
}

const sayHello = createGreeter2("Hello");
const sayHi = createGreeter2("Hi");

console.log(sayHello("Alice"));  // "Hello, Alice!"
console.log(sayHi("Bob"));       // "Hi, Bob!"

// 经典闭包陷阱
for (var i = 0; i < 5; i++) {
  setTimeout(() => console.log(i), 100);  // 5, 5, 5, 5, 5
}

// 使用 let 解决
for (let i = 0; i < 5; i++) {
  setTimeout(() => console.log(i), 100);  // 0, 1, 2, 3, 4
}

// 使用 IIFE
for (var i = 0; i < 5; i++) {
  ((n) => {
    setTimeout(() => console.log(n), 100);
  })(i);  // 0, 1, 2, 3, 4
}
```

---

## ESM 模块系统

### 导出语法

```typescript
// ===== math.ts =====

// 命名导出
export const PI = 3.14159;
export function add(a: number, b: number): number {
  return a + b;
}
export class Calculator {
  multiply(a: number, b: number): number {
    return a * b;
  }
}

// 批量导出
const E = 2.71828;
const GOLDEN_RATIO = 1.618;
export { E, GOLDEN_RATIO };

// 别名导出
const internalName = "exported";
export { internalName as externalName };

// 默认导出
export default function log(value: unknown): void {
  console.log(value);
}

// 默认导出类
export default class Logger {
  log(msg: string): void { console.log(msg); }
}
```

### 导入语法

```typescript
// ===== app.ts =====

// 命名导入
import { PI, add, Calculator } from "./math";

// 默认导入
import log from "./math";

// 混合导入
import log, { PI, add } from "./math";

// 全部导入为命名空间
import * as MathUtils from "./math";
console.log(MathUtils.PI);

// 别名导入
import { add as mathAdd } from "./math";

// 类型导入
import type { Config } from "./config";  // 仅导入类型
import { type Config, type Options } from "./config";

// 动态导入
async function loadModule() {
  const module = await import("./math");
  console.log(module.PI);
}
```

### 重新导出

```typescript
// ===== index.ts =====

// 全部重新导出
export * from "./math";

// 选择性重新导出
export { PI, add } from "./math";

// 重命名后重新导出
export { PI as MathPI } from "./math";

// 重新导出类型
export type { Config } from "./config";

// 在当前作用域导入并重新导出
import { Helper } from "./helper";
export { Helper };

// 重新导出默认导出
export { default as MathDefault } from "./math";
```

### 模块解析策略

```typescript
// 相对导入
import { foo } from "./foo";      // 同目录
import { bar } from "../utils";   // 上级目录

// 非相对导入（从 node_modules 解析）
import express from "express";
import { z } from "zod";

// tsconfig.json 中的 paths 别名
// tsconfig.json:
// {
//   "compilerOptions": {
//     "paths": {
//       "@/*": ["./src/*"]
//     }
//   }
// }
import { UserService } from "@//services/user";
```

---

## 声明文件 (.d.ts)

### 全局声明

```typescript
// ===== global.d.ts =====

// 声明全局变量
declare const ENV: string;
declare const __VERSION__: string;

// 声明全局函数
declare function $(selector: string): Element[];

// 声明全局类型
interface Window {
  myCustomProperty: string;
}

// 声明模块
declare module "*.css" {
  const content: Record<string, string>;
  export default content;
}

declare module "*.svg" {
  const content: string;
  export default content;
}
```

### 模块增强

```typescript
// 为第三方模块添加类型
// ===== express.d.ts =====
import "express";

declare module "express" {
  interface Request {
    user?: {
      id: number;
      name: string;
    };
  }
}

// 使用
// app.use((req, res) => {
//   const user = req.user;  // 有类型
// });
```

### 类型声明示例

```typescript
// ===== types.d.ts =====

// 声明类类型
declare class MyClass {
  constructor(options: { debug?: boolean });
  run(): void;
}

// 声明命名空间
declare namespace MyLib {
  function init(config: Record<string, unknown>): void;
  const version: string;
}

// 声明枚举
declare enum MyEnum {
  A = 1,
  B = 2,
}
```

---

## 常用内置函数

### 类型工具函数

```typescript
// typeof - 运行时类型检查
console.log(typeof 42);         // "number"
console.log(typeof "hello");    // "string"
console.log(typeof true);       // "boolean"
console.log(typeof undefined);  // "undefined"
console.log(typeof null);       // "object"（历史遗留）
console.log(typeof []);        // "object"
console.log(typeof {});        // "object"
console.log(typeof (() => {})); // "function"

// instanceof
const date = new Date();
console.log(date instanceof Date);     // true
console.log(date instanceof Object);   // true

// isNaN / isFinite
console.log(isNaN(NaN));        // true
console.log(isFinite(Infinity)); // false
```

### 值转换函数

```typescript
// parseInt / parseFloat
parseInt("42");         // 42
parseInt("1010", 2);   // 10（二进制）
parseInt("ff", 16);    // 255（十六进制）
parseFloat("3.14");    // 3.14

// Number / String / Boolean
Number("42");        // 42
String(42);          // "42"
Boolean(1);          // true

// JSON
JSON.stringify({ a: 1, b: 2 });   // '{"a":1,"b":2}'
JSON.parse('{"a":1}');            // { a: 1 }

// encodeURI / decodeURI
encodeURI("https://example.com/测试");  // URL 编码
decodeURI("%E6%B5%8B%E8%AF%95");       // URL 解码
```
