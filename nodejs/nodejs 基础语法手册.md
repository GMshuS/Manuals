# Node.js 基础语法手册

> 本手册对比 Python 语言，详细介绍 Node.js (JavaScript) 的基础语法特性

## 目录

1. [变量与常量](#变量与常量)
2. [基本数据类型](#基本数据类型)
3. [类型转换](#类型转换)
4. [运算符](#运算符)
5. [流程控制](#流程控制)
6. [字符串操作](#字符串操作)

---

## 变量与常量

### Node.js 变量声明

JavaScript 使用 `let` 和 `const` 声明变量（ES6+）：

```javascript
// let - 可重新赋值
let name = "Alice";
let age = 25;
name = "Bob";  // 可以重新赋值

// const - 常量（不可重新赋值）
const PI = 3.14159;
const MAX_SIZE = 100;
// PI = 3.14;  // TypeError!

// var - 旧式声明（不推荐使用）
var oldStyle = "legacy";  // 函数作用域，有提升问题
```

### Python 语言对比

```python
# Python 使用动态类型，变量无需显式声明
name = "Alice"
age = 25
name = "Bob"  # 可以重新赋值

# 常量（命名约定：全大写）
PI = 3.14159
MAX_SIZE = 100
```

### 变量作用域

```javascript
// 块级作用域（let/const）
{
    let blockVar = "inside";
    const BLOCK_CONST = "constant";
    console.log(blockVar);  // "inside"
}
// console.log(blockVar);  // ReferenceError!

// 函数作用域
function myFunction() {
    var functionVar = "visible in function";
    let functionLet = "also visible";
}
```

### Python 语言对比

```python
# Python 使用缩进定义作用域
if True:
    block_var = "visible outside block"  # Python 没有块级作用域
print(block_var)  # 可以访问

# 函数作用域
def my_function():
    local_var = "visible in function"
```

### 解构赋值

```javascript
// 数组解构
const [x, y, z] = [1, 2, 3];
const [first, ...rest] = [1, 2, 3, 4, 5];  // first=1, rest=[2,3,4,5]

// 对象解构
const person = { name: "Alice", age: 25 };
const { name, age } = person;
const { name: userName, age: userAge } = person;  // 重命名

// 默认值
const [a = 1, b = 2] = [undefined, 5];  // a=1, b=5
```

### Python 语言对比

```python
# Python 也支持解包
x, y, z = 1, 2, 3
first, *rest = [1, 2, 3, 4, 5]

# 字典解包
person = {"name": "Alice", "age": 25}
name = person["name"]
# Python 3.10+ 支持匹配模式
```

---

## 基本数据类型

### JavaScript 内置类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `number` | 数字（整数和浮点数） | `42`, `3.14`, `-0` |
| `bigint` | 大整数 | `123n`, `BigInt(100)` |
| `string` | 字符串 | `"hello"`, `'world'` |
| `boolean` | 布尔值 | `true`, `false` |
| `null` | 空值 | `null` |
| `undefined` | 未定义 | `undefined` |
| `symbol` | 唯一标识 | `Symbol('id')` |
| `object` | 对象 | `{}`, `[]`, `function(){}` |

```javascript
// 数字
let num = 42;
let floatNum = 3.14;
let scientific = 1.23e10;
let infinity = Infinity;
let nan = NaN;  // Not a Number

// BigInt（大整数）
let bigInt = 123456789012345678901234567890n;
let bigFromNum = BigInt(100);

// 字符串
let str1 = "double quotes";
let str2 = 'single quotes';
let str3 = `template literal ${num}`;

// 布尔值
let isTrue = true;
let isFalse = false;

// null 和 undefined
let empty = null;      // 显式空值
let notDefined;        // undefined（未初始化）
console.log(notDefined);  // undefined

// Symbol（唯一标识）
let id = Symbol('user-id');
let id2 = Symbol('user-id');
console.log(id === id2);  // false
```

### Python 语言对比

```python
# Python 的基本类型
num = 42                # int
float_num = 3.14        # float
complex_num = 3 + 4j    # complex
text = "hello"          # str
is_true = True          # bool
is_false = False
empty = None            # NoneType（类似 null）
# Python 没有 undefined，没有内置 Symbol
```

### typeof 运算符

```javascript
typeof 42           // "number"
typeof "hello"      // "string"
typeof true         // "boolean"
typeof undefined    // "undefined"
typeof null         // "object" (历史遗留 bug)
typeof {}           // "object"
typeof []           // "object" (数组也是对象)
typeof function(){} // "function"
typeof 123n         // "bigint"
typeof Symbol()     // "symbol"
```

### Python 语言对比

```python
type(42)            # <class 'int'>
type("hello")       # <class 'str'>
type(True)          # <class 'bool'>
type(None)          # <class 'NoneType'>
type([])            # <class 'list'>
type({})            # <class 'dict'>
```

---

## 类型转换

### JavaScript 类型转换

```javascript
// 转为数字
Number("42")        // 42
Number("3.14")      // 3.14
Number("abc")       // NaN
+"42"               // 42（一元加号）
parseInt("42px")    // 42
parseFloat("3.14kg") // 3.14

// 转为字符串
String(123)         // "123"
String(true)        // "true"
String(null)        // "null"
(123).toString()    // "123"
`template ${123}`   // "template 123"

// 转为布尔值
Boolean(1)          // true
Boolean(0)          // false
Boolean("")         // false（空字符串）
Boolean(" ")        // true（非空字符串）
Boolean(null)       // false
Boolean(undefined)  // false
Boolean([])         // true（空数组也是 true）
Boolean({})         // true（空对象也是 true）

// 隐式转换
"5" + 3             // "53"（字符串连接）
"5" - 3             // 2（数学运算）
"5" * 2             // 10
"5" / 2             // 2.5
```

### Python 语言对比

```python
# Python 类型转换
int("42")           # 42
float("3.14")       # 3.14
str(123)            # "123"
bool(1)             # True
bool(0)             # False
bool("")            # False
bool(" ")           # True
list("abc")         # ['a', 'b', 'c']
tuple([1, 2, 3])    # (1, 2, 3)
```

### 类型检查

```javascript
// typeof
typeof 42 === "number"

// instanceof（检查对象原型链）
[] instanceof Array    // true
{} instanceof Object   // true

// Array.isArray()
Array.isArray([])      // true
Array.isArray({})      // false

// Number.isNaN()
Number.isNaN(NaN)      // true
Number.isNaN(0/0)      // true

// 检查 null 或 undefined
value === null         // 只检查 null
value == null          // 检查 null 或 undefined
value === undefined    // 只检查 undefined
```

---

## 运算符

### 算术运算符

```javascript
let a = 10, b = 3;

a + b    // 加法：13
a - b    // 减法：7
a * b    // 乘法：30
a / b    // 除法：3.333...
a % b    // 取模（余数）：1
a ** b   // 幂运算：1000
a++      // 后置递增
++a      // 前置递增
a--      // 后置递减
--a      // 前置递减

// 特殊数字运算
1 / 0           // Infinity
-1 / 0          // -Infinity
0 / 0           // NaN
Math.floor(10/3) // 3（整除）
```

### Python 语言对比

```python
a, b = 10, 3

a + b    # 加法：13
a - b    # 减法：7
a * b    # 乘法：30
a / b    # 除法：3.333...
a // b   # 整除：3
a % b    # 取模：1
a ** b   # 幂运算：1000
# Python 没有 ++ 和 -- 运算符
```

### 比较运算符

```javascript
let a = 5, b = "5";

a == b    // 相等（宽松）：true（会类型转换）
a === b   // 严格相等：false（不类型转换）
a != b    // 不相等（宽松）：false
a !== b   // 严格不相等：true
a > b     // 大于：false
a < b     // 小于：false
a >= b    // 大于等于：true
a <= b    // 小于等于：true

// 推荐使用 === 和 !==
```

### Python 语言对比

```python
a, b = 5, "5"
# a == b  # TypeError! Python 不会自动转换类型
a == 5    # True
a != 5    # False
a > 3     # True

# Python 支持链式比较
1 < a < 10  # True
```

### 逻辑运算符

```javascript
// JavaScript 使用符号
let a = true, b = false;

a && b    // 与：false
a || b    // 或：true
!a        // 非：false

// 短路求值
let user = null;
let name = user && user.name;     // null（短路）
let userName = user || "Guest";   // "Guest"

// 空值合并运算符（ES2020）
let value = null ?? "default";    // "default"
let zero = 0 ?? 10;               // 0（0 不是 null/undefined）

// 可选链（ES2020）
let city = user?.address?.city;   // 如果 user 或 address 为 null/undefined，返回 undefined
```

### Python 语言对比

```python
# Python 使用英文单词
a and b   # 与
a or b    # 或
not a     # 非

# 短路求值
name = user and user.name
userName = user or "Guest"

# Python 没有 ?? 运算符，使用 or
value = None or "default"  # "default"
```

### 位运算符

```javascript
let a = 5, b = 3;

a & b    // 按位与：1  (0101 & 0011 = 0001)
a | b    // 按位或：7  (0101 | 0011 = 0111)
a ^ b    // 按位异或：4 (0101 ^ 0011 = 0100)
~a       // 按位取反：-6
a << 1   // 左移：10  (0101 << 1 = 1010)
a >> 1   // 右移：2   (0101 >> 1 = 0010)
a >>> 1  // 无符号右移：2
```

### 赋值运算符

```javascript
let a = 10;

a += 5    // a = a + 5 = 15
a -= 3    // a = a - 3 = 12
a *= 2    // a = a * 2 = 24
a /= 4    // a = a / 4 = 6
a %= 4    // a = a % 4 = 2
a **= 2   // a = a ** 2 = 4
a &= 3    // a = a & 3
a |= 3    // a = a | 3
a ^= 3    // a = a ^ 3
a <<= 2   // a = a << 2
a >>= 2   // a = a >> 2
```

### 三元运算符

```javascript
// 条件表达式
let age = 20;
let status = age >= 18 ? "adult" : "minor";

// 嵌套三元
let score = 85;
let grade = score >= 90 ? 'A' : score >= 80 ? 'B' : 'C';
```

### Python 语言对比

```python
# Python 的三元表达式
age = 20
status = "adult" if age >= 18 else "minor"
```

### typeof 和 in 运算符

```javascript
// typeof（见类型检查部分）
typeof "hello"  // "string"

// in - 检查属性是否存在
"name" in { name: "Alice" }  // true
"length" in []               // true

// instanceof
[] instanceof Array  // true
{} instanceof Object // true
```

---

## 流程控制

### if-else 语句

```javascript
let age = 18;

if (age < 12) {
    console.log("儿童");
} else if (age < 18) {
    console.log("青少年");
} else if (age < 60) {
    console.log("成年人");
} else {
    console.log("老年人");
}

// 三元表达式
let status = age >= 18 ? "成年" : "未成年";
```

### Python 语言对比

```python
age = 18

if age < 12:
    print("儿童")
elif age < 18:
    print("青少年")
elif age < 60:
    print("成年人")
else:
    print("老年人")

# 三元表达式
status = "成年" if age >= 18 else "未成年"
```

### switch 语句

```javascript
let day = 3;
let dayName;

switch (day) {
    case 1:
        dayName = "Monday";
        break;
    case 2:
        dayName = "Tuesday";
        break;
    case 3:
        dayName = "Wednesday";
        break;
    case 4:
    case 5:
        dayName = "Weekday";
        break;
    default:
        dayName = "Weekend";
}

// 注意：JavaScript 没有 Python 的 match-case（直到最新提案）
```

### Python 语言对比

```python
# Python 3.10+ 的 match-case
day = 3
match day:
    case 1:
        dayName = "Monday"
    case 2:
        dayName = "Tuesday"
    case 3:
        dayName = "Wednesday"
    case 4 | 5:
        dayName = "Weekday"
    case _:
        dayName = "Weekend"
```

### for 循环

```javascript
// 传统 for 循环
for (let i = 0; i < 5; i++) {
    console.log(i);  // 0, 1, 2, 3, 4
}

// for...of（遍历可迭代对象）
const arr = ["a", "b", "c"];
for (const item of arr) {
    console.log(item);  // "a", "b", "c"
}

// for...in（遍历对象属性）
const obj = { a: 1, b: 2, c: 3 };
for (const key in obj) {
    console.log(key, obj[key]);  // "a" 1, "b" 2, "c" 3
}

// forEach（数组方法）
arr.forEach((item, index) => {
    console.log(`${index}: ${item}`);
});
```

### Python 语言对比

```python
# Python for 循环
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

# 遍历列表
arr = ["a", "b", "c"]
for item in arr:
    print(item)

# 带索引遍历
for i, item in enumerate(arr):
    print(f"{i}: {item}")

# 遍历字典
obj = {"a": 1, "b": 2, "c": 3}
for key, value in obj.items():
    print(key, value)
```

### while 循环

```javascript
let count = 0;
while (count < 5) {
    console.log(count);
    count++;
}

// do...while（至少执行一次）
let i = 0;
do {
    console.log(i);
    i++;
} while (i < 5);

// break 和 continue
for (let i = 0; i < 10; i++) {
    if (i === 3) continue;  // 跳过
    if (i === 8) break;     // 退出循环
    console.log(i);
}

// 标签循环（用于跳出嵌套循环）
outer: for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 3; j++) {
        if (i === 1 && j === 1) break outer;
        console.log(`${i},${j}`);
    }
}
```

### Python 语言对比

```python
# Python while 循环
count = 0
while count < 5:
    print(count)
    count += 1

# Python 没有 do...while

# break 和 continue
for i in range(10):
    if i == 3:
        continue
    if i == 8:
        break
    print(i)

# Python 没有标签循环，使用函数或标志变量
```

### 异常处理中的流程控制

```javascript
try {
    for (let i = 0; i < 5; i++) {
        if (i === 3) throw new Error("Error at 3");
        console.log(i);
    }
} catch (error) {
    console.error(error.message);
} finally {
    console.log("Always executed");
}
```

---

## 字符串操作

### 字符串定义

```javascript
// 单引号和双引号
let str1 = 'single quotes';
let str2 = "double quotes";

// 模板字符串（ES6+）
let name = "Alice";
let age = 25;
let message = `Hello, ${name}! You are ${age} years old.`;

// 多行字符串
let multiLine = `Line 1
Line 2
Line 3`;

// 原始字符串（不转义）
let path = String.raw`C:\Users\${name}`;
```

### Python 语言对比

```python
# Python 字符串
str1 = 'single quotes'
str2 = "double quotes"
str3 = '''multi
line'''

# f-string（Python 3.6+）
message = f"Hello, {name}! You are {age} years old."

# 原始字符串
path = r"C:\Users\name"
```

### 字符串索引和切片

```javascript
let str = "Hello, World!";

str[0]        // 'H'
str[-1]       // '!' (ES2022 支持，旧版本返回 undefined)
str.length    // 13

str.slice(0, 5)    // "Hello"
str.slice(7)       // "World!"
str.slice(-6, -1)  // "World"
str.substring(0, 5) // "Hello" (不支持负索引)

str.substr(7, 5)   // "World" (已废弃)

// 扩展运算符
[..."hello"]  // ['h', 'e', 'l', 'l', 'o']
```

### Python 语言对比

```python
str = "Hello, World!"

str[0]        # 'H'
str[-1]       # '!'
len(str)      # 13

str[0:5]      # "Hello"
str[7:]       # "World!"
str[-6:-1]    # "World"
str[::2]      # "Hlo ol!"
str[::-1]     # "!dlroW ,olleH"
```

### 常用字符串方法

```javascript
let str = "  Hello, World!  ";

// 大小写转换
str.toLowerCase()      // "  hello, world!  "
str.toUpperCase()      // "  HELLO, WORLD!  "

// 去除空白
str.trim()             // "Hello, World!"
str.trimStart()        // "Hello, World!  "
str.trimEnd()          // "  Hello, World!"

// 查找
str.indexOf("World")   // 10
str.lastIndexOf("o")   // 8
str.includes("World")  // true
str.startsWith("Hello") // false (有空格)
str.endsWith("!")      // true

// 提取
str.slice(0, 5)        // "  Hel"
str.substring(0, 5)    // "  Hel"

// 分割和连接
"hello world".split(" ")      // ["hello", "world"]
"a,b,c".split(",")            // ["a", "b", "c"]
["a", "b", "c"].join("-")     // "a-b-c"
["a", "b", "c"].join("")      // "abc"

// 替换
str.replace("World", "JavaScript")  // "  Hello, JavaScript!  "
str.replaceAll("l", "L")            // "  heLLo, WorLd!  " (ES2021)

// 重复
"ha".repeat(3)   // "hahaha"

// 填充
"5".padStart(3, "0")   // "005"
"5".padEnd(3, "0")     // "500"
```

### Python 语言对比

```python
str = "  Hello, World!  "

# 大小写转换
str.lower()           # "  hello, world!  "
str.upper()           # "  HELLO, WORLD!  "
str.capitalize()      # "  hello, world!  "
str.title()           # "  Hello, World!  "

# 去除空白
str.strip()           # "Hello, World!"
str.lstrip()          # "Hello, World!  "
str.rstrip()          # "  Hello, World!"

# 查找
str.find("World")     # 10
str.count("o")        # 2
str.startswith("Hello") # False
str.endswith("!")     # True

# 替换
str.replace("World", "Python")

# 分割和连接
"hello world".split()     # ['hello', 'world']
"a,b,c".split(",")        # ['a', 'b', 'c']
"-".join(["a", "b", "c"]) # "a-b-c"
```

### 字符串格式化

```javascript
let name = "Alice";
let age = 25;
let height = 1.75;

// 模板字符串（推荐）
`Hello, ${name}!`

// 数字格式化
height.toFixed(2)        // "1.75"
age.toString().padStart(5, "0")  // "00025"

// 传统方法
"Hello, %s! You are %d years old.".replace(/%s/, name).replace(/%d/, age)

// Intl.NumberFormat
let num = 1000000;
new Intl.NumberFormat().format(num)  // "1,000,000"
```

### Python 语言对比

```python
name = "Alice"
age = 25
height = 1.75

# f-string (Python 3.6+)
f"{name} is {age} years old"
f"{height:.2f}"           # "1.75"
f"{age:05d}"              # "00025"
f"{0.25:%}"               # "25.000000%"
f"{1000000:,}"            # "1,000,000"

# format 方法
"{} is {} years old".format(name, age)
"{name} is {age} years old".format(name=name, age=age)
```

### 字符串不可变性

```javascript
// JavaScript 字符串不可变
let str = "hello";
// str[0] = "H";  // 无效
str = "H" + str.slice(1);  // 正确方式

// Python 同样不可变
```

---

## JavaScript 与 Python 语法对比总结

| 特性 | JavaScript (Node.js) | Python |
|------|---------------------|--------|
| 变量声明 | `let`, `const`, `var` | 直接赋值 |
| 常量 | `const` | 命名约定（大写） |
| 类型系统 | 动态类型 | 动态类型 |
| 代码块 | 花括号 `{}` | 缩进 |
| 语句结束 | 分号（可选） | 换行 |
| 布尔值 | `true`, `false` | `True`, `False` |
| 空值 | `null`, `undefined` | `None` |
| 逻辑运算符 | `&&`, `\|\|`, `!` | `and`, `or`, `not` |
| 相等比较 | `===` (严格), `==` (宽松) | `==` (值), `is` (引用) |
| 注释 | `//`, `/* */` | `#`, `""" """` |
| 字符串插值 | 模板字符串 `` `${var}` `` | f-string `f"{var}"` |
| 循环 | `for`, `for...of`, `for...in`, `while`, `do...while` | `for`, `while` |
| 条件分支 | `if-else`, `switch` | `if-elif-else`, `match-case` |
