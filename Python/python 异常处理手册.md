# Python 异常处理手册

> 本手册对比 Go 语言，详细介绍 Python 的异常处理机制

## 目录

1. [异常基础](#异常基础)
2. [try-except 语句](#try-except-语句)
3. [finally 子句](#finally 子句)
4. [抛出异常](#抛出异常)
5. [自定义异常](#自定义异常)
6. [异常链](#异常链)
7. [常见内置异常](#常见内置异常)
8. [异常处理最佳实践](#异常处理最佳实践)

---

## 异常基础

### 什么是异常

异常是程序运行时发生的错误，它会中断正常的程序流程。Python 使用异常来处理错误情况。

```python
# 触发异常
result = 10 / 0  # ZeroDivisionError: division by zero
```

### Go 语言对比

```go
// Go 使用多返回值返回错误
result, err := divide(10, 0)
if err != nil {
    // 处理错误
    return
}

// Go 也有 panic/recover 机制（用于真正异常的情况）
```

---

## try-except 语句

### 基本语法

```python
try:
    # 可能抛出异常的代码
    result = 10 / 0
except ZeroDivisionError:
    # 处理特定异常
    print("Cannot divide by zero!")
```

### 捕获多个异常

```python
try:
    value = int(input("Enter a number: "))
    result = 10 / value
except ValueError:
    print("Invalid number!")
except ZeroDivisionError:
    print("Cannot divide by zero!")
```

### 捕获多个异常类型

```python
try:
    # 可能出错的代码
    pass
except (ValueError, TypeError, ZeroDivisionError) as e:
    print(f"Error occurred: {e}")
```

### 捕获所有异常

```python
try:
    risky_operation()
except Exception as e:
    print(f"An error occurred: {e}")

# 或记录异常
import logging
try:
    risky_operation()
except Exception as e:
    logging.exception("Operation failed")
```

### Go 语言对比

```go
// Go 需要显式检查每个错误
value, err := strconv.Atoi(input)
if err != nil {
    fmt.Println("Invalid number!")
    return
}

result, err := divide(10, value)
if err != nil {
    fmt.Println("Cannot divide by zero!")
    return
}
```

### else 子句

```python
try:
    value = int(input("Enter a number: "))
except ValueError:
    print("Invalid number!")
else:
    # 没有异常时执行
    print(f"You entered: {value}")
```

### Go 语言对比

```go
// Go 的 if-else 模式
value, err := getValue()
if err != nil {
    // 错误处理
    return
}
// else 分支：正常执行
fmt.Println("Value:", value)
```

---

## finally 子句

### 资源清理

```python
file = None
try:
    file = open("data.txt", "r")
    content = file.read()
except FileNotFoundError:
    print("File not found!")
finally:
    # 无论是否发生异常都会执行
    if file:
        file.close()
```

### Go 语言对比

```go
// Go 使用 defer 进行资源清理
file, err := os.Open("data.txt")
if err != nil {
    fmt.Println("File not found!")
    return
}
defer file.Close()  // 函数返回前自动关闭

content, err := io.ReadAll(file)
```

### try-finally 组合

```python
try:
    print("Acquiring resource...")
    # 使用资源
finally:
    print("Releasing resource...")
    # 释放资源
```

---

## 抛出异常

### raise 语句

```python
# 抛出异常
raise ValueError("Invalid value!")

# 重新抛出捕获的异常
try:
    process_data()
except Exception as e:
    print(f"Logging error: {e}")
    raise  # 重新抛出
```

### Go 语言对比

```go
// Go 使用 panic 抛出异常（不推荐常规使用）
panic("something went wrong")

// 通常返回错误
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}
```

### 条件抛出

```python
def set_age(age):
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age seems unrealistic")
    return age
```

---

## 自定义异常

### 创建自定义异常类

```python
class InvalidAgeError(Exception):
    """自定义年龄验证异常"""
    def __init__(self, age, message="Age must be between 0 and 150"):
        self.age = age
        self.message = message
        super().__init__(self.message)
    
    def __str__(self):
        return f"{self.age} -> {self.message}"

# 使用
def set_age(age):
    if age < 0 or age > 150:
        raise InvalidAgeError(age)
    return age

try:
    set_age(200)
except InvalidAgeError as e:
    print(e)  # 200 -> Age must be between 0 and 150
```

### 异常层次结构

```python
class AppException(Exception):
    """应用基础异常"""
    pass

class ValidationError(AppException):
    """验证错误"""
    pass

class AuthenticationError(AppException):
    """认证错误"""
    pass

class DatabaseError(AppException):
    """数据库错误"""
    pass

# 可以捕获整个层次结构
try:
    # 可能抛出各种应用异常
    pass
except AppException as e:
    print(f"Application error: {e}")
```

### Go 语言对比

```go
// Go 自定义错误类型
type InvalidAgeError struct {
    Age   int
    Message string
}

func (e *InvalidAgeError) Error() string {
    return fmt.Sprintf("%d -> %s", e.Age, e.Message)
}

// 使用
func setAge(age int) error {
    if age < 0 || age > 150 {
        return &InvalidAgeError{
            Age: age,
            Message: "Age must be between 0 and 150",
        }
    }
    return nil
}
```

---

## 异常链

### 异常包装

```python
class DatabaseError(Exception):
    pass

try:
    import psycopg2
    conn = psycopg2.connect(...)
except ImportError as e:
    raise DatabaseError("Database module not available") from e
except psycopg2.Error as e:
    raise DatabaseError("Failed to connect") from e
```

### 访问原始异常

```python
try:
    risky_operation()
except DatabaseError as e:
    if e.__cause__:
        print(f"Original error: {e.__cause__}")
```

### Go 语言对比

```go
// Go 错误包装（Go 1.13+）
type DatabaseError struct {
    Msg   string
    Err   error
}

func (e *DatabaseError) Error() string {
    return fmt.Sprintf("database error: %s: %v", e.Msg, e.Err)
}

func (e *DatabaseError) Unwrap() error {
    return e.Err
}

// 使用
if err != nil {
    return &DatabaseError{Msg: "failed to connect", Err: err}
}

// 检查包装的错误
var dbErr *DatabaseError
if errors.As(err, &dbErr) {
    // 处理数据库错误
}
```

---

## 常见内置异常

### 内置异常层次结构

```
BaseException
├── Exception
│   ├── ArithmeticError
│   │   ├── ZeroDivisionError
│   │   └── OverflowError
│   ├── AssertionError
│   ├── AttributeError
│   ├── EOFError
│   ├── ImportError
│   │   └── ModuleNotFoundError
│   ├── IndexError
│   ├── KeyError
│   ├── KeyboardInterrupt
│   ├── NameError
│   ├── OSError
│   │   ├── FileNotFoundError
│   │   └── PermissionError
│   ├── RuntimeError
│   │   └── RecursionError
│   ├── StopIteration
│   ├── SyntaxError
│   ├── TypeError
│   ├── ValueError
│   └── UnicodeError
└── SystemExit
```

### 常见异常及处理

```python
# ZeroDivisionError - 除零错误
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")

# ValueError - 值错误
try:
    age = int("not a number")
except ValueError:
    print("Invalid number format")

# TypeError - 类型错误
try:
    result = "hello" + 5
except TypeError:
    print("Cannot add string and int")

# KeyError - 字典键不存在
data = {"name": "Alice"}
try:
    age = data["age"]
except KeyError:
    print("Key 'age' not found")

# IndexError - 列表索引越界
items = [1, 2, 3]
try:
    item = items[10]
except IndexError:
    print("Index out of range")

# FileNotFoundError - 文件不存在
try:
    with open("nonexistent.txt") as f:
        content = f.read()
except FileNotFoundError:
    print("File not found")

# AttributeError - 属性不存在
class Person:
    pass

person = Person()
try:
    name = person.name
except AttributeError:
    print("Attribute 'name' not found")

# ImportError - 导入失败
try:
    import nonexistent_module
except ImportError:
    print("Module not found")
```

### Go 语言对比

```go
// Go 标准库中的常见错误
// os.ErrNotExist - 文件/目录不存在
file, err := os.Open("nonexistent.txt")
if errors.Is(err, os.ErrNotExist) {
    fmt.Println("File not found")
}

// strconv.ErrSyntax - 解析错误
num, err := strconv.Atoi("not a number")
if err != nil {
    // 处理解析错误
}
```

---

## 异常处理最佳实践

### 1. 捕获具体的异常

```python
# ❌ 不推荐
try:
    process()
except Exception:
    pass  # 吞掉所有异常

# ✅ 推荐
try:
    process()
except (ValueError, TypeError) as e:
    log_error(e)
    return None
```

### 2. 不要吞掉异常

```python
# ❌ 不推荐
try:
    risky_operation()
except:
    pass  # 静默失败

# ✅ 推荐
try:
    risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise  # 重新抛出或处理
```

### 3. 使用 finally 或 with 清理资源

```python
# ✅ 使用 with 语句
with open("file.txt") as f:
    content = f.read()

# ✅ 使用 finally
lock = acquire_lock()
try:
    critical_section()
finally:
    release_lock(lock)
```

### 4. 提供有意义的错误信息

```python
# ❌ 不推荐
raise ValueError("Error occurred")

# ✅ 推荐
raise ValueError(f"Invalid user ID: expected positive integer, got {user_id!r}")
```

### 5. 使用异常链

```python
# ✅ 保持异常上下文
try:
    config = load_config()
except FileNotFoundError as e:
    raise ConfigError("Configuration file missing") from e
```

### 6. 创建自定义异常层次结构

```python
class APIError(Exception):
    """API 基础错误"""
    pass

class AuthenticationError(APIError):
    """认证错误"""
    status_code = 401

class ValidationError(APIError):
    """验证错误"""
    status_code = 400

class NotFoundError(APIError):
    """资源不存在"""
    status_code = 404
```

---

## 上下文管理器（with 语句）

### 使用 with 处理资源

```python
# 文件操作
with open("input.txt") as infile, open("output.txt", "w") as outfile:
    content = infile.read()
    outfile.write(content.upper())

# 锁定
from threading import Lock
lock = Lock()

with lock:
    # 临界区代码
    shared_resource.modify()
```

### Go 语言对比

```go
// Go 使用 defer
file, err := os.Open("input.txt")
if err != nil {
    return err
}
defer file.Close()

// 或使用上下文
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

### 创建自定义上下文管理器

```python
from contextlib import contextmanager

@contextmanager
def transaction(db):
    """数据库事务上下文管理器"""
    db.begin()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise

# 使用
with transaction(database) as db:
    db.execute("INSERT INTO ...")
```

---

## 断言

### assert 语句

```python
def calculate_discount(price, discount):
    # 前置条件检查
    assert price >= 0, "Price must be non-negative"
    assert 0 <= discount <= 1, "Discount must be between 0 and 1"
    
    return price * (1 - discount)

# 注意：断言可以在 python -O 模式下被禁用
# 不要使用断言进行数据验证或安全关键检查
```

### Go 语言对比

```go
// Go 没有内置 assert，使用测试包或手动检查
import "testing"

func TestCalculateDiscount(t *testing.T) {
    // 使用测试断言
    if result != expected {
        t.Errorf("Expected %v, got %v", expected, result)
    }
}

// 或使用第三方断言库
import "github.com/stretchr/testify/assert"
assert.Equal(t, expected, result)
```

---

## Python 与 Go 错误处理对比总结

| 特性 | Python | Go |
|------|--------|-----|
| 错误处理机制 | 异常（try-except） | 错误返回值 |
| 异常抛出 | `raise` | `panic`（不推荐） |
| 异常捕获 | `except ExceptionType` | `if err != nil` |
| 资源清理 | `finally`, `with` | `defer` |
| 自定义错误 | 继承 `Exception` | 实现 `error` 接口 |
| 错误包装 | `from e` | `fmt.Errorf("%w")` |
| 断言 | `assert` | 测试包/第三方库 |
| 错误链 | `__cause__` | `Unwrap()` |
| 检查时机 | 运行时 | 编译时 + 运行时 |

---

## 错误处理模式对比

### Python 模式（EAFP）

```python
# Easier to Ask Forgiveness than Permission
try:
    value = data[key]
except KeyError:
    value = default
```

### Go 模式（LBYL）

```go
// Look Before You Leap
if key, ok := data[key]; ok {
    value = key
} else {
    value = default
}
```
