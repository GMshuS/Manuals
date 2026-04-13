# Python 函数与模块手册

> 本手册对比 Go 语言，详细介绍 Python 的函数定义、参数传递、作用域和模块系统

## 目录

1. [函数定义](#函数定义)
2. [参数传递](#参数传递)
3. [返回值](#返回值)
4. [作用域](#作用域)
5. [匿名函数](#匿名函数)
6. [模块与包](#模块与包)
7. [导入机制](#导入机制)
8. [常用内置函数](#常用内置函数)

---

## 函数定义

### 基本语法

```python
# 基本函数定义
def greet(name):
    """函数文档字符串"""
    print(f"Hello, {name}!")

# 调用函数
greet("Alice")

# 带默认参数
def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

greet("Alice")              # Hello, Alice!
greet("Bob", "Hi")          # Hi, Bob!
```

### Go 语言对比

```go
// Go 函数定义
func greet(name string) {
    fmt.Printf("Hello, %s!\n", name)
}

// 带默认值（Go 不支持默认参数，需要手动处理）
func greet(name string, greeting ...string) {
    g := "Hello"
    if len(greeting) > 0 {
        g = greeting[0]
    }
    fmt.Printf("%s, %s!\n", g, name)
}
```

### 函数注解（类型提示）

```python
# Python 3.5+ 类型注解
def add(a: int, b: int) -> int:
    return a + b

def greet(name: str, greeting: str = "Hello") -> str:
    return f"{greeting}, {name}!"

# 查看注解
print(add.__annotations__)  # {'a': <class 'int'>, 'b': <class 'int'>, 'return': <class 'int'>}
```

### Go 语言对比

```go
// Go 是静态类型语言，类型在参数名后
func add(a int, b int) int {
    return a + b
}

// 简化参数类型
func add(a, b int) int {
    return a + b
}
```

### 函数也是对象

```python
# 函数可以赋值给变量
def square(x):
    return x ** 2

f = square
print(f(5))  # 25

# 函数可以作为参数传递
def apply(func, value):
    return func(value)

print(apply(square, 4))  # 16

# 函数可以存储在数据结构中
operations = {
    'add': lambda x, y: x + y,
    'mul': lambda x, y: x * y,
}
print(operations['mul'](3, 4))  # 12
```

---

## 参数传递

### 位置参数和关键字参数

```python
def describe_pet(pet_name, pet_type):
    print(f"{pet_name} is a {pet_type}")

# 位置参数（顺序重要）
describe_pet("Harry", "dog")

# 关键字参数（顺序不重要）
describe_pet(pet_type="cat", pet_name="Whiskers")

# 混合使用（位置参数必须在关键字参数之前）
describe_pet("Harry", pet_type="dog")
```

### Go 语言对比

```go
// Go 只有位置参数，没有关键字参数
func describePet(petName, petType string) {
    fmt.Printf("%s is a %s\n", petName, petType)
}
// 必须按顺序传递
describePet("Harry", "dog")
```

### 默认参数

```python
def make_pizza(size, *toppings, cheese=True):
    print(f"Making a {size}-inch pizza")
    print(f"Toppings: {toppings}")
    print(f"Cheese: {cheese}")

make_pizza(12, "mushrooms", "peppers")
make_pizza(12, "mushrooms", cheese=False)
```

### 可变参数

```python
# *args - 可变位置参数
def sum_all(*args):
    return sum(args)

print(sum_all(1, 2, 3, 4, 5))  # 15

# **kwargs - 可变关键字参数
def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_info(name="Alice", age=25, city="NYC")

# 组合使用
def full_example(a, b, *args, c=10, **kwargs):
    print(f"a={a}, b={b}")
    print(f"args={args}")
    print(f"c={c}")
    print(f"kwargs={kwargs}")

full_example(1, 2, 3, 4, 5, c=20, name="test")
# a=1, b=2
# args=(3, 4, 5)
# c=20
# kwargs={'name': 'test'}
```

### Go 语言对比

```go
// Go 的可变参数
func sumAll(numbers ...int) int {
    total := 0
    for _, n := range numbers {
        total += n
    }
    return total
}
// 调用
sumAll(1, 2, 3, 4, 5)
nums := []int{1, 2, 3}
sumAll(nums...)  // 展开切片

// Go 没有 **kwargs，可以使用 map
func printInfo(info map[string]interface{}) {
    for k, v := range info {
        fmt.Printf("%s: %v\n", k, v)
    }
}
```

### 参数解包

```python
def greet(first, last):
    print(f"Hello, {first} {last}!")

# 列表/元组解包
name = ["John", "Doe"]
greet(*name)  # Hello, John Doe!

# 字典解包
name_dict = {"first": "Jane", "last": "Smith"}
greet(**name_dict)  # Hello, Jane Smith!
```

### Go 语言对比

```go
// Go 不支持参数解包
// 需要显式传递
name := []string{"John", "Doe"}
greet(name[0], name[1])
```

---

## 返回值

### 单返回值

```python
def square(x):
    return x ** 2

# 没有 return 返回 None
def print_square(x):
    print(x ** 2)

result = print_square(4)  # 打印 16
print(result)  # None
```

### 多返回值（元组）

```python
def get_person():
    return "Alice", 25, "NYC"

name, age, city = get_person()

# 或作为元组接收
person = get_person()  # ("Alice", 25, "NYC")
```

### Go 语言对比

```go
// Go 原生支持多返回值
func getPerson() (string, int, string) {
    return "Alice", 25, "NYC"
}

name, age, city := getPerson()

// Go 多返回值常用于错误处理
result, err := doSomething()
if err != nil {
    // 处理错误
}
```

### 返回 None

```python
def no_return():
    pass  # 或没有 return 语句

result = no_return()
print(result is None)  # True
```

---

## 作用域

### LEGB 规则

Python 作用域遵循 LEGB 规则：
- **L**ocal: 函数内部
- **E**nclosing: 外层函数
- **G**lobal: 模块级别
- **B**uilt-in: 内置作用域

```python
x = "global"

def outer():
    x = "enclosing"
    
    def inner():
        x = "local"
        print(x)  # local
    
    inner()
    print(x)  # enclosing

outer()
print(x)  # global
```

### global 和 nonlocal 关键字

```python
# global - 修改全局变量
count = 0

def increment():
    global count
    count += 1

increment()
print(count)  # 1

# nonlocal - 修改外层函数变量
def make_counter():
    count = 0
    
    def increment():
        nonlocal count
        count += 1
        return count
    
    return increment

counter = make_counter()
print(counter())  # 1
print(counter())  # 2
```

### Go 语言对比

```go
// Go 没有 global 关键字
// 包级别变量可以直接访问
var count int = 0

func increment() {
    count++  // 直接修改包级别变量
}

// Go 没有 nested 函数，所以没有 nonlocal
// 需要使用闭包或结构体
func makeCounter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}
```

### 闭包

```python
def make_multiplier(factor):
    def multiply(x):
        return x * factor
    return multiply

double = make_multiplier(2)
triple = make_multiplier(3)

print(double(5))  # 10
print(triple(5))  # 15
```

---

## 匿名函数

### lambda 表达式

```python
# 基本用法
square = lambda x: x ** 2
print(square(5))  # 25

# 多参数
add = lambda x, y: x + y
print(add(3, 4))  # 7

# 与内置函数配合使用
numbers = [1, 5, 3, 9, 2]
sorted_numbers = sorted(numbers, key=lambda x: -x)

# 与 filter 配合
evens = list(filter(lambda x: x % 2 == 0, range(10)))

# 与 map 配合
squares = list(map(lambda x: x ** 2, range(5)))
```

### Go 语言对比

```go
// Go 有函数字面量（匿名函数）
square := func(x int) int {
    return x * x
}
fmt.Println(square(5))  // 25

// 作为参数传递
numbers := []int{1, 5, 3, 9, 2}
sort.Slice(numbers, func(i, j int) bool {
    return numbers[i] > numbers[j]
})
```

---

## 模块与包

### 模块基础

```python
# math.py (模块文件)
"""数学工具模块"""

PI = 3.14159

def add(a, b):
    return a + b

def multiply(a, b):
    return a * b

# main.py (使用模块)
import math

print(math.PI)
print(math.add(2, 3))
```

### Go 语言对比

```go
// Go 的包结构
// math/math.go
package math

const PI = 3.14159

func Add(a, b int) int {
    return a + b
}

// main.go
package main

import "yourmodule/math"

fmt.Println(math.PI)
fmt.Println(math.Add(2, 3))
```

### 导入方式

```python
# 导入整个模块
import math
print(math.sqrt(16))

# 导入特定成员
from math import sqrt, pi
print(sqrt(16))
print(pi)

# 导入并重命名
import numpy as np
from math import sqrt as square_root

# 导入所有（不推荐）
from math import *
```

### Go 语言对比

```go
// 导入包
import (
    "fmt"
    "math"
)

// 重命名导入
import (
    m "math"
    . "fmt"  // 点导入，可以直接使用函数
)

// Go 没有 from ... import * 的等价物
```

### 包结构

```
my_package/
├── __init__.py
├── module1.py
├── module2.py
└── subpackage/
    ├── __init__.py
    └── module3.py
```

```python
# 导入包中的模块
from my_package import module1
from my_package.module1 import function1
from my_package.subpackage import module3

# __init__.py 可以定义包的公共接口
# my_package/__init__.py
from .module1 import public_function
from .module2 import AnotherClass

__all__ = ['public_function', 'AnotherClass']
```

### Go 语言对比

```
// Go 的包结构
my_package/
├── go.mod
├── module1.go
├── module2.go
└── subpackage/
    └── module3.go
```

### `__name__` 和 `__main__`

```python
# module.py
def main():
    print("Running as script")

if __name__ == "__main__":
    main()
# 直接运行：执行 main()
# 被导入：不执行 main()
```

### Go 语言对比

```go
// Go 的 main 函数
package main

func main() {
    fmt.Println("Running as executable")
}
// 只有 main 包中的 main 函数是程序入口
```

---

## 常用内置函数

### 类型转换函数

```python
int("42")           # 42
float("3.14")       # 3.14
str(123)            # "123"
list("abc")         # ['a', 'b', 'c']
tuple([1, 2, 3])    # (1, 2, 3)
dict(a=1, b=2)      # {'a': 1, 'b': 2}
set([1, 2, 2])      # {1, 2}
bool(0)             # False
bool(1)             # True
```

### 序列操作函数

```python
len([1, 2, 3])           # 3
max([1, 5, 3])           # 5
min([1, 5, 3])           # 1
sum([1, 2, 3, 4])        # 10
sorted([3, 1, 2])        # [1, 2, 3]
reversed([1, 2, 3])      # 迭代器
enumerate(['a', 'b'])    # 迭代器，返回 (索引，值)
zip([1, 2], ['a', 'b'])  # 迭代器，返回 (1, 'a'), (2, 'b')
```

### 函数式编程工具

```python
# map - 对每个元素应用函数
squares = list(map(lambda x: x**2, [1, 2, 3, 4]))  # [1, 4, 9, 16]

# filter - 过滤元素
evens = list(filter(lambda x: x % 2 == 0, [1, 2, 3, 4]))  # [2, 4]

# reduce - 累积计算（需要从 functools 导入）
from functools import reduce
product = reduce(lambda x, y: x * y, [1, 2, 3, 4])  # 24
```

### Go 语言对比

```go
// Go 需要手动实现或使用泛型（Go 1.18+）
// 长度
len(slice)

// Go 1.21+ 添加了 min/max 内置函数
min(a, b)
max(a, b)

// 求和需要手动循环
sum := 0
for _, n := range numbers {
    sum += n
}
```

### 其他常用内置函数

```python
# 对象信息
type(obj)           # 返回类型
id(obj)             # 返回内存地址
dir(obj)            # 返回属性和方法列表
help(obj)           # 显示帮助信息
isinstance(obj, type)  # 类型检查
issubclass(cls, base)  # 类继承关系检查

# 属性操作
getattr(obj, 'attr')    # 获取属性
setattr(obj, 'attr', v) # 设置属性
hasattr(obj, 'attr')    # 检查属性是否存在
delattr(obj, 'attr')    # 删除属性

# 可调用性
callable(obj)       # 检查是否可调用

# 创建迭代器
iter(obj)           # 创建迭代器
next(iterator)      # 获取下一个元素
```

---

## 装饰器（函数增强）

```python
# 简单装饰器
def timer(func):
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end-start:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    import time
    time.sleep(1)

slow_function()
```

详细装饰器用法请参考 [高级特性手册](./python 高级特性手册.md)。

---

## Python 与 Go 函数对比总结

| 特性 | Python | Go |
|------|--------|-----|
| 函数定义 | `def name():` | `func name() {}` |
| 参数类型 | 动态/注解 | 静态类型 |
| 默认参数 | 支持 | 不支持 |
| 可变参数 | `*args`, `**kwargs` | `...T` |
| 多返回值 | 元组 | 原生支持 |
| 命名返回值 | 不支持 | 支持 |
| 匿名函数 | `lambda` | `func() {}` |
| 嵌套函数 | 支持 | 不支持 |
| 闭包 | 支持 | 支持 |
| 装饰器 | 支持 | 不支持 |
| defer | 无 | 支持 |
| panic/recover | 异常机制 | 类似机制 |
