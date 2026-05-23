# 第1章 TypeScript 基础语法手册

> 本手册详细介绍 TypeScript 的基础语法特性

## 目录

1. [变量声明](#变量声明)
2. [基本数据类型](#基本数据类型)
3. [类型注解与推断](#类型注解与推断)
4. [类型转换](#类型转换)
5. [运算符](#运算符)
6. [流程控制](#流程控制)
7. [字符串操作](#字符串操作)

---

## 变量声明

### TypeScript 变量声明

TypeScript 使用 `let` 和 `const` 声明变量（继承自 ES6），并支持类型注解：

```typescript
// let - 可重新赋值的变量
let name: string = "Alice";
let age: number = 25;
name = "Bob";  // 可以重新赋值

// const - 常量（不可重新赋值）
const PI: number = 3.14159;
const MAX_SIZE = 100;  // 推断为 100 字面量类型
// PI = 3.14;  // Error: Cannot assign to 'PI'

// var - 旧式声明（不推荐使用）
var oldStyle = "legacy";  // 函数作用域，有提升问题
```

### 块级作用域

TypeScript 的 `let`/`const` 具有块级作用域：

```typescript
{
  let blockVar = "inside";
  const BLOCK_CONST = "constant";
  // 仅在块内可见
}
// console.log(blockVar);  // Error: Cannot find name 'blockVar'
```

### 解构赋值

```typescript
// 数组解构
const [a, b, ...rest] = [1, 2, 3, 4, 5];
// a=1, b=2, rest=[3,4,5]

// 对象解构
const person = { name: "Alice", age: 25, city: "Beijing" };
const { name, age, ...others } = person;
// name="Alice", age=25, others={city:"Beijing"}

// 重命名 + 默认值
const { name: userName = "Anonymous" } = person;
```


---

## 基本数据类型

### TypeScript 原始类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `number` | 数字（整数+浮点数） | `42`, `3.14`, `NaN` |
| `string` | 字符串 | `"hello"`, `'world'` |
| `boolean` | 布尔值 | `true`, `false` |
| `null` | 空值 | `null` |
| `undefined` | 未定义 | `undefined` |
| `symbol` | 唯一标识符 | `Symbol("id")` |
| `bigint` | 大整数 | `100n` |
| `void` | 无返回值 | `undefined` |
| `never` | 永不返回 | 不适用 |
| `any` | 任意类型（逃逸） | `let x: any` |
| `unknown` | 未知类型（安全） | `let x: unknown` |

```typescript
// number - 统一数字类型（IEEE 754 双精度）
let num: number = 42;
let float: number = 3.14159;
let hex: number = 0xff;     // 255
let binary: number = 0b1010;  // 10
let octal: number = 0o77;     // 63
let scientific: number = 1.23e-4;

// string - 字符串
let s1: string = "double quotes";
let s2: string = 'single quotes';
let s3: string = `template literal ${num}`;  // 模板字符串

// boolean
let isValid: boolean = true;
let isReady: boolean = false;

// null 和 undefined
let n: null = null;
let u: undefined = undefined;

// bigint
let big: bigint = 9007199254740991n;

// symbol
let sym: symbol = Symbol("unique");
```

### 类型字面量

TypeScript 支持将具体值作为类型：

```typescript
// 字面量类型
let direction: "left" | "right" | "up" | "down";
direction = "left";  // OK
// direction = "back";  // Error

let status: 200 | 201 | 400 | 404;
status = 200;  // OK
```


---

## 类型注解与推断

### 显式类型注解

```typescript
// 变量注解
let name: string = "Alice";
let count: number = 0;
let items: string[] = ["a", "b", "c"];
let pair: [string, number] = ["Alice", 25];

// 函数注解
function add(a: number, b: number): number {
  return a + b;
}

// 参数默认值
function greet(name: string = "World"): string {
  return `Hello, ${name}`;
}
```

### 类型推断

TypeScript 编译器会自动推断类型，无需显式注解：

```typescript
let x = 10;           // 推断为 number
let text = "hello";   // 推断为 string
let isOk = true;      // 推断为 boolean

const PI = 3.14;      // 推断为 3.14（字面量类型）

// 返回值推断
function add(a: number, b: number) {
  return a + b;       // 推断返回类型为 number
}

// 上下文类型推断
const names = ["Alice", "Bob", "Charlie"];
names.forEach((name) => {
  // name 被推断为 string
  console.log(name.toUpperCase());
});
```


---

## 类型转换

### 显式类型转换（类型断言）

TypeScript 使用类型断言（Type Assertion）进行类型转换，编译时生效：

```typescript
// as 语法（推荐）
let value: unknown = "hello world";
let length: number = (value as string).length;

// 尖括号语法（不推荐，JSX 中冲突）
let length2: number = (<string>value).length;

// 双重断言（慎用）
let num = (value as unknown) as number;

// 非空断言
let maybeStr: string | null = getString();
let definite: string = maybeStr!;  // 断言不为 null/undefined
```

### 值类型转换（运行时）

```typescript
// 字符串转数字
let str = "42";
let num = Number(str);     // 42
let num2 = parseInt(str);  // 42
let num3 = +str;           // 42

// 数字转字符串
let n = 42;
let s1 = String(n);        // "42"
let s2 = n.toString();     // "42"
let s3 = `${n}`;           // "42"

// 布尔值转换
Boolean(0);        // false
Boolean("");       // false
Boolean(null);     // false
Boolean(undefined);// false
Boolean(NaN);      // false
Boolean("false");  // true!（非空字符串）
```


---

## 运算符

### 算术运算符

| 运算符 | TypeScript | 说明 |
|--------|------------|------|
| 加法 | `+` | 加法运算 |
| 减法 | `-` | 减法运算 |
| 乘法 | `*` | 乘法运算 |
| 除法 | `/` | 浮点除法 |
| 整数除法 | `Math.trunc(a / b)` | 取整除法 |
| 取余 | `%` | 取余运算 |
| 幂运算 | `**` | 幂运算 |
| 自增 | `++` | 自增1 |
| 自减 | `--` | 自减1 |

```typescript
let a = 10;
let b = 3;

// 算术运算
console.log(a + b);   // 13
console.log(a - b);   // 7
console.log(a * b);   // 30
console.log(a / b);   // 3.3333...
console.log(a % b);   // 1
console.log(a ** b);  // 1000

// 自增/自减
let count = 0;
count++;  // 1
count--;  // 0
```

### 比较运算符

```typescript
// 严格相等（推荐）
1 === 1;     // true
1 === "1";   // false（类型不同）
null === undefined;  // false

// 严格不等
1 !== 2;     // true

// 宽松相等（避免使用）
1 == "1";    // true!（类型转换后相等）
null == undefined;  // true!（特殊规则）

// 大小比较
5 > 3;       // true
5 <= 5;      // true
```

### 逻辑运算符

```typescript
// 逻辑与 (&&) - 返回第一个假值或最后一个值
true && "ok";            // "ok"
false && "ok";           // false
0 && "ok";               // 0

// 逻辑或 (||) - 返回第一个真值或最后一个值
true || "fallback";      // true
false || "fallback";     // "fallback"
0 || "default";          // "default"

// 逻辑非 (!)
!true;          // false
!false;         // true
!!"hello";      // true

// 空值合并 (??) - 仅对 null/undefined 回退
null ?? "default";       // "default"
undefined ?? "default";  // "default"
0 ?? "default";          // 0（0 不是 null/undefined）

// 可选链 (?.)
const user = { address: { city: "Beijing" } };
user?.address?.city;     // "Beijing"
user?.phone?.number;     // undefined（不会报错）
```


---

## 流程控制

### 条件语句

```typescript
// if / else if / else
const score = 85;

if (score >= 90) {
  console.log("优秀");
} else if (score >= 80) {
  console.log("良好");
} else if (score >= 60) {
  console.log("及格");
} else {
  console.log("不及格");
}

// 三元运算符
const status = score >= 60 ? "passed" : "failed";

// switch 语句
enum Color { Red, Green, Blue }

function getHex(c: Color): string {
  switch (c) {
    case Color.Red:
      return "#FF0000";
    case Color.Green:
      return "#00FF00";
    case Color.Blue:
      return "#0000FF";
    default:
      return "#000000";
  }
}
```

### 循环

```typescript
// for 循环
for (let i = 0; i < 5; i++) {
  console.log(i);  // 0, 1, 2, 3, 4
}

// for...of (遍历可迭代对象)
const numbers = [10, 20, 30];
for (const num of numbers) {
  console.log(num);
}

// for...in (遍历对象键)
const obj = { a: 1, b: 2, c: 3 };
for (const key in obj) {
  console.log(key, obj[key]);  // a 1, b 2, c 3
}

// while 循环
let i = 0;
while (i < 5) {
  console.log(i);
  i++;
}

// do...while
let j = 0;
do {
  console.log(j);
  j++;
} while (j < 5);

// forEach（数组方法）
[1, 2, 3].forEach((item, index) => {
  console.log(index, item);
});
```

### break / continue

```typescript
// break - 退出循环
for (const n of [1, 2, 3, 4, 5]) {
  if (n === 3) break;
  console.log(n);  // 1, 2
}

// continue - 跳过当前迭代
for (const n of [1, 2, 3, 4, 5]) {
  if (n === 3) continue;
  console.log(n);  // 1, 2, 4, 5
}

// 带标签的 break
outer: for (let i = 0; i < 3; i++) {
  for (let j = 0; j < 3; j++) {
    if (i === 1 && j === 1) break outer;
    console.log(i, j);
  }
}
```

---

## 字符串操作

### 字符串创建与基础操作

```typescript
// 创建字符串
const s1 = "hello";
const s2 = 'world';
const s3 = `hello ${s1}!`;  // 模板字符串

// 长度
console.log(s1.length);  // 5

// 访问字符
console.log(s1[0]);      // "h"
console.log(s1.at(-1));  // "o"
console.log(s1.charAt(0));  // "h"

// 大小写转换
s1.toUpperCase();  // "HELLO"
s1.toLowerCase();  // "hello"
```

### 字符串搜索

```typescript
const str = "Hello, TypeScript!";

// 包含检查
str.includes("Type");      // true
str.startsWith("Hello");   // true
str.endsWith("!");         // true

// 搜索位置
str.indexOf("e");          // 1
str.lastIndexOf("e");      // 13（最后一个匹配）
str.search(/Script/);      // 11（支持正则）

// 正则匹配
str.match(/[A-Z]\w+/g);    // ["Hello", "TypeScript"]
str.replace("TypeScript", "Python");  // "Hello, Python!"
```

### 字符串截取与分割

```typescript
const str = "Hello, TypeScript";

// 截取
str.slice(0, 5);      // "Hello"
str.slice(7);         // "TypeScript"
str.slice(-6);        // "Script"（支持负数）

str.substring(0, 5);  // "Hello"
str.substr(7, 4);     // "Type"（deprecated）

// 分割
"a,b,c".split(",");   // ["a", "b", "c"]
"hello world".split(" ");  // ["hello", "world"]

// 拼接
"Hello".concat(", ", "World");  // "Hello, World"
["Hello", "World"].join(" ");   // "Hello World"

// 去除空白
"  hello  ".trim();       // "hello"
"  hello  ".trimStart();  // "hello  "
"  hello  ".trimEnd();    // "  hello"
```

### 模板字符串

```typescript
const name = "Alice";
const age = 25;

// 模板字面量（反引号）
const greeting = `Hello, I'm ${name}, ${age} years old.`;
// "Hello, I'm Alice, 25 years old."

// 多行字符串
const multiline = `
  Line 1
  Line 2
  Line 3
`;

// 带标签的模板
function tag(strings: TemplateStringsArray, ...values: unknown[]) {
  return strings.reduce((result, str, i) => {
    return result + str + (values[i] ?? "");
  }, "");
}
const result = tag`Hello ${name}! Today is ${new Date()}`;
```


