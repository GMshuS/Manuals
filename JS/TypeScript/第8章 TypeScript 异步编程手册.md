# 第8章 TypeScript 异步编程手册

> 本手册详细介绍 TypeScript 的异步编程模型

## 目录

1. [异步编程基础](#异步编程基础)
2. [Promise](#promise)
3. [async/await](#asyncawait)
4. [Promise 并发控制](#promise-并发控制)
5. [事件循环 (Event Loop)](#事件循环-event-loop)
6. [类型安全异步](#类型安全异步)
7. [定时器与延迟](#定时器与延迟)
8. [流的异步处理](#流的异步处理)
9. [高级异步模式](#高级异步模式)

---

## 异步编程基础

### 同步 vs 异步

```typescript
// 同步代码：阻塞执行
console.log("Start");
const result = heavyComputation();  // 阻塞直到完成
console.log("End");

// 异步代码：非阻塞
console.log("Start");
setTimeout(() => {
  console.log("Async callback");
}, 1000);
console.log("End");  // 立即执行

// 输出: Start → End → Async callback
```

### 回调函数（旧式）

```typescript
// Node.js 回调风格
function readFileCallback(
  path: string,
  callback: (error: Error | null, data?: Buffer) => void
): void {
  fs.readFile(path, (err, data) => {
    if (err) {
      callback(err);
    } else {
      callback(null, data);
    }
  });
}

// 回调地狱
getUser(id, (err, user) => {
  if (err) return handleError(err);
  getPosts(user.id, (err, posts) => {
    if (err) return handleError(err);
    getComments(posts[0].id, (err, comments) => {
      if (err) return handleError(err);
      console.log(comments);
    });
  });
});
```

---

## Promise

### Promise 基础

```typescript
// 创建 Promise
const promise = new Promise<string>((resolve, reject) => {
  // 异步操作
  setTimeout(() => {
    const success = Math.random() > 0.5;
    if (success) {
      resolve("Operation succeeded");
    } else {
      reject(new Error("Operation failed"));
    }
  }, 1000);
});

// 使用 Promise
promise
  .then(result => console.log(result))
  .catch(error => console.error(error))
  .finally(() => console.log("Done"));

// Promise 状态
// - pending: 初始状态
// - fulfilled: 操作成功完成
// - rejected: 操作失败
```

### Promise 链式调用

```typescript
// 链式 .then()
fetchUser(1)
  .then(user => {
    console.log("User:", user);
    return fetchPosts(user.id);  // 返回新 Promise
  })
  .then(posts => {
    console.log("Posts:", posts);
    return fetchComments(posts[0].id);
  })
  .then(comments => {
    console.log("Comments:", comments);
  })
  .catch(error => {
    console.error("Any error in the chain:", error);
  });

// 值穿透
Promise.resolve(42)
  .then(x => x * 2)      // 84
  .then(x => x.toString())  // "84"
  .then(x => x.length)     // 2
  .then(console.log);      // 2
```

### Promise 静态方法

```typescript
// Promise.resolve - 创建立即完成的 Promise
const resolved = Promise.resolve(42);

// Promise.reject - 创建立即拒绝的 Promise
const rejected = Promise.reject(new Error("fail"));

// Promise.all - 全部成功才成功
const allPromises = Promise.all([
  fetch("/api/users"),
  fetch("/api/posts"),
  fetch("/api/comments"),
]);

allPromises
  .then(([users, posts, comments]) => {
    console.log("All data loaded");
  })
  .catch(error => {
    console.log("At least one failed:", error);
  });

// Promise.allSettled - 等待全部完成（无论成功失败）
const settledPromises = Promise.allSettled([
  fetch("/api/users"),
  fetch("/api/failing"),
]);

settledPromises.then(results => {
  results.forEach(result => {
    if (result.status === "fulfilled") {
      console.log("Success:", result.value);
    } else {
      console.log("Failed:", result.reason);
    }
  });
});

// Promise.race - 最快的决定最终结果
const raceWithTimeout = Promise.race([
  fetch("/api/data"),
  new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error("Timeout")), 5000)
  ),
]);

// Promise.any - 任意一个成功即成功（全失败才失败）
const anyPromise = Promise.any([
  fetch("/api/server1"),
  fetch("/api/server2"),
  fetch("/api/server3"),
]).then(response => {
  console.log("Fastest server responded");
});
```

---

## async/await

### 基本语法

```typescript
// async 函数声明
async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  return response.json() as Promise<User>;
}

// async 箭头函数
const fetchData = async (url: string): Promise<unknown> => {
  const response = await fetch(url);
  return response.json();
};

// async 方法
class UserService {
  async getUser(id: number): Promise<User> {
    return await this.http.get(`/users/${id}`);
  }
}

// 顶层 await（ES2022+ / TypeScript 模块）
// 仅在 ESM 模块中可用
const config = await fetch("/config.json");
```

### await 关键点

```typescript
// await 只能在 async 函数中使用
// 错误：
// function bad() {
//   await promise;  // Error
// }

// 正确的错误处理
async function safeFetch(url: string): Promise<unknown> {
  try {
    const response = await fetch(url);
    return await response.json();
  } catch (error) {
    console.error("Fetch failed:", error);
    throw error;  // 重新抛出
  }
}

// 串行 await（按顺序执行）
async function serial() {
  const user = await fetchUser(1);     // 等待完成
  const posts = await fetchPosts(user.id);  // 然后执行
  return posts;
}

// 并行 await（同时执行）
async function parallel() {
  const [user, posts] = await Promise.all([
    fetchUser(1),
    fetchPosts(1),
  ]);
  return { user, posts };
}

// await 表达式（await 任何值）
const value = await 42;  // 非 Promise 值直接返回
```

### 异步迭代

```typescript
// 异步迭代器（可迭代的异步数据流）
async function* generateNumbers(): AsyncGenerator<number> {
  for (let i = 0; i < 5; i++) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    yield i;
  }
}

// for-await-of 循环
async function consumeGenerator() {
  for await (const num of generateNumbers()) {
    console.log(num);  // 每隔 1 秒输出一个数字
  }
}

// 异步可迭代对象
const asyncIterable: AsyncIterable<string> = {
  [Symbol.asyncIterator]() {
    let i = 0;
    const data = ["a", "b", "c"];
    return {
      next(): Promise<IteratorResult<string>> {
        if (i < data.length) {
          return Promise.resolve({ value: data[i++], done: false });
        }
        return Promise.resolve({ value: undefined as any, done: true });
      },
    };
  },
};

// 使用
for await (const item of asyncIterable) {
  console.log(item);  // "a", "b", "c"
}
```

---

## Promise 并发控制

### 批量并发限制

```typescript
// 限制并发数
async function asyncPool<T>(
  items: T[],
  concurrency: number,
  fn: (item: T) => Promise<unknown>
): Promise<void> {
  const results: Promise<unknown>[] = [];
  const executing = new Set<Promise<unknown>>();

  for (const item of items) {
    const p = fn(item);
    results.push(p);
    executing.add(p);

    const clean = () => executing.delete(p);
    p.then(clean, clean);

    if (executing.size >= concurrency) {
      await Promise.race(executing);
    }
  }

  await Promise.all(results);
}

// 使用
const urls = Array.from({ length: 100 }, (_, i) => `/api/item/${i}`);

await asyncPool(urls, 5, async (url) => {
  const response = await fetch(url);
  return response.json();
});
```

### 带重试的并发

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  retries = 3
): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(r => setTimeout(r, 1000 * (i + 1)));
    }
  }
  throw new Error("Unreachable");
}

// 批量重试
async function batchFetch<T>(
  items: T[],
  fn: (item: T) => Promise<unknown>,
  concurrency = 3
): Promise<void> {
  const queue = [...items];
  const workers = Array.from({ length: concurrency }, async () => {
    while (queue.length > 0) {
      const item = queue.shift()!;
      await fetchWithRetry(() => fn(item));
    }
  });
  await Promise.all(workers);
}
```

---

## 事件循环 (Event Loop)

### 事件循环阶段

```typescript
// Node.js 事件循环阶段
// 1. timers: setTimeout, setInterval 回调
// 2. I/O callbacks: 已完成 I/O 的回调
// 3. idle, prepare: 内部使用
// 4. poll: 获取新 I/O 事件
// 5. check: setImmediate 回调
// 6. close callbacks: 关闭事件回调

// 微任务 vs 宏任务
console.log("1: sync");

setTimeout(() => {
  console.log("2: macro task (setTimeout)");
}, 0);

Promise.resolve().then(() => {
  console.log("3: micro task (Promise)");
});

queueMicrotask(() => {
  console.log("4: micro task (queueMicrotask)");
});

console.log("5: sync");

// 输出: 1 → 5 → 3 → 4 → 2
```

### 微任务执行顺序

```typescript
// 微任务队列高于宏任务队列
// 微任务: Promise.then/catch/finally, queueMicrotask, MutationObserver
// 宏任务: setTimeout, setInterval, setImmediate, I/O, UI rendering

async function microtaskOrder(): Promise<void> {
  console.log("A");
  
  setTimeout(() => console.log("B (macro)"), 0);
  
  await Promise.resolve();
  console.log("C (micro after await)");
  
  Promise.resolve().then(() => console.log("D (micro then)"));
  
  console.log("E (sync after await)");
}

microtaskOrder();
// A, C, E, D, B

// process.nextTick (Node.js 特有)
// 优先级高于 Promise 微任务
process.nextTick(() => {
  console.log("nextTick");
});
```

---

## 类型安全异步

### Promise 类型参数

```typescript
// 泛型 Promise 类型
type AsyncResult<T> = Promise<T>;

// async 函数返回类型
async function getString(): Promise<string> {
  return "hello";
}

async function getNumber(): Promise<number> {
  return 42;
}

// Awaited<T> - 解包 Promise 类型
type Promised = Promise<Promise<string>>;
type Unwrapped = Awaited<Promised>;  // string

async function nestedPromise(): Promise<Promise<string>> {
  return Promise.resolve("nested");
}

type ResultType = Awaited<ReturnType<typeof nestedPromise>>;
// string
```

### 类型安全的异步函数

```typescript
// 泛型异步函数
async function fetchJSON<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  return response.json() as Promise<T>;
}

// 类型安全的使用
interface User9 {
  id: number;
  name: string;
  email: string;
}

const user9 = await fetchJSON<User9>("/api/user/1");
console.log(user9.name);  // 类型安全

// 可选异步函数
type MaybeAsync<T> = T | Promise<T>;

function processValue<T>(value: MaybeAsync<T>): Promise<T> {
  return Promise.resolve(value);
}

// 异步回调类型
type AsyncCallback<T, R> = (item: T) => Promise<R>;

async function mapAsync<T, R>(
  items: T[],
  fn: AsyncCallback<T, R>
): Promise<R[]> {
  return Promise.all(items.map(fn));
}
```

---

## 定时器与延迟

### setTimeout / setInterval

```typescript
// setTimeout - 延迟执行
const timeoutId = setTimeout(() => {
  console.log("Delayed execution");
}, 1000);

// 取消定时器
clearTimeout(timeoutId);

// setInterval - 周期性执行
const intervalId = setInterval(() => {
  console.log("Repeated execution");
}, 2000);

// 取消间隔
clearInterval(intervalId);

// 封装为 Promise
function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// 使用
async function exampleDelay() {
  console.log("Start");
  await delay(1000);
  console.log("After 1 second");
}

// 带超时的 Promise
function withTimeout2<T>(
  promise: Promise<T>,
  ms: number,
  message = "Operation timed out"
): Promise<T> {
  const timeout = new Promise<never>((_, reject) => {
    const id = setTimeout(() => {
      clearTimeout(id);
      reject(new Error(message));
    }, ms);
  });
  return Promise.race([promise, timeout]);
}
```

### setImmediate / process.nextTick

```typescript
// Node.js 特有
// setImmediate - 在当前事件循环的 check 阶段执行
setImmediate(() => {
  console.log("setImmediate callback");
});

// process.nextTick - 在当前操作完成后立即执行
process.nextTick(() => {
  console.log("nextTick callback");
});

// 浏览器环境
// requestAnimationFrame - 在下一帧渲染前执行
requestAnimationFrame((timestamp) => {
  console.log("Animation frame:", timestamp);
});

// queueMicrotask - 添加到微任务队列
queueMicrotask(() => {
  console.log("Microtask");
});
```

---

## 流的异步处理

### Node.js 流 (Stream)

```typescript
// Readable Stream
import { createReadStream } from "fs";
import { createInterface } from "readline";

async function readFileLines(path: string): Promise<string[]> {
  const lines: string[] = [];
  
  const readStream = createReadStream(path, { encoding: "utf-8" });
  const rl = createInterface({ input: readStream });
  
  for await (const line of rl) {
    lines.push(line);
  }
  
  return lines;
}

// Writable Stream
import { createWriteStream } from "fs";

async function writeLines(path: string, lines: string[]): Promise<void> {
  const writeStream = createWriteStream(path);
  
  for (const line of lines) {
    const canContinue = writeStream.write(line + "\n");
    if (!canContinue) {
      // 背压处理：等待 drain 事件
      await new Promise<void>(resolve => writeStream.once("drain", resolve));
    }
  }
  
  writeStream.end();
  await new Promise<void>(resolve => writeStream.on("finish", resolve));
}
```

### Web Stream API

```typescript
// 浏览器 Web Streams API
async function processStream(url: string): Promise<void> {
  const response = await fetch(url);
  const reader = response.body!.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const text = decoder.decode(value, { stream: true });
    console.log("Chunk:", text);
  }
}

// 创建可读流
const stream = new ReadableStream({
  async start(controller) {
    for (let i = 0; i < 10; i++) {
      controller.enqueue(`Chunk ${i}\n`);
      await new Promise(r => setTimeout(r, 100));
    }
    controller.close();
  },
});

// 管道操作
stream
  .pipeThrough(new TextEncoderStream())
  .pipeTo(new WritableStream({
    write(chunk) {
      console.log("Received:", chunk);
    },
  }));
```

---

## 高级异步模式

### 可取消的 Promise

```typescript
// 使用 AbortController 取消
function cancellableFetch(url: string, signal?: AbortSignal): Promise<Response> {
  return fetch(url, { signal });
}

// 使用
const controller = new AbortController();
const { signal } = controller;

const fetchPromise = cancellableFetch("/api/data", signal);

// 超时取消
setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetchPromise;
  console.log("Data:", await response.json());
} catch (error) {
  if ((error as Error).name === "AbortError") {
    console.log("Request was cancelled");
  }
}

// 自定义可取消 Promise
function makeCancellable<T>(
  promise: Promise<T>
): { promise: Promise<T>; cancel: () => void } {
  let rejectFn: (reason?: unknown) => void;
  
  const wrappedPromise = new Promise<T>((resolve, reject) => {
    rejectFn = reject;
    promise.then(resolve, reject);
  });
  
  return {
    promise: wrappedPromise,
    cancel: () => rejectFn?.(new Error("Cancelled")),
  };
}
```

### 异步队列

```typescript
// 异步任务队列
class AsyncQueue {
  private queue: (() => Promise<void>)[] = [];
  private running = false;
  
  add<T>(task: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await task();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
      if (!this.running) {
        this.processQueue();
      }
    });
  }
  
  private async processQueue(): Promise<void> {
    this.running = true;
    while (this.queue.length > 0) {
      const task = this.queue.shift()!;
      await task();
    }
    this.running = false;
  }
}

// 使用
const queue = new AsyncQueue();
queue.add(() => fetch("/api/task1"));  // 按序执行
queue.add(() => fetch("/api/task2"));
queue.add(() => fetch("/api/task3"));
```

### 异步缓存

```typescript
// 异步缓存装饰器
function asyncCache<T>(
  fn: (...args: any[]) => Promise<T>,
  ttlMs = 60000
): (...args: any[]) => Promise<T> {
  const cache = new Map<string, { value: T; timestamp: number }>();
  
  return async (...args: any[]) => {
    const key = JSON.stringify(args);
    const cached = cache.get(key);
    
    if (cached && Date.now() - cached.timestamp < ttlMs) {
      return cached.value;
    }
    
    const value = await fn(...args);
    cache.set(key, { value, timestamp: Date.now() });
    return value;
  };
}

// 使用
const fetchUserCached = asyncCache((id: number) => fetchJSON<User>(`/api/users/${id}`));

const userData = await fetchUserCached(1);  // 实际请求
const userData2 = await fetchUserCached(1);  // 缓存命中
```
