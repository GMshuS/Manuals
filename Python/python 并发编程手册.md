# Python 并发编程手册

> 本手册对比 Go 语言，详细介绍 Python 的并发和并行编程

## 目录

1. [线程基础](#线程基础)
2. [线程同步](#线程同步)
3. [多进程](#多进程)
4. [异步编程](#异步编程)
5. [并发最佳实践](#并发最佳实践)

---

## 线程基础

### threading 模块

```python
import threading
import time

def worker(name, delay):
    for i in range(5):
        time.sleep(delay)
        print(f"{name}: {i}")

# 创建线程
t1 = threading.Thread(target=worker, args=("Thread-A", 0.5))
t2 = threading.Thread(target=worker, args=("Thread-B", 0.5))

# 启动线程
t1.start()
t2.start()

# 等待线程完成
t1.join()
t2.join()

print("All threads completed")
```

### Go 语言对比

```go
import "sync"

func worker(name string, delay time.Duration) {
    for i := 0; i < 5; i++ {
        time.Sleep(delay)
        fmt.Printf("%s: %d\n", name, i)
    }
}

// 使用 WaitGroup
var wg sync.WaitGroup
wg.Add(2)

go func() {
    defer wg.Done()
    worker("Goroutine-A", 500*time.Millisecond)
}()

go func() {
    defer wg.Done()
    worker("Goroutine-B", 500*time.Millisecond)
}()

wg.Wait()
```

### 线程参数传递

```python
from threading import Thread

def greet(name, greeting="Hello"):
    print(f"{greeting}, {name}!")

threads = []
for name in ["Alice", "Bob", "Charlie"]:
    t = Thread(target=greet, args=(name,))
    t.start()
    threads.append(t)

for t in threads:
    t.join()

# 使用关键字参数
t = Thread(target=greet, kwargs={"name": "Dave", "greeting": "Hi"})
t.start()
t.join()
```

### 守护线程

```python
import threading
import time

def background_task():
    while True:
        print("Background task running...")
        time.sleep(1)

# 创建守护线程
t = threading.Thread(target=background_task, daemon=True)
t.start()

# 主线程等待 5 秒
time.sleep(5)
print("Main thread exiting")
# 守护线程会随主线程结束而终止
```

### Go 语言对比

```go
// Go 没有守护线程概念
// 可以通过 context 控制 goroutine 生命周期
ctx, cancel := context.WithCancel(context.Background())

go func() {
    for {
        select {
        case <-ctx.Done():
            return
        default:
            fmt.Println("Background task...")
            time.Sleep(time.Second)
        }
    }
}()

// 5 秒后取消
time.Sleep(5 * time.Second)
cancel()
```

---

## 线程同步

### Lock（互斥锁）

```python
import threading

counter = 0
lock = threading.Lock()

def increment():
    global counter
    for _ in range(100000):
        with lock:  # 自动获取和释放锁
            counter += 1

threads = []
for _ in range(5):
    t = threading.Thread(target=increment)
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print(f"Final counter: {counter}")  # 500000
```

### Go 语言对比

```go
import "sync"

var (
    counter int
    mu      sync.Mutex
)

func increment() {
    for i := 0; i < 100000; i++ {
        mu.Lock()
        counter++
        mu.Unlock()
    }
}

var wg sync.WaitGroup
for i := 0; i < 5; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        increment()
    }()
}
wg.Wait()

fmt.Println("Final counter:", counter)
```

### RLock（读写锁）

```python
from threading import RLock

class DataStore:
    def __init__(self):
        self._data = {}
        self._lock = RLock()
    
    def get(self, key):
        with self._lock:
            return self._data.get(key)
    
    def set(self, key, value):
        with self._lock:
            self._data[key] = value
    
    def get_or_set(self, key, default):
        with self._lock:
            if key not in self._data:
                self._data[key] = default
            return self._data[key]
```

### Go 语言对比

```go
import "sync"

type DataStore struct {
    mu   sync.RWMutex
    data map[string]interface{}
}

func (ds *DataStore) Get(key string) interface{} {
    ds.mu.RLock()
    defer ds.mu.RUnlock()
    return ds.data[key]
}

func (ds *DataStore) Set(key string, value interface{}) {
    ds.mu.Lock()
    defer ds.mu.Unlock()
    ds.data[key] = value
}
```

### Condition（条件变量）

```python
import threading

class Queue:
    def __init__(self, max_size):
        self._queue = []
        self._max_size = max_size
        self._lock = threading.Lock()
        self._not_empty = threading.Condition(self._lock)
        self._not_full = threading.Condition(self._lock)
    
    def put(self, item):
        with self._not_full:
            while len(self._queue) >= self._max_size:
                self._not_full.wait()
            self._queue.append(item)
            self._not_empty.notify()
    
    def get(self):
        with self._not_empty:
            while not self._queue:
                self._not_empty.wait()
            item = self._queue.pop(0)
            self._not_full.notify()
            return item
```

### Go 语言对比

```go
// Go 使用 channel 实现同步
func worker(ch chan int) {
    for item := range ch {
        fmt.Println("Processing:", item)
    }
}

ch := make(chan int, 10)
go worker(ch)

// 发送数据
ch <- 1
ch <- 2

// 关闭 channel
close(ch)
```

### Event（事件）

```python
import threading
import time

event = threading.Event()

def waiter(name):
    print(f"{name}: waiting for event")
    event.wait()
    print(f"{name}: event received")

threads = [threading.Thread(target=waiter, args=(f"Worker-{i}",)) 
           for i in range(3)]

for t in threads:
    t.start()

time.sleep(2)
print("Setting event")
event.set()

for t in threads:
    t.join()
```

### Semaphore（信号量）

```python
from threading import Semaphore, Thread
import time

semaphore = Semaphore(3)  # 最多 3 个并发

def worker(id):
    with semaphore:
        print(f"Worker {id} starting")
        time.sleep(1)
        print(f"Worker {id} done")

threads = [Thread(target=worker, args=(i,)) for i in range(10)]
for t in threads:
    t.start()
for t in threads:
    t.join()
```

### Go 语言对比

```go
// Go 使用 buffered channel 实现信号量
sem := make(chan struct{}, 3)

func worker(id int) {
    sem <- struct{}{}  // 获取信号量
    defer func() { <-sem }()  // 释放信号量
    
    fmt.Printf("Worker %d starting\n", id)
    time.Sleep(time.Second)
    fmt.Printf("Worker %d done\n", id)
}

for i := 0; i < 10; i++ {
    go worker(i)
}
```

### Barrier（屏障）

```python
from threading import Barrier, Thread
import time

barrier = Barrier(3)  # 等待 3 个线程

def worker(id):
    print(f"Worker {id} arrived")
    barrier.wait()
    print(f"Worker {id} proceeding")

threads = [Thread(target=worker, args=(i,)) for i in range(3)]
for t in threads:
    t.start()
for t in threads:
    t.join()
```

---

## 多进程

### multiprocessing 模块

```python
from multiprocessing import Process

def worker(name):
    print(f"Worker {name} running")

processes = []
for i in range(4):
    p = Process(target=worker, args=(f"Process-{i}",))
    p.start()
    processes.append(p)

for p in processes:
    p.join()
```

### Go 语言对比

```go
// Go 的 goroutine 比进程轻量得多
// 不需要显式的多进程管理
for i := 0; i < 4; i++ {
    go worker(fmt.Sprintf("Goroutine-%d", i))
}
```

### 进程池

```python
from multiprocessing import Pool

def square(x):
    return x * x

with Pool(processes=4) as pool:
    # map
    results = pool.map(square, range(10))
    print(results)  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
    
    # map_async
    async_result = pool.map_async(square, range(10))
    results = async_result.get()
    
    # apply
    result = pool.apply(square, args=(5,))
    
    # apply_async
    async_result = pool.apply_async(square, args=(5,))
    result = async_result.get()
```

### 进程间通信（Queue）

```python
from multiprocessing import Process, Queue

def producer(q):
    for i in range(5):
        q.put(i)
    q.put(None)  # 结束标记

def consumer(q):
    while True:
        item = q.get()
        if item is None:
            break
        print(f"Consumed: {item}")

q = Queue()
p1 = Process(target=producer, args=(q,))
p2 = Process(target=consumer, args=(q,))

p1.start()
p2.start()
p1.join()
p2.join()
```

### Go 语言对比

```go
// Go channel 天然支持进程间通信
func producer(ch chan<- int) {
    for i := 0; i < 5; i++ {
        ch <- i
    }
    close(ch)
}

func consumer(ch <-chan int) {
    for item := range ch {
        fmt.Println("Consumed:", item)
    }
}

ch := make(chan int)
go producer(ch)
go consumer(ch)
```

### 进程间通信（Pipe）

```python
from multiprocessing import Process, Pipe

def sender(conn):
    conn.send(["Hello", "from", "sender"])
    conn.close()

def receiver(conn):
    data = conn.recv()
    print(f"Received: {data}")
    conn.close()

parent_conn, child_conn = Pipe()
p1 = Process(target=sender, args=(parent_conn,))
p2 = Process(target=receiver, args=(child_conn,))

p1.start()
p2.start()
p1.join()
p2.join()
```

### 共享内存

```python
from multiprocessing import Process, Value, Array, Manager

def increment(shared_value, shared_array):
    shared_value.value += 1
    shared_array[0] += 1

if __name__ == "__main__":
    # Value 和 Array
    num = Value('i', 0)  # 'i' 表示 int
    arr = Array('i', [0, 0, 0])
    
    processes = []
    for _ in range(10):
        p = Process(target=increment, args=(num, arr))
        p.start()
        processes.append(p)
    
    for p in processes:
        p.join()
    
    print(f"Value: {num.value}")
    print(f"Array: {arr[:]}")
    
    # Manager（更灵活）
    with Manager() as manager:
        shared_list = manager.list()
        shared_dict = manager.dict()
        
        def modify():
            shared_list.append(1)
            shared_dict['key'] = 'value'
        
        processes = []
        for _ in range(5):
            p = Process(target=modify)
            p.start()
            processes.append(p)
        
        for p in processes:
            p.join()
        
        print(f"List: {list(shared_list)}")
        print(f"Dict: {dict(shared_dict)}")
```

### Go 语言对比

```go
// Go 使用 channel 进行通信，而不是共享内存
// "Don't communicate by sharing memory, share memory by communicating"

func worker(id int, ch chan<- int) {
    ch <- id * 2
}

ch := make(chan int)
for i := 0; i < 5; i++ {
    go worker(i, ch)
}

for i := 0; i < 5; i++ {
    result := <-ch
    fmt.Println("Result:", result)
}
```

---

## 异步编程

### asyncio 基础

```python
import asyncio

async def fetch_data(url, delay):
    print(f"Fetching {url}")
    await asyncio.sleep(delay)  # 非阻塞等待
    print(f"Finished {url}")
    return f"Data from {url}"

async def main():
    # 顺序执行
    data1 = await fetch_data("url1", 1)
    data2 = await fetch_data("url2", 1)
    
    # 并发执行
    results = await asyncio.gather(
        fetch_data("url1", 1),
        fetch_data("url2", 1),
        fetch_data("url3", 1)
    )
    print(results)

asyncio.run(main())
```

### Go 语言对比

```go
// Go 的 goroutine 和 channel 实现类似功能
func fetchData(url string, delay time.Duration, ch chan<- string) {
    fmt.Printf("Fetching %s\n", url)
    time.Sleep(delay)
    fmt.Printf("Finished %s\n", url)
    ch <- fmt.Sprintf("Data from %s", url)
}

func main() {
    ch := make(chan string)
    
    go fetchData("url1", time.Second, ch)
    go fetchData("url2", time.Second, ch)
    go fetchData("url3", time.Second, ch)
    
    var results []string
    for i := 0; i < 3; i++ {
        results = append(results, <-ch)
    }
    fmt.Println(results)
}
```

### Task 创建和管理

```python
import asyncio

async def work(name, delay):
    for i in range(3):
        await asyncio.sleep(delay)
        print(f"{name}: {i}")

async def main():
    # 创建任务
    task1 = asyncio.create_task(work("A", 0.5))
    task2 = asyncio.create_task(work("B", 0.5))
    
    # 等待完成
    await task1
    await task2
    
    # 或同时等待
    # await asyncio.gather(task1, task2)
    
    # 取消任务
    task3 = asyncio.create_task(work("C", 1))
    await asyncio.sleep(1.5)
    task3.cancel()
    
    # 带超时
    try:
        await asyncio.wait_for(work("D", 10), timeout=2)
    except asyncio.TimeoutError:
        print("Task timed out")

asyncio.run(main())
```

### Go 语言对比

```go
// Go 使用 context 控制超时和取消
func work(ctx context.Context, name string, delay time.Duration) {
    for i := 0; i < 3; i++ {
        select {
        case <-ctx.Done():
            fmt.Printf("%s: cancelled\n", name)
            return
        case <-time.After(delay):
            fmt.Printf("%s: %d\n", name, i)
        }
    }
}

// 带超时
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

go work(ctx, "A", time.Second)
```

### 异步上下文管理器

```python
import asyncio

class AsyncConnection:
    async def __aenter__(self):
        print("Connecting...")
        await asyncio.sleep(1)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print("Disconnecting...")
        await asyncio.sleep(1)
    
    async def query(self, sql):
        await asyncio.sleep(0.5)
        return f"Result of: {sql}"

async def main():
    async with AsyncConnection() as conn:
        result = await conn.query("SELECT * FROM users")
        print(result)

asyncio.run(main())
```

### Go 语言对比

```go
// Go 使用 defer 和 context
type Connection struct{}

func (c *Connection) Close() error {
    fmt.Println("Disconnecting...")
    return nil
}

func connect(ctx context.Context) (*Connection, error) {
    fmt.Println("Connecting...")
    return &Connection{}, nil
}

func main() {
    ctx := context.Background()
    conn, err := connect(ctx)
    if err != nil {
        return
    }
    defer conn.Close()
    
    // 使用连接
}
```

### 异步迭代器

```python
import asyncio

class AsyncCounter:
    def __init__(self, max):
        self.max = max
        self.current = 0
    
    def __aiter__(self):
        return self
    
    async def __anext__(self):
        if self.current >= self.max:
            raise StopAsyncIteration
        await asyncio.sleep(0.5)
        value = self.current
        self.current += 1
        return value

async def main():
    async for num in AsyncCounter(5):
        print(num)

asyncio.run(main())
```

### aiohttp 示例

```python
import aiohttp
import asyncio

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        urls = [
            "https://api.example.com/data1",
            "https://api.example.com/data2",
            "https://api.example.com/data3",
        ]
        
        tasks = [fetch(session, url) for url in urls]
        responses = await asyncio.gather(*tasks)
        
        for response in responses:
            print(response)

# asyncio.run(main())
```

---

## 并发最佳实践

### 1. 避免竞态条件

```python
# ❌ 不安全
counter = 0

def unsafe_increment():
    global counter
    temp = counter
    counter = temp + 1

# ✅ 安全
lock = threading.Lock()

def safe_increment():
    global counter
    with lock:
        counter += 1
```

### 2. 避免死锁

```python
# ❌ 可能死锁
lock1 = threading.Lock()
lock2 = threading.Lock()

def thread1():
    with lock1:
        with lock2:
            pass

def thread2():
    with lock2:  # 顺序相反
        with lock1:
            pass

# ✅ 避免死锁：始终按相同顺序获取锁
def safe_thread1():
    with lock1:
        with lock2:
            pass

def safe_thread2():
    with lock1:  # 相同顺序
        with lock2:
            pass
```

### 3. 使用线程安全的数据结构

```python
from queue import Queue
import threading

# 使用 Queue 进行线程间通信
q = Queue()
q.put(item)
item = q.get()  # 阻塞直到有数据
q.task_done()   # 标记任务完成

# 或使用 threading.local 创建线程本地存储
local_data = threading.local()

def worker():
    local_data.value = get_thread_specific_value()
    print(local_data.value)
```

### Go 语言对比

```go
// Go 优先使用 channel
ch := make(chan int)
ch <- value  // 发送
value := <-ch // 接收

// 使用 sync.Map 用于并发场景
var m sync.Map
m.Store("key", "value")
value, ok := m.Load("key")
```

### 4. 合理设置线程/进程数

```python
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import os

# CPU 密集型任务：使用进程池
with ProcessPoolExecutor(max_workers=os.cpu_count()) as executor:
    results = executor.map(cpu_intensive_function, data)

# IO 密集型任务：使用线程池
with ThreadPoolExecutor(max_workers=10) as executor:
    results = executor.map(io_function, urls)
```

### 5. 使用 asyncio.Semaphore 限制并发

```python
import asyncio

semaphore = asyncio.Semaphore(5)  # 最多 5 个并发

async def limited_worker(url):
    async with semaphore:
        await fetch(url)

# 使用
async def main():
    urls = ["url1", "url2", "url3", ...]
    tasks = [limited_worker(url) for url in urls]
    await asyncio.gather(*tasks)
```

---

## 并发模式对比

| 模式 | Python | Go |
|------|--------|-----|
| 线程 | `threading.Thread` | `goroutine` |
| 锁 | `threading.Lock` | `sync.Mutex` |
| 读写锁 | `threading.RLock` | `sync.RWMutex` |
| 条件变量 | `threading.Condition` | `sync.Cond` |
| 信号量 | `threading.Semaphore` | buffered channel |
| 队列 | `queue.Queue` | `chan T` |
| 事件 | `threading.Event` | `context.Context` |
| 屏障 | `threading.Barrier` | `sync.WaitGroup` |
| 进程池 | `multiprocessing.Pool` | 不常用 |
| 异步 | `asyncio` | 原生支持 |

---

## 并发选择指南

### Python

- **CPU 密集型**：使用 `multiprocessing`
- **IO 密集型**：使用 `threading` 或 `asyncio`
- **网络 IO**：优先使用 `asyncio` + `aiohttp`
- **简单并发**：使用 `concurrent.futures`

### Go

- **任何场景**：优先使用 `goroutine` + `channel`
- **共享状态**：使用 `sync.Mutex` 或 `sync.Map`
- **超时控制**：使用 `context.Context`
- **批量处理**：使用 `errgroup`
