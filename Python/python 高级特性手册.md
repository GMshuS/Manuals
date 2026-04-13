# Python 高级特性手册

> 本手册对比 Go 语言，详细介绍 Python 的高级编程特性

## 目录

1. [装饰器](#装饰器)
2. [生成器](#生成器)
3. [迭代器](#迭代器)
4. [上下文管理器](#上下文管理器)
5. [描述符](#描述符)
6. [元类](#元类)
7. [类型注解](#类型注解)
8. [并发编程基础](#并发编程基础)

---

## 装饰器

### 装饰器基础

装饰器是修改或增强函数行为的 Callable 对象。

```python
# 简单装饰器
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("Before function call")
        result = func(*args, **kwargs)
        print("After function call")
        return result
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
# Before function call
# Hello!
# After function call
```

### Go 语言对比

```go
// Go 没有装饰器，可以使用函数包装
type Handler func() string

func withLogging(h Handler) Handler {
    return func() string {
        fmt.Println("Before")
        result := h()
        fmt.Println("After")
        return result
    }
}

func sayHello() string {
    fmt.Println("Hello!")
    return ""
}

// 使用
handler := withLogging(sayHello)
handler()
```

### 带参数的装饰器

```python
def repeat(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(3)
def greet(name):
    print(f"Hello, {name}!")

greet("Alice")  # 打印 3 次
```

### 保留函数元数据

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def say_hello():
    """Say hello"""
    print("Hello!")

print(say_hello.__name__)  # say_hello
print(say_hello.__doc__)   # Say hello
```

### 类装饰器

```python
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0
    
    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"Call {self.count}")
        return self.func(*args, **kwargs)

@CountCalls
def greet(name):
    print(f"Hello, {name}!")

greet("Alice")  # Call 1
greet("Bob")    # Call 2
```

### 常用装饰器

```python
from functools import lru_cache, singledispatch

# 缓存装饰器
@lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# 单分派泛函数
@singledispatch
def process(arg):
    print(f"Processing: {arg}")

@process.register
def _(arg: int):
    print(f"Processing integer: {arg}")

@process.register
def _(arg: str):
    print(f"Processing string: {arg}")

process(42)      # Processing integer: 42
process("hello") # Processing string: hello
process([1, 2])  # Processing: [1, 2]
```

---

## 生成器

### 生成器函数

```python
def count_up_to(n):
    """生成器函数"""
    count = 1
    while count <= n:
        yield count
        count += 1

# 使用生成器
for num in count_up_to(5):
    print(num)  # 1, 2, 3, 4, 5

# 生成器对象
gen = count_up_to(3)
print(next(gen))  # 1
print(next(gen))  # 2
```

### Go 语言对比

```go
// Go 没有生成器，使用 channel 模拟
func countUpTo(n int) <-chan int {
    ch := make(chan int)
    go func() {
        for i := 1; i <= n; i++ {
            ch <- i
        }
        close(ch)
    }()
    return ch
}

// 使用
for num := range countUpTo(5) {
    fmt.Println(num)
}
```

### 生成器表达式

```python
# 列表推导式 vs 生成器表达式
squares_list = [x**2 for x in range(10)]  # 立即计算
squares_gen = (x**2 for x in range(10))   # 惰性计算

# 内存效率
import sys
gen = (x for x in range(1000000))
lst = [x for x in range(1000000)]
print(sys.getsizeof(gen))  # 小
print(sys.getsizeof(lst))  # 大
```

### send() 和 close()

```python
def accumulator():
    total = 0
    while True:
        value = yield total
        if value is None:
            break
        total += value

gen = accumulator()
next(gen)          # 0 (启动生成器)
gen.send(10)       # 10
gen.send(20)       # 30
gen.send(None)     # 关闭
```

### yield from

```python
def sub_generator():
    yield 1
    yield 2
    yield 3

def main_generator():
    yield from sub_generator()
    yield 4
    yield 5

list(main_generator())  # [1, 2, 3, 4, 5]
```

---

## 迭代器

### 迭代器协议

```python
class Counter:
    def __init__(self, start, end):
        self.current = start
        self.end = end
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.current > self.end:
            raise StopIteration
        value = self.current
        self.current += 1
        return value

# 使用
for num in Counter(1, 5):
    print(num)  # 1, 2, 3, 4, 5
```

### Go 语言对比

```go
// Go 使用迭代器模式（Go 1.23+ 有 range over func）
type Counter struct {
    current, end int
}

func (c *Counter) Next() (int, bool) {
    if c.current > c.end {
        return 0, false
    }
    value := c.current
    c.current++
    return value, true
}
```

### 内置迭代器工具

```python
from itertools import count, cycle, islice, chain, groupby

# 无限迭代器
for i in count(10, 2):  # 10, 12, 14, ...
    if i > 20:
        break

# 循环迭代器
for item in islice(cycle(['A', 'B', 'C']), 5):  # A, B, C, A, B
    print(item)

# 链接迭代器
for item in chain([1, 2], ['a', 'b']):  # 1, 2, a, b
    print(item)

# 分组
data = [('A', 1), ('A', 2), ('B', 3)]
for key, group in groupby(data, key=lambda x: x[0]):
    print(key, list(group))
```

---

## 上下文管理器

### with 语句

```python
# 文件操作
with open("file.txt") as f:
    content = f.read()

# 多个上下文管理器
with open("in.txt") as infile, open("out.txt", "w") as outfile:
    outfile.write(infile.read())
```

### 创建上下文管理器（类方式）

```python
class ManagedFile:
    def __init__(self, filename, mode):
        self.filename = filename
        self.mode = mode
        self.file = None
    
    def __enter__(self):
        self.file = open(self.filename, self.mode)
        return self.file
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.file:
            self.file.close()
        return False

# 使用
with ManagedFile("test.txt", "w") as f:
    f.write("Hello")
```

### 创建上下文管理器（contextlib）

```python
from contextlib import contextmanager

@contextmanager
def managed_file(filename, mode):
    f = open(filename, mode)
    try:
        yield f
    finally:
        f.close()

# 使用
with managed_file("test.txt", "w") as f:
    f.write("Hello")
```

### contextlib 其他工具

```python
from contextlib import redirect_stdout, suppress
import io

# 重定向输出
f = io.StringIO()
with redirect_stdout(f):
    print("Hello")
output = f.getvalue()

# 抑制异常
with suppress(FileNotFoundError):
    os.remove("nonexistent.txt")
```

---

## 描述符

### 描述符协议

```python
class Descriptor:
    def __get__(self, obj, objtype=None):
        return self.value
    
    def __set__(self, obj, value):
        self.value = value

class MyClass:
    attr = Descriptor()

obj = MyClass()
obj.attr = 10
print(obj.attr)
```

### 属性描述符

```python
class ValidatedAttribute:
    def __init__(self, validator):
        self.validator = validator
        self.name = None
    
    def __set_name__(self, owner, name):
        self.name = name
    
    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        return obj.__dict__.get(self.name)
    
    def __set__(self, obj, value):
        if self.validator(value):
            obj.__dict__[self.name] = value
        else:
            raise ValueError(f"Invalid value for {self.name}")

class Person:
    age = ValidatedAttribute(lambda x: isinstance(x, int) and x >= 0)
    name = ValidatedAttribute(lambda x: isinstance(x, str) and len(x) > 0)

p = Person()
p.age = 25
p.name = "Alice"
```

---

## 元类

### 元类基础

```python
# 元类是创建类的类
class SingletonMeta(type):
    _instances = {}
    
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class Singleton(metaclass=SingletonMeta):
    pass

s1 = Singleton()
s2 = Singleton()
print(s1 is s2)  # True
```

### 元类应用

```python
# 自动注册子类
class RegistryMeta(type):
    registry = {}
    
    def __new__(mcs, name, bases, namespace):
        cls = super().__new__(mcs, name, bases, namespace)
        if name != 'Base':
            RegistryMeta.registry[name] = cls
        return cls

class Base(metaclass=RegistryMeta):
    pass

class PluginA(Base):
    pass

class PluginB(Base):
    pass

print(RegistryMeta.registry)
```

---

## 类型注解

### 基础类型注解

```python
# 变量注解
name: str = "Alice"
age: int = 25
height: float = 1.75

# 函数注解
def greet(name: str, greeting: str = "Hello") -> str:
    return f"{greeting}, {name}!"

# 类型提示
from typing import List, Dict, Optional, Union

def process(items: List[int]) -> Dict[str, int]:
    return {"sum": sum(items)}

def get_item(index: int) -> Optional[str]:
    if index < 0:
        return None
    return "item"

def parse(value: Union[str, int]) -> int:
    return int(value)
```

### 高级类型注解

```python
from typing import Callable, Generic, TypeVar

# Callable
def apply(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

# 泛型
T = TypeVar('T')

def first(items: List[T]) -> T:
    return items[0]

class Container(Generic[T]):
    def __init__(self, item: T):
        self.item = item
```

### Python 3.10+ 新语法

```python
# 联合类型
def process(value: int | str) -> None:
    pass

# 可选类型
def get_name() -> str | None:
    pass
```

---

## 并发编程基础

### 线程（threading）

```python
import threading
import time

def worker(name, delay):
    for i in range(3):
        time.sleep(delay)
        print(f"{name}: {i}")

t1 = threading.Thread(target=worker, args=("A", 0.5))
t2 = threading.Thread(target=worker, args=("B", 0.5))

t1.start()
t2.start()
t1.join()
t2.join()

# 线程锁
lock = threading.Lock()
counter = 0

def increment():
    global counter
    with lock:
        counter += 1
```

### Go 语言对比

```go
// Go 使用 goroutine
func worker(name string, delay time.Duration) {
    for i := 0; i < 3; i++ {
        time.Sleep(delay)
        fmt.Printf("%s: %d\n", name, i)
    }
}

var wg sync.WaitGroup
wg.Add(2)
go func() {
    defer wg.Done()
    worker("A", 500*time.Millisecond)
}()
go func() {
    defer wg.Done()
    worker("B", 500*time.Millisecond)
}()
wg.Wait()

// 互斥锁
var mu sync.Mutex
var counter int

func increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}
```

### 异步编程（asyncio）

```python
import asyncio

async def fetch_data(url):
    await asyncio.sleep(1)
    return f"Data from {url}"

async def main():
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        fetch_data("url3")
    )

asyncio.run(main())
```

---

## Python 与 Go 高级特性对比总结

| 特性 | Python | Go |
|------|--------|-----|
| 装饰器 | @decorator | 函数包装 |
| 生成器 | yield | channel |
| 迭代器 | __iter__, __next__ | range over func (1.23+) |
| 上下文管理器 | with, __enter__/__exit__ | defer |
| 描述符 | __get__/__set__ | getter/setter |
| 元类 | metaclass | 反射/工厂模式 |
| 类型系统 | 动态 + 注解 | 静态类型 |
| 泛型 | TypeVar, Generic | 泛型（1.18+） |
| 并发模型 | threading, asyncio | goroutine, channel |
| 模式匹配 | match-case | switch |
