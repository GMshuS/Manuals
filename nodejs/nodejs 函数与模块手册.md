# Node.js 函数与模块手册

> 本手册对比 Python 语言，详细介绍 Node.js 的函数定义、参数传递、作用域和模块系统

## 目录

1. [函数定义](#函数定义)
2. [参数传递](#参数传递)
3. [返回值](#返回值)
4. [作用域](#作用域)
5. [闭包](#闭包)
6. [箭头函数](#箭头函数)
7. [CommonJS 模块](#commonjs-模块)
8. [ESM 模块](#esm-模块)
9. [常用内置函数](#常用内置函数)

---

## 函数定义

### 基本语法

```javascript
// 函数声明
function greet(name) {
    console.log(`Hello, ${name}!`);
}

greet("Alice");

// 函数表达式
const greet2 = function(name) {
    console.log(`Hi, ${name}!`);
};

// 带默认参数
function greet3(name = "Guest") {
    console.log(`Hello, ${name}!`);
}

greet3();           // "Hello, Guest!"
greet3("Alice");    // "Hello, Alice!"
```

### Python 语言对比

```python
# Python 函数定义
def greet(name):
    print(f"Hello, {name}!")

# 带默认参数
def greet3(name="Guest"):
    print(f"Hello, {name}!")
```

### 函数也是对象

```javascript
// 函数可以赋值给变量
function square(x) {
    return x ** 2;
}

const f = square;
console.log(f(5));  // 25

// 函数可以作为参数传递
function apply(func, value) {
    return func(value);
}

console.log(apply(square, 4));  // 16

// 函数可以存储在对象中
const operations = {
    add: (x, y) => x + y,
    mul: (x, y) => x * y,
};

console.log(operations.mul(3, 4));  // 12
```

---

## 参数传递

### 位置参数和关键字参数

```javascript
function describePet(petName, petType) {
    console.log(`${petName} is a ${petType}`);
}

// 位置参数
describePet("Harry", "dog");

// JavaScript 没有原生的关键字参数，但可以使用对象模拟
describePetWithOptions({ petType: "cat", petName: "Whiskers" });

function describePetWithOptions({ petName, petType }) {
    console.log(`${petName} is a ${petType}`);
}
```

### Python 语言对比

```python
# Python 支持关键字参数
describe_pet(pet_type="cat", pet_name="Whiskers")
```

### 可变参数

```javascript
// ...args - 可变位置参数（剩余参数）
function sumAll(...args) {
    return args.reduce((sum, n) => sum + n, 0);
}

console.log(sumAll(1, 2, 3, 4, 5));  // 15

// 对象解构作为关键字参数
function createPerson({ name, age, city = "Unknown" } = {}) {
    return { name, age, city };
}

createPerson({ name: "Alice", age: 25 });
// { name: "Alice", age: 25, city: "Unknown" }
```

### Python 语言对比

```python
# Python *args 和 **kwargs
def sum_all(*args):
    return sum(args)

def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")
```

### 参数展开

```javascript
// 数组展开
function greet(first, last) {
    console.log(`Hello, ${first} ${last}!`);
}

const name = ["John", "Doe"];
greet(...name);  // Hello, John Doe!

// 对象展开
const defaults = { theme: "light", lang: "en" };
const options = { ...defaults, theme: "dark" };
```

---

## 返回值

### 单返回值

```javascript
function square(x) {
    return x ** 2;
}

// 没有 return 返回 undefined
function printSquare(x) {
    console.log(x ** 2);
}

const result = printSquare(4);  // 打印 16
console.log(result);  // undefined
```

### Python 语言对比

```python
# Python 没有 return 返回 None
def print_square(x):
    print(x ** 2)

result = print_square(4)
print(result)  # None
```

### 多返回值

```javascript
// JavaScript 返回数组或对象
function getPerson() {
    return ["Alice", 25, "NYC"];
}

const [name, age, city] = getPerson();

// 或返回对象
function getPersonObj() {
    return { name: "Alice", age: 25, city: "NYC" };
}

const { name, age } = getPersonObj();
```

### Python 语言对比

```python
# Python 原生支持多返回值（元组）
def get_person():
    return "Alice", 25, "NYC"

name, age, city = get_person()
```

---

## 作用域

### 作用域类型

```javascript
// 全局作用域
let globalVar = "global";

function outer() {
    // 函数作用域
    let outerVar = "outer";
    
    if (true) {
        // 块级作用域（let/const）
        let blockVar = "block";
        const BLOCK_CONST = "constant";
        var functionVar = "function scope";  // var 是函数作用域
    }
    
    console.log(blockVar);  // ReferenceError!
    console.log(functionVar);  // "function scope"
}
```

### Python 语言对比

```python
# Python 作用域（LEGB 规则）
global_var = "global"

def outer():
    outer_var = "outer"
    
    if True:
        block_var = "block"  # Python 没有块级作用域
    
    print(block_var)  # 可以访问
```

### global 和闭包

```javascript
// 全局变量
let count = 0;

function increment() {
    count++;  // 可以直接修改
}

// 闭包
function makeCounter() {
    let count = 0;
    
    return function() {
        count++;
        return count;
    };
}

const counter = makeCounter();
console.log(counter());  // 1
console.log(counter());  // 2
```

---

## 闭包

### 闭包示例

```javascript
// 闭包：函数记住并访问其词法作用域
function createMultiplier(factor) {
    return function(x) {
        return x * factor;
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);

console.log(double(5));  // 10
console.log(triple(5));  // 15

// 闭包在实际中的应用
function createCounter() {
    let count = 0;
    
    return {
        increment: () => ++count,
        decrement: () => --count,
        getCount: () => count
    };
}

const counter = createCounter();
counter.increment();
counter.increment();
console.log(counter.getCount());  // 2
```

### Python 语言对比

```python
# Python 闭包
def create_multiplier(factor):
    def multiply(x):
        return x * factor
    return multiply

# 需要使用 nonlocal 修改外层变量
def create_counter():
    count = 0
    
    def increment():
        nonlocal count
        count += 1
        return count
    
    return increment
```

---

## 箭头函数

### 箭头函数语法

```javascript
// 基本语法
const square = x => x ** 2;

// 多参数
const add = (a, b) => a + b;

// 无参数
const sayHi = () => console.log("Hi!");

// 返回对象（需要括号）
const createPerson = (name, age) => ({ name, age });

// 多行函数体
const greet = name => {
    const message = `Hello, ${name}!`;
    return message;
};

// 与 this 绑定
// 箭头函数不绑定自己的 this，继承自外层作用域
```

### Python 语言对比

```python
# Python lambda（单表达式）
square = lambda x: x ** 2
add = lambda a, b: a + b

# 常规函数
def greet(name):
    return f"Hello, {name}!"
```

### this 绑定

```javascript
const person = {
    name: "Alice",
    // 普通函数：this 动态绑定
    greet1: function() {
        console.log(`Hello, I'm ${this.name}`);
    },
    // 箭头函数：this 继承自外层
    greet2: () => {
        console.log(`Hello, I'm ${this.name}`);  // this 不是 person
    }
};

person.greet1();  // Hello, I'm Alice
person.greet2();  // Hello, I'm undefined

// 正确用法：在方法内部使用箭头函数保持 this
const person2 = {
    name: "Bob",
    friends: ["Alice", "Charlie"],
    greetFriends() {
        this.friends.forEach(friend => {
            console.log(`${this.name} greets ${friend}`);
        });
    }
};

person2.greetFriends();
```

---

## CommonJS 模块

### 模块导出

```javascript
// math.js
const PI = 3.14159;

function add(a, b) {
    return a + b;
}

function multiply(a, b) {
    return a * b;
}

// 导出单个
module.exports = add;

// 或导出多个
module.exports = {
    PI,
    add,
    multiply
};

// 或逐个导出
exports.PI = PI;
exports.add = add;
exports.multiply = multiply;
```

### 模块导入

```javascript
// 导入整个模块
const math = require('./math');
console.log(math.PI);
console.log(math.add(2, 3));

// 解构导入
const { PI, add } = require('./math');

// 导入单个（如果模块导出的是函数）
const add = require('./add');
```

### Python 语言对比

```python
# Python 模块
import math
from math import PI, add

# 或
import math as m
```

---

## ESM 模块

### ESM 导出

```javascript
// math.js (ESM)
export const PI = 3.14159;

export function add(a, b) {
    return a + b;
}

export function multiply(a, b) {
    return a * b;
}

// 默认导出
export default function main() {
    console.log("Main function");
}

// 或
const utils = { PI, add, multiply };
export default utils;
```

### ESM 导入

```javascript
// 导入特定成员
import { PI, add } from './math.js';

// 导入整个模块
import * as math from './math.js';

// 默认导入
import mainFunc from './math.js';

// 重命名导入
import { add as sum } from './math.js';

// 动态导入（返回 Promise）
const math = await import('./math.js');
```

### Python 语言对比

```python
# Python 导入
from math import PI, add
import math as m
from package import module
from package.module import function
```

### package.json 配置

```json
{
    "type": "module"  // 启用 ESM
}
```

或使用 `.mjs` 扩展名。

---

## 常用内置函数

### 全局函数

```javascript
// 类型转换
Number("42")        // 42
String(123)         // "123"
Boolean(1)          // true

// 解析
parseInt("42px")    // 42
parseFloat("3.14kg") // 3.14

// 编码
encodeURIComponent("Hello 世界");
decodeURIComponent("Hello%20%E4%B8%96%E7%95%8C");

// 定时器
setTimeout(() => console.log("After 1s"), 1000);
setInterval(() => console.log("Every 2s"), 2000);
clearTimeout(timerId);
clearInterval(intervalId);

// 立即执行
setImmediate(() => console.log("Next tick"));
process.nextTick(() => console.log("Before I/O"));

// 其他
console.log("Hello");
console.error("Error");
console.warn("Warning");
console.table([{ a: 1 }, { a: 2 }]);

eval("1 + 2");  // 3 (不推荐使用)
```

### 数学函数

```javascript
Math.abs(-5)      // 5
Math.round(3.7)   // 4
Math.floor(3.7)   // 3
Math.ceil(3.2)    // 4
Math.max(1, 2, 3) // 3
Math.min(1, 2, 3) // 1
Math.random()     // 0-1 随机数
Math.pow(2, 3)    // 8
Math.sqrt(16)     // 4
Math.PI           // 3.14159...
```

### Python 语言对比

```python
abs(-5)           # 5
round(3.7)        # 4
import math
math.floor(3.7)   # 3
math.ceil(3.2)    # 4
max(1, 2, 3)      # 3
min(1, 2, 3)      # 1
import random
random.random()   # 0-1 随机数
```

---

## Node.js 与 Python 函数对比总结

| 特性 | JavaScript (Node.js) | Python |
|------|---------------------|--------|
| 函数定义 | `function name() {}`, `const f = () => {}` | `def name():` |
| 箭头函数 | `() => {}` | `lambda` (单表达式) |
| 默认参数 | 支持 | 支持 |
| 可变参数 | `...args` | `*args`, `**kwargs` |
| 多返回值 | 数组/对象 | 元组 |
| 作用域 | 块级（let/const）、函数（var） | 函数、模块 |
| 闭包 | 支持 | 支持（需 nonlocal） |
| this 绑定 | 动态/箭头函数词法 | self 参数 |
| 模块系统 | CommonJS, ESM | import/export |
| 装饰器 | 提案阶段 | 支持 (@decorator) |
