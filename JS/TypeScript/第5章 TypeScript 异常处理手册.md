# 第5章 TypeScript 异常处理手册

> 本手册详细介绍 TypeScript 的异常处理机制

## 目录

1. [try-catch 语句](#try-catch-语句)
2. [finally 子句](#finally-子句)
3. [抛出异常](#抛出异常)
4. [Error 类层级](#error-类层级)
5. [自定义异常类](#自定义异常类)
6. [类型化错误处理](#类型化错误处理)
7. [异步错误处理](#异步错误处理)
8. [错误处理模式](#错误处理模式)
9. [最佳实践](#最佳实践)

---

## try-catch 语句

### 基本语法

```typescript
try {
  // 可能抛出异常的代码
  const data = JSON.parse(userInput);
  console.log(data.name);
} catch (error) {
  // 异常处理
  console.error("An error occurred:", error);
} finally {
  // 始终执行的代码
  cleanup();
}
```

### catch 子句的细节

```typescript
// TypeScript 4.0+ catch 变量默认为 unknown（安全）
try {
  riskyOperation();
} catch (error) {
  // error: unknown（不能直接访问属性）
  // console.log(error.message);  // Error: Object is of type 'unknown'
  
  // 需要类型收窄
  if (error instanceof Error) {
    console.log(error.message);  // OK
  }
}

// 旧版：catch 变量为 any（不安全，需要配置）
// "useUnknownInCatchVariables": false 在 tsconfig 中
try {
  riskyOperation();
} catch (error: any) {  // 不推荐
  console.log(error.message);  // 无类型安全检查
}
```

### Python 对比

```python
try:
    data = json.loads(user_input)
    print(data["name"])
except json.JSONDecodeError as e:
    print(f"JSON parse error: {e}")
except KeyError as e:
    print(f"Missing key: {e}")
except Exception as e:
    print(f"Unexpected error: {e}")
finally:
    cleanup()

# Python 的 except 类似 TypeScript 的 catch
# 但 Python 可以指定多个异常类型
```

---

## finally 子句

### finally 执行顺序

```typescript
function example(): string {
  try {
    console.log("1. try");
    return "from try";
  } finally {
    console.log("2. finally");  // 在 return 之前执行
  }
}

console.log(example());
// 输出:
// 1. try
// 2. finally
// from try

// finally 中的 return 会覆盖 try/catch 的 return
function finallyOverride(): string {
  try {
    return "from try";
  } finally {
    return "from finally";  // 覆盖了 try 的 return
  }
}

console.log(finallyOverride());  // "from finally"
```

### 资源清理模式

```typescript
// finally 确保资源释放
function readFile(path: string): string {
  const file = openFile(path);
  try {
    const content = file.read();
    if (content.length === 0) {
      return "empty";
    }
    return processContent(content);
  } finally {
    file.close();  // 无论是否异常，都关闭文件
  }
}

// TypeScript 没有 Python 的 with 语句
// 但可以使用 try-finally 模式
function withResource<T>(resource: { close(): void }, fn: () => T): T {
  try {
    return fn();
  } finally {
    resource.close();
  }
}
```

### Python 对比

```python
# Python 的 with 语句（上下文管理器）
def read_file(path: str) -> str:
    with open(path, 'r') as file:
        content = file.read()
        if len(content) == 0:
            return "empty"
        return process_content(content)
    # 文件自动关闭

# 对比 TypeScript 的 try-finally
# Python with 语句更简洁，自动清理
```

---

## 抛出异常

### throw 语句

```typescript
// 抛出 Error 实例（推荐）
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error("Division by zero");
  }
  if (b < 0) {
    throw new RangeError("Negative divisor not allowed");
  }
  return a / b;
}

// 抛出任意值（不推荐）
function riskyFunction(value: unknown): void {
  if (typeof value !== "string") {
    throw "Value must be a string";  // 不推荐
  }
}

// 推荐：始终抛出 Error 或其子类的实例
function validateUser(user: unknown): asserts user is User {
  if (typeof user !== "object" || user === null) {
    throw new TypeError("User must be an object");
  }
  if (!("id" in user)) {
    throw new ValidationError("User must have an id", user);
  }
}
```

### asserts 关键字

```typescript
// TypeScript 3.7+ 断言函数
function assert(condition: any, message: string): asserts condition {
  if (!condition) {
    throw new AssertionError(message);
  }
}

// 自定义类型断言
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") {
    throw new TypeError("Value must be a string");
  }
}

function processValue(value: unknown): void {
  assertIsString(value);
  // 此处 value 收窄为 string
  console.log(value.toUpperCase());
}
```

### Python 对比

```python
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("Division by zero")
    return a / b

# Python 的 raise 语句
# Python 通常抛出内置异常（ValueError, TypeError 等）
# Python 使用 assert 关键字
def process_value(value):
    assert isinstance(value, str), "Value must be a string"
    print(value.upper())
```

---

## Error 类层级

### 内置 Error 类型

```typescript
// Error 层级（从最高到最低）
class Error
  ├── AggregateError    // 多个错误集合（Promise.any 等）
  ├── EvalError         // eval() 相关错误
  ├── RangeError        // 数值越界
  ├── ReferenceError    // 引用未定义变量
  ├── SyntaxError       // 语法错误
  ├── TypeError         // 类型错误
  └── URIError          // URI 处理错误

// TypeError
try {
  null.toUpperCase();
} catch (error) {
  if (error instanceof TypeError) {
    console.log("Type error:", error.message);
  }
}

// RangeError
function factorial(n: number): number {
  if (n < 0) throw new RangeError("Negative numbers not allowed");
  if (n > 170) throw new RangeError("Number too large");
  return n <= 1 ? 1 : n * factorial(n - 1);
}

// SyntaxError
try {
  JSON.parse("invalid json");
} catch (error) {
  if (error instanceof SyntaxError) {
    console.log("JSON syntax error:", error.message);
  }
}
```

### AggregateError

```typescript
// ES2021+ / TypeScript 5.0+
// 表示多个错误需要同时报告

try {
  const results = await Promise.allSettled([
    fetch("/api/1"),
    fetch("/api/2"),
    fetch("/api/3"),
  ]);
  
  const errors = results
    .filter((r): r is PromiseRejectedResult => r.status === "rejected")
    .map(r => r.reason);
  
  if (errors.length > 0) {
    throw new AggregateError(errors, "Multiple API calls failed");
  }
} catch (error) {
  if (error instanceof AggregateError) {
    for (const e of error.errors) {
      console.error("Sub-error:", e);
    }
  }
}
```

### Python 对比

```python
# Python 内置异常层级
# BaseException
#   ├── SystemExit
#   ├── KeyboardInterrupt
#   ├── GeneratorExit
#   └── Exception
#       ├── StopIteration
#       ├── ValueError
#       ├── TypeError
#       ├── RuntimeError
#       └── ...

# Python 没有 AggregateError
# 但可以通过 ExceptionGroup 实现（Python 3.11+）
try:
    raise ExceptionGroup("group", [
        ValueError("first"),
        TypeError("second"),
    ])
except* ValueError as eg:
    print(f"Caught ValueError: {eg.exceptions}")
except* TypeError as eg:
    print(f"Caught TypeError: {eg.exceptions}")
```

---

## 自定义异常类

### 扩展 Error 类

```typescript
class ValidationError extends Error {
  constructor(
    message: string,
    public field?: string,
    public value?: unknown
  ) {
    super(message);
    this.name = "ValidationError";  // 设置错误名称
    
    // 修复原型链（TypeScript 继承 Error 的问题）
    Object.setPrototypeOf(this, ValidationError.prototype);
  }
}

class NetworkError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public url?: string
  ) {
    super(message);
    this.name = "NetworkError";
    Object.setPrototypeOf(this, NetworkError.prototype);
  }

  get isServerError(): boolean {
    return this.statusCode >= 500;
  }

  get isClientError(): boolean {
    return this.statusCode >= 400 && this.statusCode < 500;
  }
}
```

### 更优雅的自定义错误方式

```typescript
// 使用函数创建错误类（避免原型链问题）
function createErrorClass<T extends new (...args: any[]) => Error>(
  name: string,
  Base: T
) {
  return class extends Base {
    constructor(...args: any[]) {
      super(...args);
      this.name = name;
    }
  } as unknown as T;
}

// 或者使用明确的类定义（TypeScript 5.0+ 改进）
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = "AppError";
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string | number) {
    super(
      `${resource} with id ${id} not found`,
      "NOT_FOUND",
      { resource, id }
    );
    this.name = "NotFoundError";
  }
}

class UnauthorizedError extends AppError {
  constructor(message = "Authentication required") {
    super(message, "UNAUTHORIZED");
    this.name = "UnauthorizedError";
  }
}
```

### 错误工厂

```typescript
// 错误创建工厂
const Errors = {
  validation: (field: string, message: string) =>
    new ValidationError(message, field),
  
  network: (url: string, status: number) =>
    new NetworkError(`HTTP ${status} for ${url}`, status, url),
  
  notFound: (resource: string, id: string) =>
    new NotFoundError(resource, id),
  
  unauthorized: (message?: string) =>
    new UnauthorizedError(message),
} as const;

// 使用
throw Errors.notFound("User", "123");
```

### Python 对比

```python
# Python 自定义异常
class ValidationError(ValueError):
    def __init__(self, message: str, field: str | None = None, value=None):
        super().__init__(message)
        self.field = field
        self.value = value

class NetworkError(Exception):
    def __init__(self, message: str, status_code: int, url: str | None = None):
        super().__init__(message)
        self.status_code = status_code
        self.url = url
    
    @property
    def is_server_error(self) -> bool:
        return self.status_code >= 500

# Python 继承异常没有原型链问题
# Python 可以多重继承异常
```

---

## 类型化错误处理

### 结果类型模式（Result Type）

```typescript
// Rust/Zig 风格的 Result 类型
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

// 辅助函数
function success<T>(value: T): Result<T> {
  return { ok: true, value };
}

function failure<E = Error>(error: E): Result<never, E> {
  return { ok: false, error };
}

// 使用
function divide2(a: number, b: number): Result<number, string> {
  if (b === 0) {
    return failure("Division by zero");
  }
  return success(a / b);
}

const result = divide2(10, 2);
if (result.ok) {
  console.log(result.value);  // 类型安全
} else {
  console.error(result.error);  // "Division by zero"
}
```

### 函数重载错误处理

```typescript
// 联合返回类型
function parseJSON(text: string): { data: unknown } | { error: string } {
  try {
    return { data: JSON.parse(text) };
  } catch (e) {
    return { error: `Invalid JSON: ${(e as Error).message}` };
  }
}

const parsed = parseJSON('{"name":"Alice"}');
if ("data" in parsed) {
  console.log(parsed.data);
} else {
  console.error(parsed.error);
}
```

### 错误类型守卫

```typescript
// 类型守卫函数
function isAppError(error: unknown): error is AppError {
  return error instanceof AppError;
}

function isNetworkError(error: unknown): error is NetworkError {
  return error instanceof NetworkError;
}

// 使用
try {
  riskyOperation();
} catch (error) {
  if (error instanceof ValidationError) {
    // 处理验证错误
    console.error(`Field ${error.field}: ${error.message}`);
  } else if (error instanceof NetworkError) {
    // 处理网络错误
    if (error.isServerError) {
      retryLater();
    }
  } else if (error instanceof Error) {
    // 处理一般错误
    console.error(error.message);
  } else {
    // 处理未知错误
    console.error("Unknown error", error);
  }
}
```

### Python 对比

```python
from typing import Union, TypeVar, Generic

# Python 的 Union 类型类似 Result 模式
T = TypeVar("T")
E = TypeVar("E")

# Python 3.10+ 使用 | 语法
def divide(a: float, b: float) -> float | str:
    if b == 0:
        return "Division by zero"
    return a / b

# 使用
result = divide(10, 2)
if isinstance(result, str):
    print(f"Error: {result}")
else:
    print(f"Result: {result}")
```

---

## 异步错误处理

### try-catch 与 async/await

```typescript
async function fetchUserData(id: number): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new NetworkError(
        `HTTP error ${response.status}`,
        response.status,
        response.url
      );
    }
    return await response.json() as User;
  } catch (error) {
    if (error instanceof NetworkError) {
      // 重新抛出或处理网络错误
      throw new AppError("Failed to fetch user", "NETWORK_ERROR", { id });
    }
    // 重新抛出其他错误
    throw error;
  }
}

// 使用
async function displayUser(id: number): Promise<void> {
  try {
    const user = await fetchUserData(id);
    console.log(user.name);
  } catch (error) {
    if (error instanceof AppError) {
      showErrorNotification(error.message);
    }
  }
}
```

### Promise 错误链

```typescript
// Promise 链的错误处理
fetch("/api/data")
  .then(response => {
    if (!response.ok) throw new NetworkError("Bad response", response.status);
    return response.json();
  })
  .then(data => processData(data))
  .catch(error => {
    if (error instanceof NetworkError) {
      return handleNetworkError(error);
    }
    throw error;  // 继续传播
  })
  .then(result => {
    if (result) console.log("Processed:", result);
  })
  .catch(error => {
    console.error("Unhandled:", error);
  });
```

### 全局未处理错误

```typescript
// Node.js 全局错误处理
process.on("uncaughtException", (error: Error) => {
  console.error("Uncaught Exception:", error);
  // 清理并优雅退出
  process.exit(1);
});

process.on("unhandledRejection", (reason: unknown) => {
  console.error("Unhandled Rejection:", reason);
});

// 浏览器全局错误处理
window.onerror = (message, source, line, column, error) => {
  console.error("Global error:", message);
  return true;  // 阻止默认处理
};

window.addEventListener("unhandledrejection", (event) => {
  console.error("Unhandled promise rejection:", event.reason);
  event.preventDefault();
});
```

### Python 对比

```python
import asyncio

async def fetch_user_data(id: int) -> dict:
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"/api/users/{id}") as response:
                response.raise_for_status()
                return await response.json()
    except aiohttp.ClientError as e:
        raise RuntimeError(f"Failed to fetch user: {e}")

# 全局异常处理
import sys
def global_exception_handler(exc_type, exc_value, exc_traceback):
    print(f"Unhandled: {exc_type.__name__}: {exc_value}")

sys.excepthook = global_exception_handler
```

---

## 错误处理模式

### 防弹模式（Fail-safe）

```typescript
function safeExecute<T>(fn: () => T): { result: T } | { error: Error } {
  try {
    return { result: fn() };
  } catch (error) {
    return { error: error instanceof Error ? error : new Error(String(error)) };
  }
}

// 使用
const outcome = safeExecute(() => riskyOperation());
if ("error" in outcome) {
  console.error("Failed:", outcome.error.message);
} else {
  console.log("Succeeded:", outcome.result);
}
```

### 重试模式

```typescript
async function retry<T>(
  fn: () => Promise<T>,
  options: {
    maxRetries?: number;
    delay?: number;
    backoff?: "fixed" | "exponential";
  } = {}
): Promise<T> {
  const { maxRetries = 3, delay = 1000, backoff = "exponential" } = options;
  
  let lastError: Error;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      
      if (attempt === maxRetries) break;
      
      const waitTime = backoff === "exponential"
        ? delay * Math.pow(2, attempt)
        : delay;
      
      console.warn(`Attempt ${attempt + 1} failed, retrying in ${waitTime}ms`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
  
  throw lastError!;
}

// 使用
const data = await retry(() => fetch("/api/data"));
```

### 超时模式

```typescript
function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  errorMessage?: string
): Promise<T> {
  const timeout = new Promise<never>((_, reject) => {
    setTimeout(() => {
      reject(new Error(errorMessage ?? `Operation timed out after ${timeoutMs}ms`));
    }, timeoutMs);
  });
  
  return Promise.race([promise, timeout]);
}

// 使用
try {
  const result = await withTimeout(
    fetch("/api/slow"),
    5000,
    "API request timed out"
  );
} catch (error) {
  if (error instanceof Error && error.message.includes("timed out")) {
    console.log("Request was too slow, using cached data");
  }
}
```

### Python 对比

```python
import asyncio
import time
from functools import wraps

# Python 重试模式
async def retry(fn, max_retries=3, delay=1.0, backoff="exponential"):
    last_error = None
    for attempt in range(max_retries + 1):
        try:
            return await fn()
        except Exception as e:
            last_error = e
            if attempt == max_retries:
                raise
            wait = delay * (2 ** attempt) if backoff == "exponential" else delay
            print(f"Attempt {attempt + 1} failed, retrying in {wait}s")
            await asyncio.sleep(wait)

# Python 超时模式
async def with_timeout(coro, timeout_sec):
    try:
        return await asyncio.wait_for(coro, timeout=timeout_sec)
    except asyncio.TimeoutError:
        raise TimeoutError(f"Operation timed out after {timeout_sec}s")
```

---

## 最佳实践

### 原则

```typescript
// 1. 始终抛出 Error 实例，不要抛出原始值
// 不推荐
throw "error";
throw 404;

// 推荐
throw new Error("Something went wrong");
throw new ValidationError("Invalid email", "email");

// 2. 使用 instanceof 检查错误类型
// 3. 在 catch 中收窄 unknown 类型
// 4. 使用自定义错误类携带额外信息
// 5. 不要吞掉异常（空的 catch 块）

// 6. 异步错误始终 catch
// 不推荐
async function bad() {
  throw new Error("fail");
}
bad();  // 未处理的 Promise 拒绝

// 推荐
async function good() {
  throw new Error("fail");
}
good().catch(err => console.error(err));

// 7. 使用 finally 进行清理
// 8. 错误边界在 UI 框架中使用
```

### 错误处理清单

| 场景 | 推荐方式 | 不推荐 |
|------|----------|--------|
| 验证用户输入 | `ValidationError` | 抛出字符串 |
| API 调用失败 | `NetworkError` + 重试 | 静默失败 |
| 解析 JSON | try-catch + 类型守卫 | 假设成功 |
| 异步操作 | try-catch + async/await | 忽略 catch |
| 第三方错误 | 包装为自定义错误 | 传播原始错误 |
| 资源清理 | try-finally | 忘记释放 |
| 超时控制 | `Promise.race` + 超时 Promise | 无限等待 |

### Python 对比

```python
# Python 最佳实践
# 1. 始终抛出 Exception 子类（不是 BaseException）
# 2. 使用具体的异常类型
# 3. 使用 finally 或 with 清理资源
# 4. 不要 except: pass 静默吞掉异常
# 5. 使用日志记录异常信息

import logging

logger = logging.getLogger(__name__)

def process_order(data: dict) -> None:
    try:
        validate(data)
        save_to_db(data)
        send_notification(data)
    except ValidationError as e:
        logger.warning(f"Validation failed: {e}")
        raise  # 重新抛出给调用者
    except DatabaseError as e:
        logger.error(f"DB error: {e}")
        raise RuntimeError("Failed to save order") from e  # 异常链
    except Exception:
        logger.exception("Unexpected error")  # 自动记录 traceback
        raise
```
