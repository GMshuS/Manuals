# Node.js 并发编程手册

> 本手册对比 Python 语言，详细介绍 Node.js 的并发和并行编程

## 目录

1. [事件循环](#事件循环)
2. [异步编程基础](#异步编程基础)
3. [Promise 并发控制](#promise-并发控制)
4. [Worker Threads](#worker-threads)
5. [Cluster 模块](#cluster-模块)
6. [child_process](#child_process)

---

## 事件循环

### 事件循环阶段

```javascript
// Node.js 事件循环阶段：
// 1. Timers - setTimeout, setInterval
// 2. Pending callbacks - I/O callbacks
// 3. Idle, Prepare - 内部使用
// 4. Poll - 新的 I/O 事件
// 5. Check - setImmediate
// 6. Close callbacks - close 事件

setTimeout(() => console.log('timer'), 0);
setImmediate(() => console.log('immediate'));
Promise.resolve().then(() => console.log('promise'));

// 输出顺序可能不同，但 promise 总是在下一个微任务执行
```

### Python 语言对比

```python
# Python asyncio 事件循环
import asyncio

async def main():
    await asyncio.sleep(0)
    print('async')

asyncio.run(main())
```

---

## 异步编程基础

### 回调模式

```javascript
// 回调函数
fs.readFile('file.txt', 'utf-8', (err, data) => {
    if (err) {
        console.error(err);
        return;
    }
    console.log(data);
});

// 回调地狱（避免）
fs.readFile('file1.txt', 'utf-8', (err, data1) => {
    if (err) throw err;
    fs.readFile('file2.txt', 'utf-8', (err, data2) => {
        if (err) throw err;
        fs.readFile('file3.txt', 'utf-8', (err, data3) => {
            console.log(data1, data2, data3);
        });
    });
});
```

### Promise 模式

```javascript
// Promise 链
fsPromises.readFile('file1.txt', 'utf-8')
    .then(data1 => fsPromises.readFile('file2.txt', 'utf-8'))
    .then(data2 => fsPromises.readFile('file3.txt', 'utf-8'))
    .then(data3 => console.log(data3))
    .catch(err => console.error(err));

// async/await（推荐）
async function readFiles() {
    try {
        const data1 = await fsPromises.readFile('file1.txt', 'utf-8');
        const data2 = await fsPromises.readFile('file2.txt', 'utf-8');
        const data3 = await fsPromises.readFile('file3.txt', 'utf-8');
        console.log(data1, data2, data3);
    } catch (err) {
        console.error(err);
    }
}
```

### Python 语言对比

```python
# Python asyncio
import asyncio
import aiofiles

async def read_file(filename):
    async with aiofiles.open(filename, 'r') as f:
        return await f.read()

async def main():
    data1 = await read_file('file1.txt')
    data2 = await read_file('file2.txt')
    data3 = await read_file('file3.txt')
    print(data1, data2, data3)

asyncio.run(main())
```

---

## Promise 并发控制

### 并发执行

```javascript
// 限制并发数
async function limitedConcurrency(tasks, limit) {
    const results = [];
    const running = [];
    
    for (const task of tasks) {
        const promise = task().then(result => {
            results.push(result);
            running.splice(running.indexOf(promise), 1);
            return result;
        });
        running.push(promise);
        
        if (running.length >= limit) {
            await Promise.race(running);
        }
    }
    
    await Promise.all(running);
    return results;
}

// 使用
const tasks = [
    () => fetchUrl('url1'),
    () => fetchUrl('url2'),
    () => fetchUrl('url3'),
];

const results = await limitedConcurrency(tasks, 2);
```

### Semaphore 模式

```javascript
class Semaphore {
    constructor(limit) {
        this.limit = limit;
        this.count = 0;
        this.queue = [];
    }
    
    async acquire() {
        if (this.count < this.limit) {
            this.count++;
            return Promise.resolve();
        }
        
        return new Promise(resolve => {
            this.queue.push(resolve);
        });
    }
    
    release() {
        this.count--;
        if (this.queue.length > 0) {
            this.count++;
            const next = this.queue.shift();
            next();
        }
    }
}

// 使用
const semaphore = new Semaphore(3);

async function worker(id) {
    await semaphore.acquire();
    try {
        console.log(`Worker ${id} starting`);
        await doWork();
    } finally {
        semaphore.release();
    }
}
```

### Python 语言对比

```python
# asyncio.Semaphore
semaphore = asyncio.Semaphore(5)

async def limited_worker(url):
    async with semaphore:
        await fetch(url)
```

---

## Worker Threads

### Worker 基础

```javascript
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');

// 主线程
if (isMainThread) {
    const worker = new Worker(__filename, {
        workerData: { value: 42 }
    });
    
    worker.on('message', (msg) => {
        console.log('From worker:', msg);
    });
    
    worker.postMessage('Hello from main');
} else {
    // Worker 线程
    parentPort.on('message', (msg) => {
        console.log('From main:', msg);
        
        // 执行计算密集型任务
        const result = heavyComputation(workerData.value);
        parentPort.postMessage(result);
    });
}
```

### Python 语言对比

```python
# Python multiprocessing
from multiprocessing import Process, Queue

def worker(q, value):
    result = heavy_computation(value)
    q.put(result)

q = Queue()
p = Process(target=worker, args=(q, 42))
p.start()
result = q.get()
p.join()
```

---

## Cluster 模块

### Cluster 基础

```javascript
const cluster = require('cluster');
const os = require('os');

if (cluster.isMaster) {
    const numCPUs = os.cpus().length;
    console.log(`Master ${process.pid} started, ${numCPUs} workers`);
    
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
    
    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
        cluster.fork();  // 重启
    });
} else {
    // Worker 进程
    const http = require('http');
    
    http.createServer((req, res) => {
        res.writeHead(200);
        res.end('Hello from worker ' + process.pid);
    }).listen(3000);
    
    console.log('Worker ' + process.pid + ' started');
}
```

### Python 语言对比

```python
# Python multiprocessing
from multiprocessing import Process
import os

def worker():
    print(f'Worker {os.getpid()}')

processes = []
for _ in range(os.cpu_count()):
    p = Process(target=worker)
    p.start()
    processes.append(p)

for p in processes:
    p.join()
```

---

## child_process

### 派生子进程

```javascript
const { exec, execSync, spawn, fork } = require('child_process');

// exec（命令执行）
exec('ls -la', (error, stdout, stderr) => {
    if (error) {
        console.error(error);
        return;
    }
    console.log(stdout);
});

// execSync（同步）
const output = execSync('ls -la', 'utf-8');

// spawn（流式）
const child = spawn('ls', ['-la']);
child.stdout.on('data', (data) => {
    console.log(`stdout: ${data}`);
});
child.stderr.on('data', (data) => {
    console.error(`stderr: ${data}`);
});
child.on('close', (code) => {
    console.log(`Child process exited with code ${code}`);
});

// fork（Node.js 模块）
const child = fork('child.js');
child.send({ hello: 'world' });
child.on('message', (msg) => {
    console.log('Message from child:', msg);
});
```

### Python 语言对比

```python
# Python subprocess
import subprocess

# 执行命令
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# 同步执行
output = subprocess.check_output(['ls', '-la'], text=True)

# 异步
process = subprocess.Popen(['ls', '-la'], stdout=subprocess.PIPE)
output, _ = process.communicate()
```

---

## Node.js 与 Python 并发对比总结

| 特性 | Node.js | Python |
|------|---------|--------|
| 事件循环 | 原生支持 | asyncio |
| Promise | 原生支持 | asyncio.Future |
| async/await | 原生支持 | 原生支持 |
| 线程 | Worker Threads | threading |
| 进程 | child_process, cluster | multiprocessing |
| 并发控制 | Semaphore 类 | asyncio.Semaphore |
| GIL 限制 | 无 | 有（threading） |
| 推荐并发模型 | 异步 IO | asyncio, multiprocessing |
