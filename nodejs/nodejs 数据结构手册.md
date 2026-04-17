# Node.js 数据结构手册

> 本手册对比 Python 语言，详细介绍 Node.js (JavaScript) 的内置数据结构

## 目录

1. [数组 (Array)](#数组-array)
2. [对象 (Object)](#对象-object)
3. [Map](#map)
4. [Set](#set)
5. [TypedArray](#typedarray)
6. [WeakMap 和 WeakSet](#weakmap-和-weakset)
7. [数据结构对比](#数据结构对比)

---

## 数组 (Array)

### 数组创建

```javascript
// 字面量创建
const fruits = ["apple", "banana", "cherry"];
const numbers = [1, 2, 3, 4, 5];
const mixed = [1, "hello", 3.14, true, null];
const nested = [[1, 2], [3, 4], [5, 6]];
const empty = [];

// Array 构造函数
const arr1 = new Array(5);        // [empty × 5] 长度为 5 的空数组
const arr2 = new Array(1, 2, 3);  // [1, 2, 3]
const arr3 = Array.of(1, 2, 3);   // [1, 2, 3] (推荐)
const arr4 = Array.from("hello"); // ["h", "e", "l", "l", "o"]
```

### Python 语言对比

```python
# Python 列表
fruits = ["apple", "banana", "cherry"]
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True, None]
nested = [[1, 2], [3, 4], [5, 6]]
empty = []

# list() 构造函数
chars = list("hello")      # ['h', 'e', 'l', 'l', 'o']
nums = list(range(5))      # [0, 1, 2, 3, 4]
```

### 数组索引和切片

```javascript
const fruits = ["apple", "banana", "cherry", "date"];

// 索引访问
fruits[0]      // "apple"
fruits[-1]     // undefined (JavaScript 不支持负索引)
fruits[10]     // undefined

// 使用 at() 方法 (ES2022)
fruits.at(-1)  // "date" (支持负索引)

// 切片
fruits.slice(1, 3)    // ["banana", "cherry"]
fruits.slice(2)       // ["cherry", "date"]
fruits.slice(-2)      // ["cherry", "date"]
fruits.slice(0, -1)   // ["apple", "banana"]

// 修改原数组的切片
fruits.splice(1, 2, "apricot", "blueberry");  // 删除 2 个，插入 2 个
```

### Python 语言对比

```python
fruits = ["apple", "banana", "cherry", "date"]

# Python 原生支持负索引
fruits[0]      # "apple"
fruits[-1]     # "date"

# 切片
fruits[1:3]    # ["banana", "cherry"]
fruits[2:]     # ["cherry", "date"]
fruits[-2:]    # ["cherry", "date"]
fruits[0:-1]   # ["apple", "banana"]
fruits[::2]    # ["apple", "cherry"]
fruits[::-1]   # ["date", "cherry", "banana", "apple"]
```

### 数组常用方法

```javascript
const fruits = ["apple", "banana"];

// 添加/删除元素
fruits.push("cherry");        // 末尾添加，返回新长度
fruits.pop();                 // 删除末尾，返回删除的元素
fruits.unshift("apricot");    // 开头添加
fruits.shift();               // 删除开头

// 查找
fruits.indexOf("apple");      // 0 (索引)
fruits.lastIndexOf("banana"); // 1
fruits.includes("apple");     // true
fruits.find(x => x.length > 5);  // "banana" (第一个匹配)
fruits.findIndex(x => x === "apple");  // 0

// 转换
fruits.join(", ");            // "apple, banana"
fruits.toString();            // "apple,banana"
fruits.slice(0, 1);           // ["apple"] (不修改原数组)
fruits.concat(["cherry"]);    // ["apple", "banana", "cherry"]

// 排序和反转
fruits.reverse();             // 原地反转
fruits.sort();                // 字典序排序

// 其他
fruits.length;                // 长度
fruits.copyWithin(0, 1);      // 复制数组部分
fruits.fill("x");             // 填充数组
```

### 数组迭代方法

```javascript
const numbers = [1, 2, 3, 4, 5];

// forEach - 遍历
numbers.forEach((num, idx) => {
    console.log(`${idx}: ${num}`);
});

// map - 映射
const squares = numbers.map(n => n ** 2);  // [1, 4, 9, 16, 25]

// filter - 过滤
const evens = numbers.filter(n => n % 2 === 0);  // [2, 4]

// reduce - 累积
const sum = numbers.reduce((acc, n) => acc + n, 0);  // 15
const product = numbers.reduce((acc, n) => acc * n, 1);  // 120

// some/every - 条件检查
numbers.some(n => n > 4);     // true (至少一个)
numbers.every(n => n > 0);    // true (所有)

// find/findIndex - 查找
numbers.find(n => n > 3);     // 4
numbers.findIndex(n => n > 3); // 3

// flat/flatMap - 扁平化
const nested = [1, [2, 3], [4, [5, 6]]];
nested.flat();                // [1, 2, 3, 4, [5, 6]]
nested.flat(2);               // [1, 2, 3, 4, 5, 6]
[1, 2, 3].flatMap(n => [n, n * 2]);  // [1, 2, 2, 4, 3, 6]

// keys/values/entries - 迭代器
[...numbers.keys()];          // [0, 1, 2, 3, 4]
[...numbers.values()];        // [1, 2, 3, 4, 5]
[...numbers.entries()];       // [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]]
```

### Python 语言对比

```python
numbers = [1, 2, 3, 4, 5]

# Python 列表推导式（更简洁）
squares = [n ** 2 for n in numbers]      # [1, 4, 9, 16, 25]
evens = [n for n in numbers if n % 2 == 0]  # [2, 4]

# map/filter
squares = list(map(lambda n: n ** 2, numbers))
evens = list(filter(lambda n: n % 2 == 0, numbers))

# reduce (需要导入)
from functools import reduce
sum_val = reduce(lambda acc, n: acc + n, numbers, 0)

# any/all
any(n > 4 for n in numbers)  # True
all(n > 0 for n in numbers)  # True

# 查找
next(n for n in numbers if n > 3)  # 4
```

### 数组操作

```javascript
// 展开运算符
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5, 6];  // [1, 2, 3, 4, 5, 6]
const copy = [...arr1];            // 浅拷贝

// 合并
const merged = [...arr1, ...arr2];

// 去重
const unique = [...new Set([1, 2, 2, 3, 3, 3])];  // [1, 2, 3]

// 交换变量
let a = 1, b = 2;
[a, b] = [b, a];  // a=2, b=1

// 剩余参数
const [first, ...rest] = [1, 2, 3, 4, 5];  // first=1, rest=[2,3,4,5]
```

### Python 语言对比

```python
# Python 也有展开运算符
arr1 = [1, 2, 3]
arr2 = [*arr1, 4, 5, 6]
copy = arr1[:]  # 或 list(arr1)

# 去重
unique = list(set([1, 2, 2, 3, 3, 3]))

# 交换变量
a, b = 1, 2
a, b = b, a

# 解包
first, *rest = [1, 2, 3, 4, 5]
```

---

## 对象 (Object)

### 对象创建

```javascript
// 对象字面量
const person = {
    name: "Alice",
    age: 25,
    city: "New York",
    greet: function() {
        return `Hello, I'm ${this.name}`;
    },
    // 简写方法
    introduce() {
        return `I'm ${this.age} years old`;
    },
    // 计算属性名
    ["favorite" + "Color"]: "blue"
};

// 访问属性
person.name;           // "Alice"
person["age"];         // 25
const key = "city";
person[key];           // "New York"

// 修改/添加
person.email = "alice@example.com";
delete person.city;
```

### Python 语言对比

```python
# Python 字典
person = {
    "name": "Alice",
    "age": 25,
    "city": "New York"
}

# 访问
person["name"]         # "Alice"
person.get("age")      # 25
person.get("missing", "default")  # 默认值
```

### 对象常用方法

```javascript
const obj = { a: 1, b: 2, c: 3 };

// 获取键/值/条目
Object.keys(obj);        // ["a", "b", "c"]
Object.values(obj);      // [1, 2, 3]
Object.entries(obj);     // [["a", 1], ["b", 2], ["c", 3]]

// 遍历
for (const key in obj) {
    console.log(key, obj[key]);
}

Object.entries(obj).forEach(([key, value]) => {
    console.log(`${key}: ${value}`);
});

// 合并
const merged = { ...obj, d: 4 };
const merged2 = Object.assign({}, obj, { d: 4 });

// 拷贝
const copy = { ...obj };
const deepCopy = JSON.parse(JSON.stringify(obj));  // 简单深拷贝

// 检查
obj.hasOwnProperty("a");  // true
"a" in obj;               // true

// 属性描述符
Object.getOwnPropertyDescriptor(obj, "a");
```

### Python 语言对比

```python
obj = {"a": 1, "b": 2, "c": 3}

# 获取键/值/条目
list(obj.keys())      # ['a', 'b', 'c']
list(obj.values())    # [1, 2, 3]
list(obj.items())     # [('a', 1), ('b', 2), ('c', 3)]

# 遍历
for key, value in obj.items():
    print(key, value)

# 合并
merged = {**obj, "d": 4}
merged2 = {**obj, **{"d": 4}}

# 拷贝
copy = obj.copy()
import copy
deep_copy = copy.deepcopy(obj)

# 检查
"a" in obj            # True
```

### 解构赋值

```javascript
const person = { name: "Alice", age: 25, city: "NYC" };

// 基本解构
const { name, age } = person;

// 重命名
const { name: userName, age: userAge } = person;

// 默认值
const { country = "USA" } = person;

// 嵌套解构
const user = {
    profile: {
        name: "Bob",
        age: 30
    }
};
const { profile: { name } } = user;

// 剩余属性
const { name, ...rest } = person;  // name="Alice", rest={age:25, city:"NYC"}
```

### Python 语言对比

```python
# Python 3.10+ 支持模式匹配
person = {"name": "Alice", "age": 25}
match person:
    case {"name": name, "age": age}:
        print(name, age)
```

---

## Map

### Map 创建和操作

```javascript
// 创建 Map
const map = new Map();
const mapWithInit = new Map([
    ["name", "Alice"],
    ["age", 25],
    ["city", "NYC"]
]);

// 添加/修改
map.set("name", "Alice");
map.set("age", 25);

// 访问
map.get("name");      // "Alice"
map.get("missing");   // undefined
map.has("name");      // true
map.size;             // 2

// 删除
map.delete("age");
map.clear();

// 遍历
for (const [key, value] of map) {
    console.log(key, value);
}

map.forEach((value, key) => {
    console.log(key, value);
});

// 键可以是任意类型
const objKey = { id: 1 };
map.set(objKey, "value");
map.get(objKey);  // "value"
```

### Python 语言对比

```python
# Python 字典（3.7+ 保持插入顺序）
d = {
    "name": "Alice",
    "age": 25,
    "city": "NYC"
}

# 访问
d["name"]           # "Alice"
d.get("missing")    # None
d.get("missing", "default")  # "default"
"name" in d         # True

# 删除
del d["age"]
d.clear()

# 遍历
for key, value in d.items():
    print(key, value)

# 键可以是任意可哈希类型
obj_key = (1, 2)  # 元组可哈希
d[obj_key] = "value"
```

---

## Set

### Set 创建和操作

```javascript
// 创建 Set
const set = new Set();
const setWithInit = new Set([1, 2, 3, 2, 1]);  // {1, 2, 3}

// 添加
set.add(4);
set.add(5);
set.add(4);  // 重复，无效果

// 检查
set.has(4);   // true
set.has(10);  // false
set.size;     // 5

// 删除
set.delete(4);
set.clear();

// 遍历
for (const item of set) {
    console.log(item);
}

set.forEach(item => console.log(item));

// 转换为数组
const arr = [...set];
const arr2 = Array.from(set);

// 集合运算
const a = new Set([1, 2, 3, 4, 5]);
const b = new Set([4, 5, 6, 7, 8]);

// 并集
const union = new Set([...a, ...b]);  // {1, 2, 3, 4, 5, 6, 7, 8}

// 交集
const intersection = new Set([...a].filter(x => b.has(x)));  // {4, 5}

// 差集
const difference = new Set([...a].filter(x => !b.has(x)));  // {1, 2, 3}
```

### Python 语言对比

```python
# Python set
s = {1, 2, 3, 2, 1}  # {1, 2, 3}
empty_set = set()    # 不能用 {} 创建空集合

# 添加
s.add(4)

# 检查
4 in s          # True

# 删除
s.remove(4)     # 不存在会报错
s.discard(4)    # 不存在不会报错
s.pop()         # 随机删除

# 集合运算
a = {1, 2, 3, 4, 5}
b = {4, 5, 6, 7, 8}

a | b    # 并集：{1, 2, 3, 4, 5, 6, 7, 8}
a & b    # 交集：{4, 5}
a - b    # 差集：{1, 2, 3}
a ^ b    # 对称差集：{1, 2, 3, 6, 7, 8}

# 方法
a.union(b)         # 并集
a.intersection(b)  # 交集
a.difference(b)    # 差集
```

---

## TypedArray

### TypedArray 类型

```javascript
// TypedArray 用于处理二进制数据
const int8 = new Int8Array(8);           // 8 位有符号整数
const uint8 = new Uint8Array(8);         // 8 位无符号整数
const uint8Clamped = new Uint8ClampedArray(8);  // 0-255 钳制
const int16 = new Int16Array(4);         // 16 位有符号整数
const int32 = new Int32Array(2);         // 32 位有符号整数
const float32 = new Float32Array(4);     // 32 位浮点数
const float64 = new Float64Array(2);     // 64 位浮点数

// 初始化
const arr = new Uint8Array([1, 2, 3, 4]);
const fromArray = Uint8Array.from([1, 2, 3]);

// 使用
arr[0] = 10;
arr.length;  // 4

// 与 ArrayBuffer 配合
const buffer = new ArrayBuffer(16);  // 16 字节
const view = new Uint8Array(buffer);
const int32View = new Int32Array(buffer);
```

### Python 语言对比

```python
# Python array 模块
import array
arr = array.array('i', [1, 2, 3, 4])  # 'i' 表示 int

# numpy (更常用)
import numpy as np
arr = np.array([1, 2, 3, 4], dtype=np.int32)
arr = np.zeros(8, dtype=np.uint8)
arr = np.ones(4, dtype=np.float32)
```

---

## WeakMap 和 WeakSet

### WeakMap

```javascript
// WeakMap 的键是弱引用（会被垃圾回收）
const weakMap = new WeakMap();

const obj = { id: 1 };
weakMap.set(obj, "metadata");

weakMap.get(obj);  // "metadata"
// WeakMap 不能遍历，没有 size 属性
```

### WeakSet

```javascript
// WeakSet 存储弱引用的对象
const weakSet = new WeakSet();

const obj = { id: 1 };
weakSet.add(obj);

weakSet.has(obj);  // true
// WeakSet 不能遍历
```

---

## 数据结构对比

### 可变性对比

| 类型 | 可变性 | 有序 | 允许重复 | 索引访问 |
|------|--------|------|----------|----------|
| Array | 可变 | ✓ | ✓ | ✓ |
| Object | 可变 | ✓ (ES2015+) | 键唯一 | 键访问 |
| Map | 可变 | ✓ | 键唯一 | 键访问 |
| Set | 可变 | ✗ | ✗ | ✗ |
| String | 不可变 | ✓ | ✓ | ✓ |
| TypedArray | 可变 | ✓ | ✓ | ✓ |

### 性能特性

| 操作 | Array | Object | Map | Set |
|------|-------|--------|-----|-----|
| 索引访问 | O(1) | O(1)* | O(1) | - |
| 末尾添加 | O(1)* | - | O(1) | O(1) |
| 查找 | O(n) | O(1)* | O(1) | O(1) |
| 删除 | O(n) | O(1)* | O(1) | O(1) |

*平均时间复杂度，Object 的键查找

### JavaScript 与 Python 数据结构对比

| JavaScript | Python | 说明 |
|------------|--------|------|
| Array | list | 动态数组 |
| Object | dict | 哈希表（3.7+ 有序） |
| Map | dict | 键值对映射 |
| Set | set | 集合 |
| TypedArray | array.array / numpy | 类型化数组 |
| String | str | 不可变字符串 |

### 选择指南

- **Array**: 需要有序、可变的序列，允许重复
- **Object**: 简单的键值对映射，键为字符串
- **Map**: 需要非字符串键，或需要保持插入顺序
- **Set**: 需要去重，进行集合运算
- **TypedArray**: 处理二进制数据，需要高性能数值计算

---

## 常用数据结构模式

### 栈 (Stack)

```javascript
// 使用 Array 实现栈
const stack = [];
stack.push(1);      // 压栈
stack.push(2);
const top = stack.pop();  // 弹栈：2
```

### 队列 (Queue)

```javascript
// 使用 Array（低效）
const queue = [];
queue.push(1);
queue.shift();  // O(n)

// 推荐：使用 deque 库或自己实现
class Queue {
    constructor() {
        this.head = [];
        this.tail = [];
    }
    push(item) {
        this.tail.push(item);
    }
    shift() {
        if (this.head.length === 0) {
            this.head = this.tail.reverse();
            this.tail = [];
        }
        return this.head.pop();
    }
}
```

### Python 语言对比

```python
# Python deque 实现高效队列
from collections import deque
queue = deque()
queue.append(1)      # 入队
queue.popleft()      # 出队：O(1)
```

### 堆 (Heap)

```javascript
// 使用第三方库
const heap = require('heap');
const h = new heap();
h.push(3);
h.push(1);
h.push(2);
const smallest = h.pop();  // 1
```

### Python 语言对比

```python
# Python heapq
import heapq
heap = []
heapq.heappush(heap, 3)
heapq.heappush(heap, 1)
smallest = heapq.heappop(heap)  # 1
```
