# Python 数据结构手册

> 本手册对比 Go 语言，详细介绍 Python 的内置数据结构

## 目录

1. [列表 (List)](#列表-list)
2. [元组 (Tuple)](#元组-tuple)
3. [字典 (Dictionary)](#字典-dictionary)
4. [集合 (Set)](#集合-set)
5. [字符串 (String)](#字符串-string)
6. [字节序列 (Bytes)](#字节序列-bytes)
7. [数据结构对比](#数据结构对比)

---

## 列表 (List)

### 列表创建

```python
# 创建列表
fruits = ["apple", "banana", "cherry"]
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]
nested = [[1, 2], [3, 4], [5, 6]]
empty = []

# list() 构造函数
chars = list("hello")      # ['h', 'e', 'l', 'l', 'o']
nums = list(range(5))      # [0, 1, 2, 3, 4]
```

### Go 语言对比

```go
// Go 的切片（类似列表）
fruits := []string{"apple", "banana", "cherry"}
numbers := []int{1, 2, 3, 4, 5}
// Go 是静态类型，不能混合类型
// 嵌套切片
nested := [][]int{{1, 2}, {3, 4}, {5, 6}}
```

### 列表索引和切片

```python
fruits = ["apple", "banana", "cherry", "date"]

# 索引访问
fruits[0]    # "apple"
fruits[-1]   # "date" (最后一个)
fruits[-2]   # "cherry" (倒数第二个)

# 切片
fruits[1:3]    # ["banana", "cherry"]
fruits[:2]     # ["apple", "banana"]
fruits[2:]     # ["cherry", "date"]
fruits[::2]    # ["apple", "cherry"]
fruits[::-1]   # ["date", "cherry", "banana", "apple"] (反转)

# 切片赋值
fruits[1:3] = ["blueberry", "coconut"]
```

### Go 语言对比

```go
// Go 的切片访问
fruits[0]      // "apple"
fruits[1:3]    // []string{"banana", "cherry"}
// Go 不支持负索引
// Go 不支持负步长
```

### 列表常用方法

```python
fruits = ["apple", "banana"]

# 添加元素
fruits.append("cherry")        # 末尾添加
fruits.insert(1, "apricot")    # 指定位置插入
fruits.extend(["date", "egg"]) # 扩展列表

# 删除元素
fruits.remove("banana")        # 删除第一个匹配项
popped = fruits.pop()          # 删除并返回末尾元素
popped = fruits.pop(0)         # 删除并返回指定位置元素
del fruits[0]                  # 删除指定位置
del fruits[1:3]                # 删除切片

# 查找
idx = fruits.index("apple")    # 返回索引
count = fruits.count("apple")  # 计算出现次数
exists = "apple" in fruits     # 判断是否存在

# 排序
numbers = [3, 1, 4, 1, 5, 9, 2, 6]
numbers.sort()                 # 原地排序：[1, 1, 2, 3, 4, 5, 6, 9]
numbers.sort(reverse=True)     # 降序排序
sorted_nums = sorted(numbers)  # 返回新列表

# 其他方法
fruits.reverse()               # 原地反转
length = len(fruits)           # 列表长度
copy = fruits.copy()           # 浅拷贝
copy = fruits[:]               # 另一种拷贝方式
fruits.clear()                 # 清空列表
```

### Go 语言对比

```go
// Go 切片操作
fruits = append(fruits, "cherry")           // 添加
fruits = append(fruits, "date", "egg")      // 添加多个
// 删除（需要手动实现）
fruits = append(fruits[:i], fruits[i+1:]...) // 删除索引 i 的元素
// 查找（需要手动实现）
for i, v := range fruits { if v == "apple" { ... } }
// 排序
sort.Strings(fruits)
sort.Ints(numbers)
// 长度
len(fruits)
// 拷贝
copy := make([]string, len(fruits))
copy(copy, fruits)
```

### 列表推导式

```python
# 基础推导式
squares = [x**2 for x in range(10)]           # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# 带条件
evens = [x for x in range(20) if x % 2 == 0]

# 嵌套推导式
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flattened = [num for row in matrix for num in row]

# 条件表达式
labels = ["偶数" if x % 2 == 0 else "奇数" for x in range(5)]

# 转换类型
strings = [str(x) for x in range(5)]  # ['0', '1', '2', '3', '4']
```

### Go 语言对比

```go
// Go 没有列表推导式，需要显式循环
squares := make([]int, 0, 10)
for x := 0; x < 10; x++ {
    squares = append(squares, x*x)
}
```

---

## 元组 (Tuple)

### 元组创建

```python
# 创建元组
point = (1, 2, 3)
colors = "red", "green", "blue"  # 可以省略括号
single = (1,)                     # 单元素元组需要逗号
empty = ()

# 解包
x, y, z = point
first, *rest = (1, 2, 3, 4, 5)   # first=1, rest=[2, 3, 4, 5]
```

### Go 语言对比

```go
// Go 没有元组，使用结构体或数组
type Point struct { X, Y, Z int }
// 多返回值类似元组
x, y, err := getPosition()
```

### 元组特性

```python
# 不可变性
point = (1, 2, 3)
# point[0] = 10  # TypeError!

# 但可变元素可以修改
nested = ([1, 2], [3, 4])
nested[0][0] = 99  # 可以，因为列表是可变的

# 元组方法
count = (1, 2, 2, 3).count(2)  # 2
index = (1, 2, 3).index(2)     # 1

# 命名元组
from collections import namedtuple
Point = namedtuple('Point', ['x', 'y'])
p = Point(1, 2)
print(p.x, p.y)  # 1 2
```

---

## 字典 (Dictionary)

### 字典创建

```python
# 创建字典
person = {"name": "Alice", "age": 25, "city": "New York"}
empty = {}
from_pairs = dict([("name", "Bob"), ("age", 30)])
from_kwargs = dict(name="Charlie", age=35)

# 访问值
name = person["name"]           # "Alice"
age = person.get("age")         # 25
missing = person.get("email")   # None
default = person.get("email", "N/A")  # "N/A"
```

### Go 语言对比

```go
// Go 的 map
person := map[string]interface{}{
    "name": "Alice",
    "age":  25,
    "city": "New York",
}
// 访问
name := person["name"]
// Go 有"comma ok"惯用法
age, ok := person["age"]
// 默认值
email, ok := person["email"]
if !ok { email = "N/A" }
```

### 字典操作

```python
person = {"name": "Alice", "age": 25}

# 添加/修改
person["email"] = "alice@example.com"  # 添加
person["age"] = 26                      # 修改

# 删除
del person["name"]                      # 删除键
age = person.pop("age")                 # 删除并返回值
last = person.popitem()                 # 删除并返回最后一个键值对

# 查找
keys = person.keys()                    # 所有键
values = person.values()                # 所有值
items = person.items()                  # 所有键值对
exists = "name" in person               # 判断键是否存在

# 遍历
for key in person:
    print(key, person[key])

for key, value in person.items():
    print(key, value)

# 合并
person2 = {"city": "New York"}
person.update(person2)

# 拷贝
copy = person.copy()

# 默认值
person.setdefault("country", "USA")  # 如果键不存在则设置默认值
```

### Go 语言对比

```go
// Go map 操作
person["email"] = "alice@example.com"  // 添加/修改
delete(person, "name")                  // 删除
// 遍历
for key, value := range person {
    fmt.Println(key, value)
}
// 长度
len(person)
```

### 字典推导式

```python
# 基础推导式
squares = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# 带条件
even_squares = {x: x**2 for x in range(10) if x % 2 == 0}

# 交换键值
original = {"a": 1, "b": 2, "c": 3}
swapped = {v: k for k, v in original.items()}  # {1: 'a', 2: 'b', 3: 'c'}

# 从两个列表创建
keys = ["a", "b", "c"]
values = [1, 2, 3]
paired = dict(zip(keys, values))  # {'a': 1, 'b': 2, 'c': 3}
```

### 特殊字典

```python
# defaultdict - 带默认值的字典
from collections import defaultdict
counts = defaultdict(int)
counts["apple"] += 1  # 自动初始化为 0

# OrderedDict - 保持插入顺序（Python 3.7+ 普通字典也保持顺序）
from collections import OrderedDict
ordered = OrderedDict()
ordered["a"] = 1
ordered["b"] = 2

# Counter - 计数器
from collections import Counter
counter = Counter("hello world")
print(counter.most_common(3))  # [('l', 3), ('o', 2), ('h', 1)]
```

---

## 集合 (Set)

### 集合创建

```python
# 创建集合
fruits = {"apple", "banana", "cherry"}
from_list = set([1, 2, 3, 2, 1])  # {1, 2, 3}
empty = set()                      # 不能用 {} 创建空集合

# frozenset - 不可变集合
frozen = frozenset([1, 2, 3])
```

### Go 语言对比

```go
// Go 没有内置集合，使用 map 模拟
fruits := map[string]bool{
    "apple": true,
    "banana": true,
}
// 添加
fruits["cherry"] = true
// 检查存在
if fruits["apple"] { ... }
// 删除
delete(fruits, "banana")
```

### 集合操作

```python
fruits = {"apple", "banana", "cherry"}

# 添加/删除
fruits.add("date")
fruits.remove("banana")       # 不存在会报错
fruits.discard("banana")      # 不存在不会报错
popped = fruits.pop()         # 随机删除并返回一个元素

# 集合运算
a = {1, 2, 3, 4, 5}
b = {4, 5, 6, 7, 8}

a | b    # 并集：{1, 2, 3, 4, 5, 6, 7, 8}
a & b    # 交集：{4, 5}
a - b    # 差集：{1, 2, 3}
a ^ b    # 对称差集：{1, 2, 3, 6, 7, 8}

# 集合方法
a.union(b)         # 并集
a.intersection(b)  # 交集
a.difference(b)    # 差集
a.symmetric_difference(b)  # 对称差集

# 子集/超集判断
{1, 2} <= a        # True (子集)
a >= {1, 2}        # True (超集)
{1, 2} < {1, 2, 3} # True (真子集)

# 其他
len(a)             # 集合大小
1 in a             # 判断元素是否存在
```

### 集合推导式

```python
# 基础推导式
squares = {x**2 for x in range(5)}  # {0, 1, 4, 9, 16}

# 带条件
even_squares = {x**2 for x in range(10) if x % 2 == 0}
```

---

## 字符串 (String)

字符串在 Python 中是不可变的序列类型，详细操作请参考 [基础语法手册](./python 基础语法手册.md#字符串操作)。

```python
# 字符串作为序列
s = "hello"
len(s)        # 5
s[0]          # 'h'
s[-1]         # 'o'
s[1:4]        # 'ell'

# 遍历
for char in s:
    print(char)

# 成员检查
'h' in s     # True
```

---

## 字节序列 (Bytes)

### bytes 和 bytearray

```python
# bytes - 不可变
b = b'hello'
b[0]          # 104 (ASCII 码)
# b[0] = 105  # TypeError!

# bytearray - 可变
ba = bytearray(b'hello')
ba[0] = 105   # 可以修改
ba.append(33) # 追加

# 转换
text = "hello"
encoded = text.encode('utf-8')    # b'hello'
decoded = encoded.decode('utf-8') # 'hello'

# 字节字面量
hex_bytes = bytes.fromhex('48656c6c6f')  # b'Hello'
```

### Go 语言对比

```go
// Go 的字节切片
b := []byte("hello")
b[0] = 'H'  // 可以修改
```

---

## 数据结构对比

### 可变性对比

| 类型 | 可变性 | 有序 | 允许重复 | 索引访问 |
|------|--------|------|----------|----------|
| list | 可变 | ✓ | ✓ | ✓ |
| tuple | 不可变 | ✓ | ✓ | ✓ |
| dict | 可变 | ✓ (3.7+) | 键唯一 | 键访问 |
| set | 可变 | ✗ | ✗ | ✗ |
| str | 不可变 | ✓ | ✓ | ✓ |
| bytes | 不可变 | ✓ | ✓ | ✓ |
| bytearray | 可变 | ✓ | ✓ | ✓ |

### 性能特性

| 操作 | list | dict | set |
|------|------|------|-----|
| 索引访问 | O(1) | O(1) (键) | - |
| 末尾添加 | O(1)* | - | - |
| 任意位置插入 | O(n) | - | - |
| 查找 | O(n) | O(1)* | O(1)* |
| 删除 | O(n) | O(1)* | O(1)* |

*平均时间复杂度

### Go 与 Python 数据结构对比

| Python | Go | 说明 |
|--------|-----|------|
| list | slice | 动态数组 |
| tuple | 无/struct | Go 可用结构体或数组替代 |
| dict | map | 哈希表 |
| set | map[T]bool | Go 用 map 模拟集合 |
| str | string | 都是不可变 |
| bytes | []byte | Go 的字节切片是可变的 |

### 选择指南

- **list**: 需要有序、可变的序列，允许重复
- **tuple**: 需要不可变的序列，常用于函数返回值
- **dict**: 需要键值对映射，快速查找
- **set**: 需要去重，进行集合运算
- **bytes**: 处理二进制数据
- **bytearray**: 需要修改字节数据

---

## 常用数据结构模式

### 栈 (Stack)

```python
# 使用 list 实现栈
stack = []
stack.append(1)      # 压栈
stack.append(2)
top = stack.pop()    # 弹栈：2
```

### 队列 (Queue)

```python
# 使用 deque 实现高效队列
from collections import deque
queue = deque()
queue.append(1)      # 入队
queue.append(2)
first = queue.popleft()  # 出队：1
```

### 堆 (Heap)

```python
# 使用 heapq 实现最小堆
import heapq
heap = []
heapq.heappush(heap, 3)
heapq.heappush(heap, 1)
heapq.heappush(heap, 2)
smallest = heapq.heappop(heap)  # 1
```

### 链表

```python
# 使用类实现简单链表
class Node:
    def __init__(self, value):
        self.value = value
        self.next = None
```
