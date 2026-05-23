# 第7章 TypeScript 泛型编程手册

> 本手册详细介绍 TypeScript 泛型编程的核心概念

## 目录

1. [泛型基础](#泛型基础)
2. [泛型函数](#泛型函数)
3. [泛型接口](#泛型接口)
4. [泛型类](#泛型类)
5. [泛型约束](#泛型约束)
6. [条件类型](#条件类型)
7. [映射类型](#映射类型)
8. [模板字面量类型](#模板字面量类型)
9. [内置泛型工具类型](#内置泛型工具类型)
10. [实战模式](#实战模式)

---

## 泛型基础

### 为什么需要泛型

```typescript
// 不使用泛型：类型丢失
function identityWithout(value: any): any {
  return value;
}

// 使用泛型：保留类型信息
function identity<T>(value: T): T {
  return value;
}

const num = identity(42);      // num: number
const str = identity("hello"); // str: string
const obj = identity({ x: 1 }); // obj: { x: number }
```

### 类型参数命名约定

| 参数 | 常见含义 |
|------|----------|
| `T` | Type（通用类型） |
| `K` | Key（键类型） |
| `V` | Value（值类型） |
| `E` | Element（元素类型） |
| `R` | Return（返回类型） |
| `P` | Parameters（参数类型） |

### Python 对比

```python
# Python 3.12+ 泛型语法
def identity[T](value: T) -> T:
    return value

# Python 3.11 及更早
from typing import TypeVar

T = TypeVar("T")

def identity(value: T) -> T:
    return value

# Python 的类型变量 vs TypeScript 的类型参数
# 概念相同，但 TypeScript 语法更简洁
```

---

## 泛型函数

### 基本泛型函数

```typescript
// 单类型参数
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

const firstNum = first([1, 2, 3]);     // number | undefined
const firstStr = first(["a", "b"]);    // string | undefined

// 多类型参数
function pair<T, U>(first: T, second: U): [T, U] {
  return [first, second];
}

const p1 = pair("hello", 42);     // [string, number]
const p2 = pair(1, true);         // [number, boolean]

// 默认类型参数
function createArray<T = string>(length: number, value: T): T[] {
  return Array(length).fill(value);
}

const arr1 = createArray(3, "x");  // string[]
const arr2 = createArray<number>(3, 5);  // number[]
```

### 泛型箭头函数

```typescript
// 箭头函数泛型
const identity2 = <T>(value: T): T => value;

// 在 JSX 中可能需要约束
const identity3 = <T extends unknown>(value: T): T => value;

// 泛型高阶函数
const wrapInArray = <T>(value: T): T[] => [value];

const mapArray = <T, U>(arr: T[], fn: (item: T) => U): U[] => arr.map(fn);
```

### 泛型函数重载

```typescript
// 泛型重载
function merge<T, U>(obj1: T, obj2: U): T & U;
function merge<T, U, V>(obj1: T, obj2: U, obj3: V): T & U & V;
function merge(...objs: Record<string, unknown>[]): Record<string, unknown> {
  return Object.assign({}, ...objs);
}
```

### Python 对比

```python
from typing import TypeVar, Sequence

T = TypeVar("T")
U = TypeVar("U")

def first(arr: Sequence[T]) -> T | None:
    return arr[0] if arr else None

def pair(first: T, second: U) -> tuple[T, U]:
    return (first, second)

# Python 3.12+
def create_array[T: str = str](length: int, value: T) -> list[T]:
    return [value] * length

# Python 不支持函数重载（使用 @overload 仅类型检查）
```

---

## 泛型接口

### 泛型接口基础

```typescript
// 泛型接口
interface Repository<T> {
  getById(id: string): T | undefined;
  getAll(): T[];
  create(item: T): T;
  update(id: string, item: Partial<T>): T;
  delete(id: string): boolean;
}

// 实现泛型接口
class UserRepository implements Repository<User> {
  private users: User[] = [];

  getById(id: string): User | undefined {
    return this.users.find(u => u.id === id);
  }

  getAll(): User[] {
    return [...this.users];
  }

  create(item: User): User {
    this.users.push(item);
    return item;
  }

  update(id: string, item: Partial<User>): User {
    const index = this.users.findIndex(u => u.id === id);
    this.users[index] = { ...this.users[index], ...item };
    return this.users[index];
  }

  delete(id: string): boolean {
    const index = this.users.findIndex(u => u.id === id);
    if (index >= 0) {
      this.users.splice(index, 1);
      return true;
    }
    return false;
  }
}
```

### 泛型接口模式

```typescript
// 泛型工厂接口
interface Factory<T> {
  create(...args: unknown[]): T;
}

// 泛型比较器
interface Comparator<T> {
  compare(a: T, b: T): number;
}

const numberComparator: Comparator<number> = {
  compare: (a, b) => a - b,
};

// 泛型选项模式
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

interface PaginatedResponse<T> extends ApiResponse<T[]> {
  total: number;
  page: number;
  pageSize: number;
}
```

---

## 泛型类

### 泛型类基本语法

```typescript
class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1];
  }

  get size(): number {
    return this.items.length;
  }

  isEmpty(): boolean {
    return this.items.length === 0;
  }
}

const numberStack = new Stack<number>();
numberStack.push(1);
numberStack.push(2);
console.log(numberStack.pop());  // 2

const stringStack = new Stack<string>();
stringStack.push("hello");
```

### 泛型类约束

```typescript
interface HasId {
  id: string;
}

class EntityManager<T extends HasId> {
  private entities = new Map<string, T>();

  add(entity: T): void {
    this.entities.set(entity.id, entity);
  }

  get(id: string): T | undefined {
    return this.entities.get(id);
  }

  getAll(): T[] {
    return [...this.entities.values()];
  }
}

// T 必须是 HasId 的子类型
class User4 implements HasId {
  constructor(
    public id: string,
    public name: string
  ) {}
}

const userManager = new EntityManager<User4>();
userManager.add(new User4("1", "Alice"));
```

### 泛型类的静态成员

```typescript
// 注意：类的静态成员不能使用类型参数
class Collection<T> {
  // static defaultItem: T;  // Error: 静态成员不能引用类型参数
  static create<T>(): Collection<T> {  // 但静态方法可以有独立的泛型
    return new Collection<T>();
  }
}
```

### Python 对比

```python
from typing import Generic, TypeVar, Optional

T = TypeVar("T")

class Stack(Generic[T]):
    def __init__(self):
        self._items: list[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> Optional[T]:
        return self._items.pop() if self._items else None
    
    @property
    def size(self) -> int:
        return len(self._items)

# Python 使用 Generic[T] 继承实现泛型类
# TypeScript 使用 class ClassName<T>
```

---

## 泛型约束

### extends 约束

```typescript
// 基本约束
function getLength<T extends { length: number }>(item: T): number {
  return item.length;
}

getLength("hello");       // 5（string 有 length）
getLength([1, 2, 3]);     // 3（array 有 length）
// getLength(42);          // Error: number 没有 length

// 联合类型约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user5 = { name: "Alice", age: 25, email: "a@b.com" };
const name2 = getProperty(user5, "name");  // string
// getProperty(user5, "ssn");  // Error: "ssn" 不在 keyof 中
```

### 多约束与类型参数

```typescript
// 多个类型参数之间的约束
function getPropertyValue<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// 条件约束
interface Lengthwise {
  length: number;
}

function longer<T extends Lengthwise, U extends Lengthwise>(a: T, b: U): T | U {
  return a.length >= b.length ? a : b;
}

longer("hello", [1, 2, 3]);  // string | number[]

// 自引用约束
interface Comparable<T> {
  compareTo(other: T): number;
}

function max<T extends Comparable<T>>(a: T, b: T): T {
  return a.compareTo(b) >= 0 ? a : b;
}
```

### 使用 new 约束（工厂函数）

```typescript
// 约束为可构造的
function createInstance<T>(ctor: new (...args: any[]) => T, ...args: any[]): T {
  return new ctor(...args);
}

class Animal2 {
  constructor(public name: string) {}
}

const dog2 = createInstance(Animal2, "Rex");
// dog2: Animal2
```

### Python 对比

```python
from typing import TypeVar, Protocol

# Python 使用 Protocol 实现类型约束
class HasLength(Protocol):
    length: int

T = TypeVar("T", bound=HasLength)

def get_length(item: T) -> int:
    return item.length

# Python 3.12+ 约束语法
def longer[T: HasLength, U: HasLength](a: T, b: U) -> T | U:
    return a if a.length >= b.length else b

# Python 没有 keyof 操作符
# 使用 typing 模块的 get_type_hints 替代
```

---

## 条件类型

### 基本条件类型

```typescript
// T extends U ? X : Y
type IsString<T> = T extends string ? true : false;

type A = IsString<"hello">;  // true
type B = IsString<42>;       // false
type C = IsString<string>;   // true

// 分布式条件类型
type ToArray<T> = T extends unknown ? T[] : never;

type D = ToArray<string | number>;
// string[] | number[]（分布式：分别应用条件）
```

### 条件类型实战

```typescript
// 提取函数返回类型
type ReturnTypeOf<T> = T extends (...args: any[]) => infer R ? R : never;

type Fn1 = ReturnTypeOf<() => string>;     // string
type Fn2 = ReturnTypeOf<(x: number) => boolean>;  // boolean

// 提取函数参数
type ParametersOf<T> = T extends (...args: infer P) => any ? P : never;

type Params = ParametersOf<(name: string, age: number) => void>;
// [name: string, age: number]

// 提取 Promise 内部类型
type Unwrap<T> = T extends Promise<infer U> ? U : T;

type P1 = Unwrap<Promise<string>>;   // string
type P2 = Unwrap<string>;            // string（不是 Promise 则原样返回）
type P3 = Unwrap<Promise<Promise<number>>>;
// Promise<number>（只解一层）
```

### 递归条件类型

```typescript
// 展平数组
type Flatten<T> = T extends any[] 
  ? T extends [infer First, ...infer Rest]
    ? [...Flatten<First>, ...Flatten<Rest>]
    : []
  : [T];

type Flat1 = Flatten<[1, [2, [3]]]>;  // [1, 2, 3]

// 深层只读
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object
    ? T[K] extends Function
      ? T[K]
      : DeepReadonly<T[K]>
    : T[K];
};

// 链式 Promise 解包
type DeepAwaited<T> = T extends Promise<infer U> 
  ? DeepAwaited<U> 
  : T;

type Resolved = DeepAwaited<Promise<Promise<string>>>;  // string
```

### Python 对比

```python
# Python 没有条件类型
# 使用 @overload 或 isinstance 运行时判断

# Python 3.12+ 的类型参数支持简单条件
from typing import overload

@overload
def process(value: str) -> str: ...
@overload
def process(value: int) -> float: ...

def process(value: str | int) -> str | float:
    if isinstance(value, str):
        return value.upper()
    return value * 1.0

# TypeScript 的条件类型在编译时计算
# Python 的条件在运行时通过重载实现
```

---

## 映射类型

### 基本映射类型

```typescript
// 映射类型：基于已有类型生成新类型
type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

interface User6 {
  id: number;
  name: string;
  email: string;
}

type NullableUser = Nullable<User6>;
// { id: number | null; name: string | null; email: string | null }

// 带修饰符的映射
type Readonly2<T> = {
  readonly [P in keyof T]: T[P];
};

type Optional<T> = {
  [P in keyof T]?: T[P];
};

type ReadonlyOptional<T> = {
  readonly [P in keyof T]?: T[P];
};
```

### 修饰符控制

```typescript
// 移除 readonly
type Mutable<T> = {
  -readonly [P in keyof T]: T[P];
};

// 移除可选
type Concrete<T> = {
  [P in keyof T]-?: T[P];
};

// 结合使用
type CreateMutable<T> = {
  -readonly [P in keyof T]: T[P];
};

type CreateConcrete<T> = {
  [P in keyof T]-?: T[P];
};
```

### as 子句（键重映射）

```typescript
// TypeScript 4.1+ 键重映射
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person7 {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person7>;
// { getName: () => string; getAge: () => number }

// 过滤键
type RemoveKindField<T> = {
  [K in keyof T as Exclude<K, "kind">]: T[K];
};

interface Circle3 {
  kind: "circle";
  radius: number;
}

type NoKindCircle = RemoveKindField<Circle3>;
// { radius: number }

// 所有值类型转为字符串
type Stringify<T> = {
  [K in keyof T]: string;
};
```

### 映射类型实战

```typescript
// 选择部分属性
type Pick2<T, K extends keyof T> = {
  [P in K]: T[P];
};

// 排除部分属性
type Omit2<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;

// 函数化属性
type FunctionPropertyNames<T> = {
  [K in keyof T]: T[K] extends Function ? K : never;
}[keyof T];

type FunctionProperties<T> = Pick<T, FunctionPropertyNames<T>>;

// 基于值的类型过滤
type ExtractProperties<T, U> = {
  [K in keyof T]: T[K] extends U ? K : never;
}[keyof T];
```

### Python 对比

```python
# Python 没有映射类型
# 使用 dataclass 和 TypeVar 模拟

from dataclasses import dataclass, field
from typing import Optional

@dataclass
class User:
    id: int
    name: str
    email: str

# 手动创建新类型
@dataclass
class NullableUser:
    id: Optional[int]
    name: Optional[str]
    email: Optional[str]
```

---

## 模板字面量类型

### 基本语法

```typescript
// TypeScript 4.1+
type EventName = `on${Capitalize<string>}`;
type Handler = `handle${string}`;
type CSSUnit = `${number}px` | `${number}em` | `${number}%`;

type Greeting = `Hello, ${string}!`;
// 所有以 "Hello, " 开头、以 "!" 结尾的字符串

// 联合类型展开
type Direction4 = "top" | "bottom" | "left" | "right";
type Margin = `margin-${Direction4}`;
// "margin-top" | "margin-bottom" | "margin-left" | "margin-right"
```

### 模板字面量与类型转换

```typescript
// 内置大写转换
type LowercaseEvent = `on${Lowercase<"Click" | "Hover">}`;
// "onclick" | "onhover"

type UppercaseEvent = `on${Uppercase<"click" | "hover">}`;
// "onCLICK" | "onHOVER"

type CapitalizeEvent = `on${Capitalize<"click" | "hover">}`;
// "onClick" | "onHover"

type UncapitalizeEvent = `on${Uncapitalize<"Click" | "Hover">}`;
// "onclick" | "onhover"
```

### 模板字面量提取

```typescript
// 从模板中提取（使用 infer）
type ExtractName<T extends string> = 
  T extends `Hello, ${infer Name}!` ? Name : never;

type Name3 = ExtractName<"Hello, Alice!">;  // "Alice"
type Name4 = ExtractName<"Hi, Bob!">;       // never（不匹配模式）

// 解析 CSS 值
type ParseCSS<T extends string> =
  T extends `${infer Value}px` ? { value: number; unit: "px" }
  : T extends `${infer Value}em` ? { value: number; unit: "em" }
  : never;

type Parsed = ParseCSS<"16px">;  // { value: number; unit: "px" }
```

### 实战：类型安全事件系统

```typescript
type EventTypes = "click" | "hover" | "focus" | "blur";
type EventHandler = `on${Capitalize<EventTypes>}`;
// "onClick" | "onHover" | "onFocus" | "onBlur"

type EventHandlers = {
  [K in EventHandler as Uncapitalize<K> extends infer E
    ? E extends string ? `handle${Capitalize<E>}` : never
    : never
  ]: (event: Event) => void;
};

// 类型安全的 CSS 类名
type Component = "button" | "input" | "label";
type Variant = "primary" | "secondary" | "danger";
type Size = "sm" | "md" | "lg";

type ClassName = `${Component}-${Variant}-${Size}`;
// "button-primary-sm" | "button-primary-md" | ...
```

### Python 对比

```python
# Python 没有模板字面量类型
# 运行时使用 f-string 和 enum 模拟

from enum import Enum
from typing import Literal

class Direction(Enum):
    TOP = "top"
    BOTTOM = "bottom"

# 使用 Literal 联合（需要手动列出所有值）
Margin = Literal[
    "margin-top", "margin-bottom",
    "margin-left", "margin-right"
]
```

---

## 内置泛型工具类型

| 工具类型 | 说明 | 示例 |
|----------|------|------|
| `Partial<T>` | 所有属性可选 | `Partial<Config>` |
| `Required<T>` | 所有属性必填 | `Required<Config>` |
| `Readonly<T>` | 所有属性只读 | `Readonly<State>` |
| `Pick<T, K>` | 选取指定属性 | `Pick<User, 'id' | 'name'>` |
| `Omit<T, K>` | 排除指定属性 | `Omit<User, 'password'>` |
| `Record<K, V>` | 构造对象类型 | `Record<string, number>` |
| `Exclude<T, U>` | 从联合中排除 | `Exclude<'a'|'b', 'a'>` |
| `Extract<T, U>` | 从联合中提取 | `Extract<'a'|'b', 'a'>` |
| `NonNullable<T>` | 排除 null/undefined | `NonNullable<string|null>` |
| `ReturnType<T>` | 函数返回类型 | `ReturnType<typeof fn>` |
| `Parameters<T>` | 函数参数类型 | `Parameters<typeof fn>` |
| `Awaited<T>` | 解包 Promise | `Awaited<Promise<string>>` |

---

## 实战模式

### 类型安全的 Builder 模式

```typescript
class QueryBuilder<T extends Record<string, unknown>> {
  private conditions: string[] = [];

  where<K extends keyof T & string>(
    key: K,
    operator: "=" | ">" | "<" | ">=" | "<=" | "!=",
    value: T[K]
  ): this {
    this.conditions.push(`${key} ${operator} ${value}`);
    return this;
  }

  build(): string {
    return `SELECT * FROM table WHERE ${this.conditions.join(" AND ")}`;
  }
}

interface User8 {
  id: number;
  name: string;
  age: number;
}

const query = new QueryBuilder<User8>()
  .where("age", ">", 18)
  .where("name", "="", "Alice")
  .build();
```

### 类型安全的 API 响应处理

```typescript
type ApiResult<T> = 
  | { status: "success"; data: T }
  | { status: "error"; error: string }
  | { status: "loading" };

async function fetchApi<T>(url: string): Promise<ApiResult<T>> {
  try {
    const res = await fetch(url);
    if (!res.ok) {
      return { status: "error", error: `HTTP ${res.status}` };
    }
    const data = await res.json() as T;
    return { status: "success", data };
  } catch (e) {
    return { status: "error", error: String(e) };
  }
}

// 使用
const result = await fetchApi<User[]>("/api/users");
if (result.status === "success") {
  console.log(result.data.map(u => u.name));
}
```

### 类型安全的事件发射器

```typescript
type EventMap = {
  userCreated: { id: number; name: string };
  userDeleted: { id: number };
  error: { message: string; code: number };
};

class TypedEmitter<T extends Record<string, unknown>> {
  private handlers = new Map<keyof T, Set<Function>>();

  on<K extends keyof T>(event: K, handler: (data: T[K]) => void): void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    this.handlers.get(event)!.add(handler);
  }

  emit<K extends keyof T>(event: K, data: T[K]): void {
    this.handlers.get(event)?.forEach(handler => handler(data));
  }

  off<K extends keyof T>(event: K, handler: (data: T[K]) => void): void {
    this.handlers.get(event)?.delete(handler);
  }
}

const emitter = new TypedEmitter<EventMap>();
emitter.on("userCreated", (data) => {
  console.log(data.name);  // data 类型安全
});
```
