# 第2章 TypeScript 类型系统手册

> 本手册详细介绍 TypeScript 的类型系统核心概念

## 目录

1. [类型系统概述](#类型系统概述)
2. [原始类型](#原始类型)
3. [接口 (Interface)](#接口-interface)
4. [类型别名 (Type Alias)](#类型别名-type-alias)
5. [联合类型](#联合类型)
6. [交叉类型](#交叉类型)
7. [类型守卫](#类型守卫)
8. [类型操作符](#类型操作符)
9. [工具类型](#工具类型)
10. [声明合并](#声明合并)

---

## 类型系统概述

### TypeScript 类型系统特点

TypeScript 的类型系统是**结构化类型系统**（Structural Type System），即类型兼容性基于结构而非名称。

| 特性 | TypeScript |
|------|------------|
| 类型检查时机 | 编译时 |
| 类型系统 | 结构化类型 |
| 类型注解 | 内置语法支持 |
| 可为空 | `null` 和 `undefined` 独立类型 |
| 泛型 | 原生支持 |
| 类型擦除 | 编译后擦除 |

### 结构化类型 vs 名义类型

```typescript
// TypeScript 结构化类型: 只要结构匹配就兼容
interface Point {
  x: number;
  y: number;
}

interface Position {
  x: number;
  y: number;
}

const p: Point = { x: 10, y: 20 };
const pos: Position = p;  // OK! 结构相同

function logPoint(p: Point) {
  console.log(p.x, p.y);
}

logPoint({ x: 1, y: 2 });   // OK: 对象字面量
logPoint({ x: 1, y: 2, z: 3 });  // Error: 多余属性（对象字面量的额外属性检查）
```

---

## 原始类型

### 基础原始类型

```typescript
// 原始类型
const a: number = 42;        // 数字（含整数和浮点数）
const b: string = "hello";   // 字符串
const c: boolean = true;     // 布尔值
const d: bigint = 100n;      // 大整数
const e: symbol = Symbol();  // 唯一符号
const f: null = null;        // 空值
const g: undefined = undefined;  // 未定义
```

### 特殊类型

```typescript
// any - 逃逸类型（关闭类型检查）
let loose: any = 42;
loose = "string";       // OK
loose = true;           // OK
loose.doSomething();    // 编译通过，但可能运行时崩溃

// unknown - 安全版 any
let safe: unknown = 42;
safe = "string";        // OK
// safe.doSomething();  // Error: Object is of type 'unknown'

// 类型收窄后才能使用
if (typeof safe === "string") {
  console.log(safe.toUpperCase());  // OK: 类型收窄为 string
}

// never - 永不发生的值
function throwError(message: string): never {
  throw new Error(message);
}

function infiniteLoop(): never {
  while (true) {}
}

// void - 函数不返回值
function log(msg: string): void {
  console.log(msg);
}

// 穷尽检查
type Shape = "circle" | "square" | "triangle";
function getArea(shape: Shape): number {
  switch (shape) {
    case "circle": return 1;
    case "square": return 2;
    case "triangle": return 3;
    default:
      // 此处 shape 类型被收窄为 never
      const _exhaustive: never = shape;
      return _exhaustive;
  }
}
```

---

## 接口 (Interface)

### 基本接口定义

```typescript
interface User {
  id: number;
  name: string;
  email?: string;          // 可选属性
  readonly createdAt: Date; // 只读属性
}

const user: User = {
  id: 1,
  name: "Alice",
  createdAt: new Date(),
  // email 可选，可省略
};

// user.createdAt = new Date();  // Error: 只读
```

### 方法定义

```typescript
interface Animal {
  name: string;
  speak(): string;          // 方法声明
  move(distance: number): void;
}

// 函数类型接口
interface SearchFunc {
  (source: string, subString: string): boolean;
}

const mySearch: SearchFunc = (src, sub) => {
  return src.includes(sub);
};

// 索引签名
interface StringArray {
  [index: number]: string;
}

interface Dictionary {
  [key: string]: unknown;
  // 可以同时定义具名属性
  length: number;
}
```

### 接口继承

```typescript
interface Person {
  name: string;
  age: number;
}

interface Employee extends Person {
  employeeId: string;
  department: string;
}

const emp: Employee = {
  name: "Alice",
  age: 30,
  employeeId: "EMP001",
  department: "Engineering",
};

// 多继承
interface A { a: string }
interface B { b: number }
interface C extends A, B { c: boolean }

const obj: C = { a: "hello", b: 42, c: true };
```

### 接口与类

```typescript
interface ClockInterface {
  currentTime: Date;
  setTime(d: Date): void;
}

class Clock implements ClockInterface {
  currentTime: Date = new Date();
  
  setTime(d: Date): void {
    this.currentTime = d;
  }
}
```

---

## 类型别名 (Type Alias)

### 基本类型别名

```typescript
// 原始类型别名
type ID = number;
type Name = string;
type Callback = (value: string) => void;

// 联合类型别名
type Status = "success" | "error" | "loading";

// 对象类型别名
type Point = {
  x: number;
  y: number;
};

// 函数类型别名
type GreetFunction = (name: string) => string;
```

### Interface vs Type Alias

| 特性 | Interface | Type Alias |
|------|-----------|------------|
| 扩展 | `extends` | `&`（交叉） |
| 合并 | 同名自动合并 | 同名报错 |
| 映射类型 | 不支持 | 支持 |
| 联合类型 | 不支持 | 支持 |
| 元组 | 不支持 | 支持 |
| 性能 | 通常更快 | 大型联合可能慢 |

```typescript
// Interface 可声明合并
interface Box {
  value: string;
}
interface Box {
  label: string;
}
// Box = { value: string; label: string }

// Type 不可重名
type Box2 = { value: string };
// type Box2 = { label: string };  // Error: Duplicate identifier

// Type 支持联合
type Result<T> = { ok: true; data: T } | { ok: false; error: string };
```

---

## 联合类型

### 基本联合类型

```typescript
// 类型联合
type StringOrNumber = string | number;
let value: StringOrNumber;
value = "hello";  // OK
value = 42;       // OK
// value = true;  // Error

// 字面量联合
type Direction = "north" | "south" | "east" | "west";
type HTTPCode = 200 | 201 | 400 | 404 | 500;
```

### 可辨识联合（Discriminated Union）

```typescript
// 使用共同属性区分（代数数据类型风格）
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "square"; side: number }
  | { kind: "rectangle"; width: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      // 此处 shape 被收窄为 { kind: "circle"; radius: number }
      return Math.PI * shape.radius ** 2;
    case "square":
      return shape.side ** 2;
    case "rectangle":
      return shape.width * shape.height;
  }
}

// 穷尽检查
function assertNever(x: never): never {
  throw new Error("Unexpected value: " + x);
}

function area2(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2;
    case "square": return shape.side ** 2;
    case "rectangle": return shape.width * shape.height;
    default: return assertNever(shape);  // 如果未穷尽，编译错误
  }
}
```

---

## 交叉类型

### 基本交叉类型

```typescript
// 交叉类型合并多个类型
type Named = { name: string };
type Aged = { age: number };

type Person = Named & Aged;

const person: Person = {
  name: "Alice",
  age: 30,
};

// 与接口继承相比
interface Person2 extends Named, Aged {}
```

### 交叉类型的使用场景

```typescript
// 混入功能
type HasId = { id: string };
type HasTimestamp = { createdAt: Date; updatedAt: Date };
type HasMetadata = { metadata: Record<string, unknown> };

type Entity = HasId & HasTimestamp & HasMetadata;

// 函数参数扩展
type BaseConfig = {
  host: string;
  port: number;
};

type SecurityConfig = {
  ssl: boolean;
  authToken?: string;
};

type ServerConfig = BaseConfig & SecurityConfig;
```

### 冲突处理

```typescript
// 交叉类型中相同属性会合并
type A = { x: number; common: string };
type B = { y: number; common: number };

// C = { x: number; y: number; common: never }
// 因为 string & number = never
type C = A & B;

// 最佳实践：避免属性冲突
type D = A & Omit<B, "common">;
// 或使用扩展覆盖
type E = A & { common: string | number };
```

---

## 类型守卫

### typeof 守卫

```typescript
function process(value: string | number | boolean) {
  // typeof 类型收窄
  if (typeof value === "string") {
    // value: string
    return value.toUpperCase();
  }
  if (typeof value === "number") {
    // value: number
    return value.toFixed(2);
  }
  // value: boolean
  return value ? "yes" : "no";
}
```

### instanceof 守卫

```typescript
class Dog {
  bark(): string { return "Woof!"; }
}

class Cat {
  meow(): string { return "Meow!"; }
}

function makeSound(animal: Dog | Cat) {
  if (animal instanceof Dog) {
    return animal.bark();
  }
  return animal.meow();
}
```

### 自定义类型守卫

```typescript
// 使用 is 关键字定义类型谓词
interface Fish {
  swim(): void;
  name: string;
}

interface Bird {
  fly(): void;
  name: string;
}

function isFish(pet: Fish | Bird): pet is Fish {
  return (pet as Fish).swim !== undefined;
}

function move(pet: Fish | Bird) {
  if (isFish(pet)) {
    return pet.swim();  // pet 收窄为 Fish
  }
  return pet.fly();     // pet 收窄为 Bird
}

// 属性名守卫
function hasProperty<K extends string>(
  obj: unknown,
  key: K
): obj is { [P in K]: unknown } {
  return typeof obj === "object" && obj !== null && key in obj;
}
```

### in 操作符守卫

```typescript
type Circle2 = { radius: number };
type Square2 = { side: number };

function getArea2(shape: Circle2 | Square2): number {
  if ("radius" in shape) {
    return Math.PI * shape.radius ** 2;
  }
  return shape.side ** 2;
}
```

---

## 类型操作符

### keyof 操作符

```typescript
interface Person3 {
  name: string;
  age: number;
  email: string;
}

// keyof T 返回 T 的键的联合类型
type PersonKeys = keyof Person3;  // "name" | "age" | "email"

function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const p: Person3 = { name: "Alice", age: 30, email: "a@b.com" };
const n = getProperty(p, "name");   // n: string
const a = getProperty(p, "age");    // a: number
```

### typeof 操作符

```typescript
// typeof 值 -> 类型
const config = {
  host: "localhost",
  port: 3000,
  ssl: true,
};

type Config = typeof config;
// { host: string; port: number; ssl: boolean }

// 与 ReturnType 结合
function createUser(name: string, age: number) {
  return { id: Math.random(), name, age };
}

type UserType = ReturnType<typeof createUser>;
// { id: number; name: string; age: number }
```

### 索引访问类型

```typescript
interface Person4 {
  name: string;
  age: number;
  address: {
    city: string;
    street: string;
  };
}

type NameType = Person4["name"];       // string
type AgeType = Person4["age"];          // number
type CityType = Person4["address"]["city"];  // string

// 联合索引
type NameOrAge = Person4["name" | "age"];  // string | number

// 使用 keyof
type AnyValue = Person4[keyof Person4];
// string | number | { city: string; street: string }
```

---

## 工具类型

### Partial / Required / Readonly

```typescript
interface Task {
  id: number;
  title: string;
  description: string;
  completed: boolean;
}

// Partial<T> - 所有属性变为可选
type PartialTask = Partial<Task>;
// { id?: number; title?: string; description?: string; completed?: boolean }

// Required<T> - 所有属性变为必填
type RequiredTask = Required<PartialTask>;

// Readonly<T> - 所有属性变为只读
type ReadonlyTask = Readonly<Task>;

// 使用场景
function updateTask(id: number, updates: Partial<Task>): void {
  // 只需要传入要更新的字段
}
```

### Pick / Omit

```typescript
// Pick<T, K> - 选取部分属性
type TaskPreview = Pick<Task, "id" | "title">;
// { id: number; title: string }

// Omit<T, K> - 排除部分属性
type TaskForm = Omit<Task, "id" | "completed">;
// { title: string; description: string }
```

### Record / Extract / Exclude

```typescript
// Record<K, V> - 构造对象类型
type PageInfo = Record<string, string>;
// { [key: string]: string }

type UserRoles = Record<"admin" | "user" | "guest", number>;
// { admin: number; user: number; guest: number }

// Extract<T, U> - 提取联合类型中的子集
type T0 = Extract<"a" | "b" | "c", "a" | "f">;  // "a"

// Exclude<T, U> - 排除联合类型中的子集
type T1 = Exclude<"a" | "b" | "c", "a" | "f">;  // "b" | "c"
```

### NonNullable / ReturnType / Parameters

```typescript
// NonNullable<T> - 排除 null 和 undefined
type T2 = NonNullable<string | number | null | undefined>;
// string | number

// ReturnType<T> - 获取函数返回类型
function createUser2() { return { id: 1, name: "Alice" }; }
type UserReturn = ReturnType<typeof createUser2>;
// { id: number; name: string }

// Parameters<T> - 获取函数参数类型（元组）
function greet2(name: string, age: number): void {}
type GreetParams = Parameters<typeof greet2>;
// [name: string, age: number]

// ConstructorParameters<T> - 构造函数参数类型
class Foo { constructor(a: string, b: number) {} }
type FooParams = ConstructorParameters<typeof Foo>;
// [a: string, b: number]

// InstanceType<T> - 实例类型
type FooInstance = InstanceType<typeof Foo>;
// Foo
```

### Awaited / ThisType

```typescript
// Awaited<T> - 递归解包 Promise
type PromiseResult = Awaited<Promise<Promise<string>>>;
// string

async function fetchData(): Promise<{ data: string }> {
  return { data: "hello" };
}
type FetchResult = Awaited<ReturnType<typeof fetchData>>;
// { data: string }

// ThisType<T> - 标记 this 类型
type ObjectDescriptor<D, M> = {
  data?: D;
  methods?: M & ThisType<D & M>;
};

function makeObject<D, M>(desc: ObjectDescriptor<D, M>): D & M {
  // ...
}
```

---

## 声明合并

### 接口合并

```typescript
// TypeScript 中同名接口自动合并
interface Document {
  title: string;
}

interface Document {
  body: string;
}

// Document = { title: string; body: string }
const doc: Document = {
  title: "TypeScript Guide",
  body: "Content here",
};

// 可用于扩展第三方类型
interface Array<T> {
  // 为全局 Array 添加方法
  first(): T | undefined;
}

Array.prototype.first = function <T>(this: T[]): T | undefined {
  return this[0];
};
```

### 命名空间合并

```typescript
// 命名空间（旧式模块）与类/函数/枚举的合并
class Album {
  label!: Album.AlbumLabel;
}

namespace Album {
  export class AlbumLabel {
    name!: string;
  }
  export const DEFAULT_LABEL = "Universal";
}

// Album 类带有静态属性 AlbumLabel
const album = new Album();
const label = new Album.AlbumLabel();
```
