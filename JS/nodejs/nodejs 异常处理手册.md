# Node.js 异常处理手册

> 本手册对比 Python 语言，详细介绍 Node.js 的异常处理机制

## 目录

1. [异常基础](#异常基础)
2. [try-catch 语句](#try-catch-语句)
3. [finally 子句](#finally 子句)
4. [抛出异常](#抛出异常)
5. [自定义异常](#自定义异常)
6. [Error 对象](#error-对象)
7. [常见内置异常](#常见内置异常)
8. [异步异常处理](#异步异常处理)
9. [异常处理最佳实践](#异常处理最佳实践)

---

## 异常基础

### 什么是异常

异常是程序运行时发生的错误，它会中断正常的程序流程。JavaScript 使用异常来处理错误情况。

```javascript
// 触发异常
const result = 10 / 0;  // Infinity (不报错)
const invalid = Number("abc");  // NaN (不报错)

// 真正的异常
null.someMethod();  // TypeError: Cannot read property 'someMethod' of null
undeclaredVar;      // ReferenceError: undeclaredVar is not defined
```

### Python 语言对比

```python
# Python 除零会报错
result = 10 / 0  # ZeroDivisionError

# Go 使用错误返回值
result, err := divide(10, 0)
if err != nil {
    // 处理错误
}
```

---

## try-catch 语句

### 基本语法

```javascript
try {
    // 可能抛出异常的代码
    const result = riskyOperation();
    console.log(result);
} catch (error) {
    // 处理异常
    console.error("Error occurred:", error.message);
}
```

### 捕获特定异常

```javascript
try {
    const data = JSON.parse(jsonString);
    const value = data.property;
} catch (error) {
    if (error instanceof SyntaxError) {
        console.error("Invalid JSON:", error.message);
    } else if (error instanceof TypeError) {
        console.error("Type error:", error.message);
    } else {
        console.error("Unknown error:", error);
    }
}
```

### Python 语言对比

```python
try:
    data = json.loads(json_string)
    value = data["property"]
except json.JSONDecodeError as e:
    print(f"Invalid JSON: {e}")
except TypeError as e:
    print(f"Type error: {e}")
except Exception as e:
    print(f"Unknown error: {e}")
```

### 捕获多个异常

```javascript
try {
    // 可能出错的代码
} catch (error) {
    if (error instanceof SyntaxError || error instanceof TypeError) {
        console.error("Specific error:", error.message);
    } else {
        throw error;  // 重新抛出
    }
}
```

### try-catch-finally

```javascript
try {
    console.log("Acquiring resource...");
    riskyOperation();
} catch (error) {
    console.error("Error:", error.message);
} finally {
    // 无论是否发生异常都会执行
    console.log("Releasing resource...");
    cleanup();
}
```

### Python 语言对比

```python
try:
    print("Acquiring resource...")
    risky_operation()
except Exception as e:
    print(f"Error: {e}")
finally:
    print("Releasing resource...")
    cleanup()
```

---

## finally 子句

### 资源清理

```javascript
let file = null;
try {
    file = fs.readFileSync("data.txt", "utf-8");
    processFile(file);
} catch (error) {
    console.error("File error:", error.message);
} finally {
    if (file) {
        closeFile(file);
    }
}
```

### Python 语言对比

```python
# Python 使用 with 语句
with open("data.txt", "r") as f:
    content = f.read()
    process_file(content)
# 自动关闭文件
```

---

## 抛出异常

### throw 语句

```javascript
// 抛出内置错误类型
throw new Error("Something went wrong");
throw new TypeError("Invalid type");
throw new RangeError("Out of range");

// 抛出字符串（不推荐）
throw "Error message";

// 抛出对象（不推荐）
throw { code: 500, message: "Server error" };

// 重新抛出捕获的异常
try {
    process();
} catch (error) {
    console.error("Logging:", error.message);
    throw error;  // 重新抛出
}
```

### Python 语言对比

```python
# Python 抛出异常
raise ValueError("Invalid value")
raise TypeError("Invalid type")

# 重新抛出
try:
    process()
except Exception as e:
    print(f"Logging: {e}")
    raise  # 重新抛出
```

### 条件抛出

```javascript
function setAge(age) {
    if (age < 0) {
        throw new RangeError("Age cannot be negative");
    }
    if (age > 150) {
        throw new RangeError("Age seems unrealistic");
    }
    return age;
}
```

---

## 自定义异常

### 创建自定义错误类

```javascript
class ValidationError extends Error {
    constructor(message, field) {
        super(message);
        this.name = "ValidationError";
        this.field = field;
        
        // 捕获堆栈跟踪
        if (Error.captureStackTrace) {
            Error.captureStackTrace(this, ValidationError);
        }
    }
}

// 使用
function validateUser(user) {
    if (!user.name) {
        throw new ValidationError("Name is required", "name");
    }
    if (user.age < 0) {
        throw new ValidationError("Age must be positive", "age");
    }
}

try {
    validateUser({ age: -1 });
} catch (error) {
    if (error instanceof ValidationError) {
        console.error(`Field ${error.field}: ${error.message}`);
    }
}
```

### 错误层次结构

```javascript
class AppError extends Error {
    constructor(message, code) {
        super(message);
        this.name = "AppError";
        this.code = code;
    }
}

class AuthenticationError extends AppError {
    constructor(message) {
        super(message, 401);
        this.name = "AuthenticationError";
    }
}

class ValidationError extends AppError {
    constructor(message, field) {
        super(message, 400);
        this.name = "ValidationError";
        this.field = field;
    }
}

class NotFoundError extends AppError {
    constructor(resource) {
        super(`${resource} not found`, 404);
        this.name = "NotFoundError";
    }
}

// 使用
try {
    // 可能抛出各种应用异常
} catch (error) {
    if (error instanceof AppError) {
        console.error(`App error ${error.code}: ${error.message}`);
    } else {
        console.error("Unknown error:", error);
    }
}
```

### Python 语言对比

```python
class AppError(Exception):
    def __init__(self, message, code):
        super().__init__(message)
        self.code = code

class AuthenticationError(AppError):
    def __init__(self, message):
        super().__init__(message, 401)

class ValidationError(AppError):
    def __init__(self, message, field):
        super().__init__(message, 400)
        self.field = field
```

---

## Error 对象

### 内置错误类型

```javascript
// Error - 基础错误
new Error("Something went wrong");

// TypeError - 类型错误
null.someMethod();  // TypeError

// RangeError - 范围错误
new Array(-1);  // RangeError
Number.MAX_VALUE + 1;  // Infinity (不报错)

// SyntaxError - 语法错误
JSON.parse("invalid");  // SyntaxError

// ReferenceError - 引用错误
console.log(undeclaredVar);  // ReferenceError

// URIError - URI 错误
decodeURIComponent("%");  // URIError

// EvalError - eval 错误（很少使用）
```

### Error 属性

```javascript
try {
    throw new Error("Test error");
} catch (error) {
    console.log(error.name);      // "Error"
    console.log(error.message);   // "Test error"
    console.log(error.stack);     // 堆栈跟踪
    console.log(error.fileName);  // 文件名
    console.log(error.lineNumber); // 行号
}
```

### Python 语言对比

```python
try:
    raise ValueError("Test error")
except Exception as e:
    print(e.__class__.__name__)  # 类名
    print(str(e))                # 错误信息
    import traceback
    traceback.print_exc()        # 堆栈跟踪
```

---

## 常见内置异常

### 常见错误场景

```javascript
// TypeError
null.toString();           // Cannot read property 'toString' of null
undefined.length;          // Cannot read property 'length' of undefined
"hello".nonexistent();     // ... is not a function
const arr = []; arr.nonexistent();  // ... is not a function

// ReferenceError
console.log(notDefined);   // notDefined is not defined

// RangeError
new Array(-1);             // Invalid array length
const num = 1e309;         // Infinity

// SyntaxError
JSON.parse("invalid");     // Unexpected token i
eval("if (");              // Unexpected end of input

// URIError
decodeURIComponent("%");   // URI malformed
```

### Python 语言对比

```python
# TypeError
None.some_method()         # 'NoneType' object has no attribute
"hello" + 5                # can't concatenate str and int

# NameError (类似 ReferenceError)
print(not_defined)         # name 'not_defined' is not defined

# ValueError
int("abc")                 # invalid literal for int()
math.sqrt(-1)              # math domain error

# SyntaxError
eval("if")                 # invalid syntax
```

---

## 异步异常处理

### Promise 错误处理

```javascript
// Promise 链
fetchData()
    .then(data => processData(data))
    .then(result => console.log(result))
    .catch(error => console.error("Error:", error));

// 或 async/await
async function fetchDataAsync() {
    try {
        const data = await fetchData();
        const result = await processData(data);
        console.log(result);
    } catch (error) {
        console.error("Error:", error);
    }
}

// Promise.all 错误处理
Promise.all([promise1, promise2, promise3])
    .then(results => console.log(results))
    .catch(error => console.error("One failed:", error));

// Promise.allSettled（等待所有完成）
Promise.allSettled([promise1, promise2])
    .then(results => {
        results.forEach(result => {
            if (result.status === "fulfilled") {
                console.log("Success:", result.value);
            } else {
                console.error("Failed:", result.reason);
            }
        });
    });
```

### Python 语言对比

```python
# Python asyncio
async def fetch_data_async():
    try:
        data = await fetch_data()
        result = await process_data(data)
        print(result)
    except Exception as e:
        print(f"Error: {e}")

# 多个协程
results = await asyncio.gather(
    task1(), task2(), task3(),
    return_exceptions=True
)
```

### Node.js 错误事件

```javascript
// EventEmitter 错误
const emitter = require('events');
const myEmitter = new emitter();

myEmitter.on('error', (err) => {
    console.error("Emitter error:", err);
});

myEmitter.emit('error', new Error("Something failed"));

// Stream 错误处理
const stream = fs.createReadStream("file.txt");
stream.on('error', (err) => {
    console.error("Stream error:", err);
});
stream.on('data', (chunk) => {
    console.log("Chunk:", chunk);
});
```

---

## 异常处理最佳实践

### 1. 捕获具体的异常

```javascript
// ❌ 不推荐
try {
    process();
} catch (error) {
    // 吞掉所有异常
}

// ✅ 推荐
try {
    process();
} catch (error) {
    if (error instanceof ValidationError) {
        handleValidationError(error);
    } else {
        throw error;
    }
}
```

### 2. 不要吞掉异常

```javascript
// ❌ 不推荐
try {
    riskyOperation();
} catch (error) {
    // 静默失败
}

// ✅ 推荐
try {
    riskyOperation();
} catch (error) {
    logger.error("Operation failed:", error);
    throw error;  // 重新抛出或处理
}
```

### 3. 使用 finally 或 with 清理资源

```javascript
// ✅ 使用 try-finally
let resource = null;
try {
    resource = acquireResource();
    useResource(resource);
} finally {
    if (resource) {
        releaseResource(resource);
    }
}
```

### 4. 提供有意义的错误信息

```javascript
// ❌ 不推荐
throw new Error("Error occurred");

// ✅ 推荐
throw new Error(
    `Invalid user ID: expected positive integer, got ${userId}`
);
```

### 5. 使用错误包装

```javascript
class DatabaseError extends Error {
    constructor(message, cause) {
        super(message);
        this.name = "DatabaseError";
        this.cause = cause;
    }
}

try {
    await database.connect();
} catch (error) {
    throw new DatabaseError("Failed to connect to database", error);
}
```

### 6. 创建自定义错误层次结构

```javascript
class APIError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.name = "APIError";
        this.statusCode = statusCode;
    }
}

class AuthenticationError extends APIError {
    constructor(message) {
        super(message, 401);
        this.name = "AuthenticationError";
    }
}

class ValidationError extends APIError {
    constructor(message, field) {
        super(message, 400);
        this.name = "ValidationError";
        this.field = field;
    }
}

class NotFoundError extends APIError {
    constructor(resource) {
        super(`${resource} not found`, 404);
        this.name = "NotFoundError";
    }
}
```

---

## Node.js 与 Python 错误处理对比总结

| 特性 | JavaScript (Node.js) | Python |
|------|---------------------|--------|
| 异常抛出 | `throw` | `raise` |
| 异常捕获 | `try-catch` | `try-except` |
| 资源清理 | `finally` | `finally`, `with` |
| 自定义错误 | `extends Error` | `extends Exception` |
| 错误包装 | 手动实现 | `from e` |
| 异步错误 | `.catch()`, `try-catch` | `try-except` |
| 错误事件 | `EventEmitter.on('error')` | logging |
| 检查时机 | 运行时 | 运行时 |
