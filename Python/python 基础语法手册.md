# Python 基础语法手册

> 本手册对比 Go 语言，详细介绍 Python 的基础语法特性

## 目录

1. [变量与常量](#变量与常量)
2. [基本数据类型](#基本数据类型)
3. [类型转换](#类型转换)
4. [运算符](#运算符)
5. [流程控制](#流程控制)
6. [字符串操作](#字符串操作)

---

## 变量与常量

### Python 变量声明

Python 使用动态类型，变量无需显式声明类型：

```python
# 变量赋值
name = "Alice"
age = 25
height = 1.75
is_student = False

# 多重赋值
x, y, z = 1, 2, 3
a = b = c = 0

# 交换变量值
x, y = y, x
```

### Go 语言对比

```go
// Go 需要显式声明类型或使用类型推断
var name string = "Alice"  // 显式声明
age := 25                   // 类型推断
const PI = 3.14159          // 常量
```

### Python 常量约定

Python 没有真正的常量，通过命名约定表示：

```python
# 常量（命名约定：全大写）
MAX_SIZE = 100
PI = 3.14159
DEFAULT_TIMEOUT = 30
```

---

## 基本数据类型

### Python 内置类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `int` | 整数 | `42`, `-17`, `0` |
| `float` | 浮点数 | `3.14`, `-0.5`, `2.0` |
| `complex` | 复数 | `3+4j`, `1-2j` |
| `str` | 字符串 | `"hello"`, `'world'` |
| `bool` | 布尔值 | `True`, `False` |
| `bytes` | 字节序列 | `b'hello'` |
| `NoneType` | 空值 | `None` |

```python
# 整数
num = 42
big_num = 10**100  # Python 支持任意精度整数

# 浮点数
pi = 3.14159
scientific = 1.23e-4  # 科学计数法

# 复数
c = 3 + 4j
print(c.real)  # 3.0
print(c.imag)  # 4.0

# 字符串
s1 = 'single quotes'
s2 = "double quotes"
s3 = '''multi
line'''

# 布尔值
is_valid = True
is_empty = False

# None 表示空值
result = None
```

### Go 语言对比

```go
// Go 的基本类型
var num int = 42
var pi float64 = 3.14159
var complexNum complex128 = 3 + 4i
var str string = "hello"
var valid bool = true
// Go 没有 None，使用 nil（用于指针、切片等）
```

---

## 类型转换

### Python 类型转换

```python
# 数值转换
int("42")        # 42
float("3.14")    # 3.14
str(123)         # "123"
bool(1)          # True
bool("")         # False

# 其他转换
list("abc")      # ['a', 'b', 'c']
tuple([1, 2, 3]) # (1, 2, 3)
set([1, 2, 2])   # {1, 2}
```

### Go 语言对比

```go
// Go 需要显式类型转换
i := 42
f := float64(i)     // int 转 float64
s := strconv.Itoa(i) // int 转 string
```

---

## 运算符

### 算术运算符

```python
a, b = 10, 3

a + b   # 加法：13
a - b   # 减法：7
a * b   # 乘法：30
a / b   # 除法：3.333...
a // b  # 整除：3
a % b   # 取模：1
a ** b  # 幂运算：1000
```

### Go 语言对比

```go
// Go 没有 // 整除运算符，使用 / (整数相除)
// Go 没有 ** 幂运算，使用 math.Pow()
// Go 的 ++ 和 -- 只能作为语句，不能作为表达式
```

### 比较运算符

```python
a == b   # 等于
a != b   # 不等于
a > b    # 大于
a < b    # 小于
a >= b   # 大于等于
a <= b   # 小于等于

# Python 支持链式比较
1 < x < 10  # 等价于 1 < x and x < 10
```

### 逻辑运算符

```python
# Python 使用英文单词
a and b   # 与
a or b    # 或
not a     # 非

# 短路求值
result = x and x > 0  # 如果 x 为假，不会计算 x > 0
```

### Go 语言对比

```go
// Go 使用符号
a && b   // 与
a || b   // 或
!a       // 非
```

### 位运算符

```python
a & b    # 按位与
a | b    # 按位或
a ^ b    # 按位异或
~a       # 按位取反
a << 2   # 左移
a >> 2   # 右移
```

### 赋值运算符

```python
a += b    # a = a + b
a -= b    # a = a - b
a *= b    # a = a * b
a /= b    # a = a / b
a //= b   # a = a // b
a %= b    # a = a % b
a **= b   # a = a ** b
a &= b    # a = a & b
a |= b    # a = a | b
a ^= b    # a = a ^ b
a <<= 2   # a = a << 2
a >>= 2   # a = a >> 2
```

### 成员运算符和身份运算符

```python
# 成员运算符
x in [1, 2, 3]      # True 如果 x 在列表中
x not in [1, 2, 3]  # True 如果 x 不在列表中

# 身份运算符（比较对象内存地址）
a is b      # True 如果 a 和 b 是同一对象
a is not b  # True 如果 a 和 b 不是同一对象

# 示例
x = [1, 2, 3]
y = x
z = [1, 2, 3]
x is y  # True (同一对象)
x is z  # False (不同对象，尽管内容相同)
x == z  # True (内容相同)
```

---

## 流程控制

### if-elif-else 语句

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

### Go 语言对比

```go
// Go 的 if 语句
if age < 12 {
    fmt.Println("儿童")
} else if age < 18 {
    fmt.Println("青少年")
} else {
    fmt.Println("成年人")
}

// Go 的三元运算符只支持简单情况
// status := "成年"; if age < 18 { status = "未成年" }
```

### for 循环

```python
# 遍历序列
for i in range(5):      # 0, 1, 2, 3, 4
    print(i)

for i in range(1, 6):   # 1, 2, 3, 4, 5
    print(i)

for i in range(0, 10, 2):  # 0, 2, 4, 6, 8
    print(i)

# 遍历字符串
for char in "hello":
    print(char)

# 遍历列表
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)

# 带索引遍历
for i, fruit in enumerate(fruits):
    print(f"{i}: {fruit}")
```

### Go 语言对比

```go
// Go 的 for 循环（三种形式）
for i := 0; i < 5; i++ { }           // 传统 for
for i < 5 { }                         // while 风格
for { }                               // 无限循环

// 遍历
for i, fruit := range fruits { }     // range 遍历
```

### while 循环

```python
count = 0
while count < 5:
    print(count)
    count += 1

# break 和 continue
while True:
    if count > 10:
        break
    count += 1
    if count % 2 == 0:
        continue
```

### Go 语言对比

```go
// Go 没有 while 关键字，使用 for
for count < 5 {
    count++
}
```

### match-case 语句（Python 3.10+）

```python
status = 404

match status:
    case 200:
        print("OK")
    case 404:
        print("Not Found")
    case 500:
        print("Server Error")
    case _:
        print("Unknown")

# 模式匹配
point = (1, 2)
match point:
    case (0, 0):
        print("原点")
    case (0, y):
        print(f"Y 轴上的点，y={y}")
    case (x, 0):
        print(f"X 轴上的点，x={x}")
    case (x, y):
        print(f"普通点，x={x}, y={y}")
```

### Go 语言对比

```go
// Go 的 switch 语句
switch status {
case 200:
    fmt.Println("OK")
case 404:
    fmt.Println("Not Found")
default:
    fmt.Println("Unknown")
}
```

---

## 字符串操作

### 字符串定义

```python
s1 = 'single quotes'
s2 = "double quotes"
s3 = '''多行
字符串'''
s4 = """多行
字符串"""

# 原始字符串（不转义）
path = r"C:\Users\name"
regex = r"\d+\.\d+"

# f-string（格式化字符串）
name = "Alice"
age = 25
message = f"Hello, {name}! You are {age} years old."
```

### Go 语言对比

```go
// Go 的字符串
s1 := "double quotes only"
s2 := `raw string
can be multi-line`
// Go 使用 fmt.Sprintf 格式化
msg := fmt.Sprintf("Hello, %s!", name)
```

### 字符串索引和切片

```python
s = "Hello, World!"

s[0]      # 'H'
s[-1]     # '!'
s[0:5]    # 'Hello'
s[7:]     # 'World!'
s[:5]     # 'Hello'
s[-6:-1]  # 'World'
s[::2]    # 'Hlo ol!'
s[::-1]   # '!dlroW ,olleH'
```

### Go 语言对比

```go
// Go 的字符串切片
s := "Hello, World!"
s[0:5]  // "Hello"
// Go 不支持负索引和步长
```

### 常用字符串方法

```python
s = "  Hello, World!  "

# 大小写转换
s.lower()           # "  hello, world!  "
s.upper()           # "  HELLO, WORLD!  "
s.capitalize()      # "  hello, world!  "
s.title()           # "  Hello, World!  "
s.swapcase()        # "  hELLO, wORLD!  "

# 去除空白
s.strip()           # "Hello, World!"
s.lstrip()          # "Hello, World!  "
s.rstrip()          # "  Hello, World!"

# 查找和替换
s.find("World")     # 10
s.count("o")        # 2
s.replace("World", "Python")  # "  Hello, Python!  "

# 分割和连接
"hello world".split()        # ['hello', 'world']
"a,b,c".split(",")           # ['a', 'b', 'c']
"-".join(["a", "b", "c"])    # "a-b-c"

# 判断
s.startswith("Hello")        # False (因为有空格)
s.endswith("!")              # True
"123".isdigit()              # True
"abc".isalpha()              # True
"abc123".isalnum()           # True
```

### 字符串格式化

```python
name = "Alice"
age = 25
height = 1.75

# f-string (Python 3.6+)
f"{name} is {age} years old"

# format 方法
"{} is {} years old".format(name, age)
"{0} is {1} years old".format(name, age)
"{name} is {age} years old".format(name=name, age=age)

# 格式化数字
f"{height:.2f}"           # "1.75"
f"{age:05d}"              # "00025"
f"{0.25:%}"               # "25.000000%"
f"{1000000:,}"            # "1,000,000"
```

### Go 语言对比

```go
// Go 的字符串格式化
import "fmt"
fmt.Sprintf("%s is %d years old", name, age)
fmt.Sprintf("%.2f", height)
```

---

## Python 与 Go 语法对比总结

| 特性 | Python | Go |
|------|--------|-----|
| 变量声明 | `x = 1` | `x := 1` 或 `var x int = 1` |
| 类型系统 | 动态类型 | 静态类型 |
| 代码块 | 缩进 | 花括号 `{}` |
| 语句结束 | 换行 | 分号（可选） |
| 布尔值 | `True`, `False` | `true`, `false` |
| 空值 | `None` | `nil` |
| 逻辑运算符 | `and`, `or`, `not` | `&&`, `||`, `!` |
| 循环 | `for`, `while` | 只有 `for` |
| 条件分支 | `if-elif-else`, `match-case` | `if-else`, `switch` |
| 字符串插值 | f-string | `fmt.Sprintf` |
| 多返回值 | 元组 | 原生支持 |
