# 第3章 TypeScript 数据结构手册

> 本手册详细介绍 TypeScript 中的数据结构

## 目录

1. [数组 (Array)](#数组-array)
2. [元组 (Tuple)](#元组-tuple)
3. [枚举 (Enum)](#枚举-enum)
4. [对象 (Object)](#对象-object)
5. [Map / Set](#map--set)
6. [TypedArray / Buffer](#typedarray--buffer)
7. [数据结构对比](#数据结构对比)

---

## 数组 (Array)

### 类型化数组

```typescript
// 两种等价语法
const numbers1: number[] = [1, 2, 3, 4, 5];
const numbers2: Array<number> = [1, 2, 3, 4, 5];

// 只读数组
const readonly: readonly number[] = [1, 2, 3];
// readonly.push(4);  // Error: 只读
const readonly2: ReadonlyArray<number> = [1, 2, 3];
```

### 数组创建

```typescript
// 字面量创建
const arr1: number[] = [1, 2, 3];

// 构造函数
const arr2: number[] = new Array(5);     // [empty × 5]
const arr3: number[] = new Array(1, 2, 3); // [1, 2, 3]

// Array.from
const from1 = Array.from("hello");         // ["h", "e", "l", "l", "o"]
const from2 = Array.from({ length: 5 }, (_, i) => i * 2);  // [0, 2, 4, 6, 8]

// Array.of
const of1 = Array.of(1, 2, 3);  // [1, 2, 3]

// fill
const filled = new Array(3).fill(0);  // [0, 0, 0]
```

### 数组遍历与转换

```typescript
const arr = [1, 2, 3, 4, 5];

// forEach - 遍历
arr.forEach((item, index) => {
  console.log(index, item);
});

// map - 变换
const doubled = arr.map(x => x * 2);  // [2, 4, 6, 8, 10]

// filter - 过滤
const evens = arr.filter(x => x % 2 === 0);  // [2, 4]

// reduce - 归约
const sum = arr.reduce((acc, x) => acc + x, 0);  // 15

// some / every - 条件检查
const hasEven = arr.some(x => x % 2 === 0);   // true
const allPositive = arr.every(x => x > 0);    // true

// find / findIndex - 查找
const firstEven = arr.find(x => x % 2 === 0);      // 2
const firstEvenIdx = arr.findIndex(x => x % 2 === 0);  // 1

// includes - 包含检查
arr.includes(3);  // true

// flat / flatMap - 展平
const nested = [[1, 2], [3, 4]];
nested.flat();               // [1, 2, 3, 4]
nested.flatMap(x => x);      // [1, 2, 3, 4]

// sort - 排序（注意：默认按字符串排序）
const sorted = [3, 1, 4, 1, 5].sort((a, b) => a - b);  // [1, 1, 3, 4, 5]

// reverse - 反转
arr.reverse();  // [5, 4, 3, 2, 1]

// join - 转字符串
arr.join(", ");  // "5, 4, 3, 2, 1"
```


```typescript
const arr = [1, 2, 3, 4, 5];

// forEach - 遍历
arr.forEach((item, index) => {
  console.log(index, item);
});

// map - 变换
const doubled = arr.map(x => x * 2);  // [2, 4, 6, 8, 10]

// filter - 过滤
const evens = arr.filter(x => x % 2 === 0);  // [2, 4]

// reduce - 归约
const sum = arr.reduce((acc, x) => acc + x, 0);  // 15

// some / every - 条件检查
const hasEven = arr.some(x => x % 2 === 0);   // true
const allPositive = arr.every(x => x > 0);    // true

// find / findIndex - 查找
const firstEven = arr.find(x => x % 2 === 0);      // 2
const firstEvenIdx = arr.findIndex(x => x % 2 === 0);  // 1

// includes - 包含检查
arr.includes(3);  // true

// flat / flatMap - 展平
const nested = [[1, 2], [3, 4]];
nested.flat();               // [1, 2, 3, 4]
nested.flatMap(x => x);      // [1, 2, 3, 4]

// sort - 排序（注意：默认按字符串排序）
const sorted = [3, 1, 4, 1, 5].sort((a, b) => a - b);  // [1, 1, 3, 4, 5]

// reverse - 反转
arr.reverse();  // [5, 4, 3, 2, 1]

// join - 转字符串
arr.join(", ");  // "5, 4, 3, 2, 1"
```

---

## 元组 (Tuple)

### 定义与使用

```typescript
// 固定长度，各位置类型不同
let pair: [string, number] = ["Alice", 25];
let triple: [string, number, boolean] = ["Bob", 30, true];

// 访问
const name = pair[0];  // string
const age = pair[1];   // number

// 可选元素
type OptionalTuple = [string, number?];
let t1: OptionalTuple = ["hello"];      // OK
let t2: OptionalTuple = ["hello", 42];  // OK

// 剩余元素
type StringNumberBooleans = [string, ...number[]];
let snb: StringNumberBooleans = ["hello", 1, 2, 3];

// 具名元组（TypeScript 4.0+）
type NamedTuple = [name: string, age: number, email?: string];
const person: NamedTuple = ["Alice", 25];
```

### 解构与模式匹配

```typescript
// 元组解构
const [name, age] = pair;
console.log(name, age);  // "Alice", 25

// 解构时设置默认值
const [first2, second2 = 0] = [1];

// 元组作为函数返回类型
function getMinMax(values: number[]): [number, number] {
  return [Math.min(...values), Math.max(...values)];
}

const [min, max] = getMinMax([3, 1, 4, 1, 5]);
```

---

## 枚举 (Enum)

### 数字枚举

```typescript
// 默认从 0 开始
enum Direction {
  Up,      // 0
  Down,    // 1
  Left,    // 2
  Right,   // 3
}

// 指定初始值
enum StatusCode {
  OK = 200,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  InternalServerError = 500,
}

// 反向映射
console.log(Direction[0]);   // "Up"
console.log(Direction.Up);   // 0
```

### 字符串枚举

```typescript
enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE",
}

console.log(Color.Red);  // "RED"
// 字符串枚举没有反向映射

// 异构枚举（混合类型，不推荐）
enum Mixed {
  Yes = "YES",
  No = 0,
}
```

### const 枚举

```typescript
// const 枚举在编译时内联，没有运行时对象
const enum Size {
  Small = 1,
  Medium = 2,
  Large = 3,
}

const size = Size.Medium;
// 编译为: const size = 2;
// 没有 Size 对象的运行时开销
```

### 枚举与联合类型对比

```typescript
// 枚举方式
enum Direction2 {
  Up = "UP",
  Down = "DOWN",
}

function move(d: Direction2): void {
  console.log(d);
}

// 联合类型方式（推荐，更灵活）
type Direction3 = "UP" | "DOWN";
function move2(d: Direction3): void {
  console.log(d);
}

// 何时使用枚举：
// - 需要反向映射（数字枚举）
// - 需要运行时对象
// - 需要枚举作为类型和值同时存在
```

---

## 对象 (Object)

### 对象类型注解

```typescript
// 内联对象类型
function processPoint(point: { x: number; y: number }): number {
  return Math.sqrt(point.x ** 2 + point.y ** 2);
}

// 类型别名
type Point = { x: number; y: number };

// 索引签名
type Dictionary<T = unknown> = {
  [key: string]: T;
};

const dict: Dictionary<number> = {
  a: 1,
  b: 2,
};

// 特殊属性
type SpecialObject = {
  // 可选属性
  name?: string;
  // 只读属性
  readonly id: number;
  // 方法
  greet(): string;
  // 重载方法
  add(x: number, y: number): number;
  add(x: string, y: string): string;
};
```

### 对象操作

```typescript
const user = {
  id: 1,
  name: "Alice",
  age: 25,
};

// 访问
console.log(user.name);     // "Alice"（点号）
console.log(user["name"]);  // "Alice"（方括号）

// 添加/修改
user.age = 26;
user.email = "alice@example.com";

// 删除
delete user.email;

// 检查属性
"name" in user;         // true
user.hasOwnProperty("age");  // true
Object.hasOwn(user, "age");  // true（ES2022+）

// 获取键/值/条目
const keys = Object.keys(user);      // ["id", "name", "age"]
const values = Object.values(user);  // [1, "Alice", 26]
const entries = Object.entries(user); // [["id", 1], ["name", "Alice"], ["age", 26]]

// 合并
const merged2 = Object.assign({}, user, { role: "admin" });
const merged3 = { ...user, role: "admin" };

// 冻结/密封
Object.freeze(user);  // 完全不可变
Object.seal(user);    // 不可增删，但可修改
```

---

## Map / Set

### Map

```typescript
// 创建
const map = new Map<string, number>();
const map2 = new Map([
  ["a", 1],
  ["b", 2],
  ["c", 3],
]);

// 基本操作
map.set("x", 100);
map.set("y", 200);
console.log(map.get("x"));      // 100
console.log(map.has("z"));      // false
console.log(map.size);          // 2
map.delete("x");                // true
map.clear();                    // 清空

// 遍历
for (const [key, value] of map2) {
  console.log(key, value);
}

map2.forEach((value, key) => {
  console.log(key, value);
});

// 转换为数组
const entries = [...map2.entries()];  // [["a", 1], ...]
const keys2 = [...map2.keys()];       // ["a", "b", "c"]
const values2 = [...map2.values()];   // [1, 2, 3]
```

### Set

```typescript
// 创建
const set = new Set<number>();
const set2 = new Set([1, 2, 3, 3, 4]);  // {1, 2, 3, 4} - 去重

// 基本操作
set.add(1);
set.add(2);
console.log(set.has(1));    // true
console.log(set.size);      // 2
set.delete(1);              // true
set.clear();

// 遍历
set2.forEach(value => console.log(value));
for (const value of set2) {
  console.log(value);
}

// 数组去重
const unique = [...new Set([1, 2, 2, 3, 3, 4])];  // [1, 2, 3, 4]

// 集合操作（无内置，需手动）
const a = new Set([1, 2, 3]);
const b = new Set([2, 3, 4]);

// 交集
const intersection = new Set([...a].filter(x => b.has(x)));  // {2, 3}

// 差集
const difference = new Set([...a].filter(x => !b.has(x)));  // {1}

// 并集
const union = new Set([...a, ...b]);  // {1, 2, 3, 4}
```

### WeakMap / WeakSet

```typescript
// WeakMap - 键必须是对象，弱引用（不影响 GC）
const weakMap = new WeakMap<object, string>();
const objKey = { id: 1 };
weakMap.set(objKey, "metadata");

// WeakSet
const weakSet = new WeakSet<object>();
weakSet.add(objKey);

// 用途：存储对象元数据而不影响 GC
const privateData = new WeakMap<object, { secret: string }>();

class User2 {
  constructor(name: string, secret: string) {
    privateData.set(this, { secret });
  }
  // 当 User2 实例被 GC 时，对应的 privateData 条目自动清除
}
```

---

## TypedArray / Buffer

### TypedArray（类型化数组）

```typescript
// 类型化数组用于处理二进制数据
const int8 = new Int8Array(4);     // 长度为4的有符号8位整数数组
const uint8 = new Uint8Array(4);   // 无符号8位整数
const uint8Clamped = new Uint8ClampedArray(4);  // 截断的 Uint8
const int16 = new Int16Array(4);   // 16位
const uint32 = new Uint32Array(4); // 32位
const float64 = new Float64Array(4);// 64位浮点

// 从数组创建
const arr = new Uint8Array([1, 2, 3, 4]);

// 常用操作
console.log(arr.length);   // 4
console.log(arr.byteLength); // 4 (4 bytes)
arr[0] = 255;  // 自动截断到 0-255

// ArrayBuffer
const buffer = new ArrayBuffer(16);  // 16字节缓冲区
const view1 = new Uint8Array(buffer);
const view2 = new Uint32Array(buffer);  // 以32位视角看同一缓冲区
```

---

## 数据结构对比
