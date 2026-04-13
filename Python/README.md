# Python 编程语法使用手册

> 本系列手册对比 Go 语言，全面介绍 Python 编程语法和最佳实践

## 手册目录

### 📚 核心语法

| 手册 | 描述 |
|------|------|
| [基础语法手册](./python 基础语法手册.md) | 变量、数据类型、运算符、流程控制、字符串操作 |
| [数据结构手册](./python 数据结构手册.md) | 列表、元组、字典、集合、字节序列 |
| [函数与模块手册](./python 函数与模块手册.md) | 函数定义、参数传递、作用域、模块系统 |

### 🏗️ 高级主题

| 手册 | 描述 |
|------|------|
| [面向对象编程手册](./python 面向对象编程手册.md) | 类与对象、继承、多态、特殊方法、装饰器 |
| [异常处理手册](./python 异常处理手册.md) | try-except、自定义异常、异常链、最佳实践 |
| [文件操作手册](./python 文件操作手册.md) | 文件读写、路径操作、序列化、标准 IO |
| [高级特性手册](./python 高级特性手册.md) | 装饰器、生成器、迭代器、上下文管理器、元类、类型注解 |
| [并发编程手册](./python 并发编程手册.md) | 多线程、多进程、异步编程、同步原语 |

### 🔧 其他手册

| 手册 | 描述 |
|------|------|
| [项目全流程：pip+venv](./python 项目全流程：pip+venv 使用详解.md) | 虚拟环境、包管理 |
| [项目全流程：uv](./python 项目全流程：uv 使用详解.md) | 现代化 Python 项目管理工具 |

---

## 快速索引

### 基础概念

- [变量与常量](./python 基础语法手册.md#变量与常量)
- [基本数据类型](./python 基础语法手册.md#基本数据类型)
- [类型转换](./python 基础语法手册.md#类型转换)
- [运算符](./python 基础语法手册.md#运算符)
- [流程控制](./python 基础语法手册.md#流程控制)
- [字符串操作](./python 基础语法手册.md#字符串操作)

### 数据结构

- [列表 (List)](./python 数据结构手册.md#列表-list)
- [元组 (Tuple)](./python 数据结构手册.md#元组-tuple)
- [字典 (Dictionary)](./python 数据结构手册.md#字典-dictionary)
- [集合 (Set)](./python 数据结构手册.md#集合-set)
- [数据结构对比](./python 数据结构手册.md#数据结构对比)

### 函数与模块

- [函数定义](./python 函数与模块手册.md#函数定义)
- [参数传递](./python 函数与模块手册.md#参数传递)
- [返回值](./python 函数与模块手册.md#返回值)
- [作用域](./python 函数与模块手册.md#作用域)
- [匿名函数](./python 函数与模块手册.md#匿名函数)
- [模块与包](./python 函数与模块手册.md#模块与包)
- [常用内置函数](./python 函数与模块手册.md#常用内置函数)

### 面向对象

- [类与对象](./python 面向对象编程手册.md#类与对象)
- [构造函数](./python 面向对象编程手册.md#构造函数)
- [实例方法和类方法](./python 面向对象编程手册.md#实例方法和类方法)
- [属性访问控制](./python 面向对象编程手册.md#属性访问控制)
- [继承](./python 面向对象编程手册.md#继承)
- [多态](./python 面向对象编程手册.md#多态)
- [特殊方法](./python 面向对象编程手册.md#特殊方法)
- [属性装饰器](./python 面向对象编程手册.md#属性装饰器)
- [抽象基类](./python 面向对象编程手册.md#抽象基类)

### 异常处理

- [try-except 语句](./python 异常处理手册.md#try-except-语句)
- [finally 子句](./python 异常处理手册.md#finally 子句)
- [抛出异常](./python 异常处理手册.md#抛出异常)
- [自定义异常](./python 异常处理手册.md#自定义异常)
- [异常链](./python 异常处理手册.md#异常链)
- [常见内置异常](./python 异常处理手册.md#常见内置异常)
- [最佳实践](./python 异常处理手册.md#异常处理最佳实践)

### 文件操作

- [文件打开与关闭](./python 文件操作手册.md#文件打开与关闭)
- [文件读取](./python 文件操作手册.md#文件读取)
- [文件写入](./python 文件操作手册.md#文件写入)
- [文件路径操作](./python 文件操作手册.md#文件路径操作)
- [文件和目录管理](./python 文件操作手册.md#文件和目录管理)
- [序列化](./python 文件操作手册.md#序列化)
- [文本与二进制文件](./python 文件操作手册.md#文本与二进制文件)

### 高级特性

- [装饰器](./python 高级特性手册.md#装饰器)
- [生成器](./python 高级特性手册.md#生成器)
- [迭代器](./python 高级特性手册.md#迭代器)
- [上下文管理器](./python 高级特性手册.md#上下文管理器)
- [描述符](./python 高级特性手册.md#描述符)
- [元类](./python 高级特性手册.md#元类)
- [类型注解](./python 高级特性手册.md#类型注解)

### 并发编程

- [线程基础](./python 并发编程手册.md#线程基础)
- [线程同步](./python 并发编程手册.md#线程同步)
- [多进程](./python 并发编程手册.md#多进程)
- [异步编程](./python 并发编程手册.md#异步编程)
- [并发最佳实践](./python 并发编程手册.md#并发最佳实践)

---

## Python vs Go 快速对照

### 语法差异

| 特性 | Python | Go |
|------|--------|-----|
| 变量声明 | `x = 1` | `x := 1` |
| 类型系统 | 动态类型 | 静态类型 |
| 代码块 | 缩进 | 花括号 `{}` |
| 布尔值 | `True`, `False` | `true`, `false` |
| 空值 | `None` | `nil` |
| 逻辑运算符 | `and`, `or`, `not` | `&&`, `||`, `!` |

### 数据结构对照

| Python | Go |
|--------|-----|
| list | slice |
| tuple | struct/array |
| dict | map |
| set | map[T]bool |
| str | string |

### 并发模型对照

| Python | Go |
|--------|-----|
| threading.Thread | goroutine |
| threading.Lock | sync.Mutex |
| queue.Queue | chan T |
| asyncio | goroutine + channel |

---

## 学习路径建议

### 初学者

1. 📖 [基础语法手册](./python 基础语法手册.md) - 掌握 Python 基本语法
2. 📦 [数据结构手册](./python 数据结构手册.md) - 理解内置数据结构
3. 🔧 [函数与模块手册](./python 函数与模块手册.md) - 学习函数定义和模块使用
4. 📝 [文件操作手册](./python 文件操作手册.md) - 掌握文件读写
5. ⚠️ [异常处理手册](./python 异常处理手册.md) - 学会错误处理

### 进阶开发者

1. 🏗️ [面向对象编程手册](./python 面向对象编程手册.md) - 深入理解 OOP
2. 🚀 [高级特性手册](./python 高级特性手册.md) - 掌握装饰器、生成器等
3. 🔀 [并发编程手册](./python 并发编程手册.md) - 学习并发编程

### 项目实战

1. 📦 [pip+venv 使用详解](./python 项目全流程：pip+venv 使用详解.md)
2. ⚡ [uv 使用详解](./python 项目全流程：uv 使用详解.md)

---

## 代码示例索引

### 常用代码片段

#### 列表推导式
```python
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]
```

#### 字典推导式
```python
squares = {x: x**2 for x in range(5)}
swapped = {v: k for k, v in original.items()}
```

#### 装饰器
```python
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

#### 上下文管理器
```python
from contextlib import contextmanager

@contextmanager
def managed_resource():
    resource = acquire()
    try:
        yield resource
    finally:
        release(resource)
```

#### 异步函数
```python
import asyncio

async def fetch_data(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()
```

---

## 附录

### Python 版本兼容性

本手册主要基于 Python 3.8+ 编写，部分特性需要更新版本：

- `walrus` 运算符 (`:=`)：Python 3.8+
- `match-case` 语句：Python 3.10+
- 联合类型语法 (`int | str`)：Python 3.10+

### 参考资源

- [Python 官方文档](https://docs.python.org/3/)
- [PEP 索引](https://peps.python.org/)
- [Python Cookbook](https://pypi.org/project/python-cookbook/)
- [Real Python](https://realpython.com/)

### 版本信息

- 手册版本：1.0
- 最后更新：2024
- Python 目标版本：3.8+
- Go 对比版本：1.18+
