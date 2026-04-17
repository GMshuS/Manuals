# Node.js 高级特性手册

> 本手册对比 Python 语言，详细介绍 Node.js 的高级编程特性

## 目录

1. [Promise](#promise)
2. [async/await](#asyncawait)
3. [生成器](#生成器)
4. [迭代器](#迭代器)
5. [装饰器](#装饰器)
6. [Proxy](#proxy)
7. [Reflect](#reflect)

---

## Promise

### Promise 基础

```javascript
// 创建 Promise
const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("Success!");
    }, 1000);
});

// 使用 Promise
promise
    .then(result => console.log(result))
    .catch(error => console.error(error));

// 链式调用
fetchData()
    .then(data => processData(data))
    .then(result => console.log(result))
    .catch(error => console.error(error));
```

### Python 语言对比

```python
# Python asyncio.Future
import asyncio

async def main():
    await asyncio.sleep(1)
    print("Success!")

asyncio.run(main())
```

### Promise 状态

```javascript
// Pending - 初始状态
// Fulfilled - 成功
// Rejected - 失败

const promise = new Promise((resolve, reject) => {
    if (success) {
        resolve(result);
    } else {
        reject(new Error("Failed"));
    }
});
```

### Promise 组合

```javascript
// Promise.all - 所有完成或一个失败
const [result1, result2, result3] = await Promise.all([
    promise1,
    promise2,
    promise3
]);

// Promise.allSettled - 等待所有完成
const results = await Promise.allSettled([promise1, promise2]);
results.forEach(result => {
    if (result.status === 'fulfilled') {
        console.log('Success:', result.value);
    } else {
        console.error('Failed:', result.reason);
    }
});

// Promise.race - 第一个完成
const first = await Promise.race([promise1, promise2]);

// Promise.any - 第一个成功
const firstSuccess = await Promise.any([promise1, promise2]);

// Promise.resolve/reject
const resolved = Promise.resolve(value);
const rejected = Promise.reject(error);
```

### Python 语言对比

```python
# asyncio.gather
results = await asyncio.gather(task1(), task2(), task3())

# 带异常处理
results = await asyncio.gather(
    task1(), task2(),
    return_exceptions=True
)
```

---

## async/await

### 异步函数

```javascript
// 定义异步函数
async function fetchData() {
    const response = await fetch('https://api.example.com/data');
    const data = await response.json();
    return data;
}

// 调用异步函数
fetchData()
    .then(data => console.log(data))
    .catch(err => console.error(err));

// 或在另一个 async 函数中
async function main() {
    try {
        const data = await fetchData();
        console.log(data);
    } catch (err) {
        console.error(err);
    }
}

main();
```

### 错误处理

```javascript
async function process() {
    try {
        const data = await fetchData();
        const result = await processData(data);
        return result;
    } catch (error) {
        console.error('Error:', error);
        throw error;  // 重新抛出
    }
}
```

### Python 语言对比

```python
async def fetch_data():
    response = await fetch('https://api.example.com/data')
    data = await response.json()
    return data

async def main():
    try:
        data = await fetch_data()
        print(data)
    except Exception as e:
        print(f'Error: {e}')

asyncio.run(main())
```

### 并发执行

```javascript
// 顺序执行（慢）
async function sequential() {
    const result1 = await fetchUrl('url1');
    const result2 = await fetchUrl('url2');
    const result3 = await fetchUrl('url3');
    return [result1, result2, result3];
}

// 并发执行（快）
async function concurrent() {
    const [result1, result2, result3] = await Promise.all([
        fetchUrl('url1'),
        fetchUrl('url2'),
        fetchUrl('url3')
    ]);
    return [result1, result2, result3];
}
```

---

## 生成器

### 生成器函数

```javascript
// 定义生成器
function* countUpTo(n) {
    let count = 1;
    while (count <= n) {
        yield count;
        count++;
    }
}

// 使用生成器
const gen = countUpTo(3);
console.log(gen.next());  // { value: 1, done: false }
console.log(gen.next());  // { value: 2, done: false }
console.log(gen.next());  // { value: 3, done: false }
console.log(gen.next());  // { value: undefined, done: true }

// for...of 遍历
for (const num of countUpTo(5)) {
    console.log(num);  // 1, 2, 3, 4, 5
}
```

### yield 用法

```javascript
function* accumulator() {
    let total = 0;
    while (true) {
        const value = yield total;
        if (value === undefined) break;
        total += value;
    }
}

const gen = accumulator();
gen.next();        // { value: 0, done: false }
gen.next(10);      // { value: 10, done: false }
gen.next(20);      // { value: 30, done: false }
gen.next();        // { value: undefined, done: true }
```

### yield* 委托

```javascript
function* subGenerator() {
    yield 1;
    yield 2;
    yield 3;
}

function* mainGenerator() {
    yield* subGenerator();
    yield 4;
    yield 5;
}

[...mainGenerator()];  // [1, 2, 3, 4, 5]
```

### Python 语言对比

```python
def count_up_to(n):
    count = 1
    while count <= n:
        yield count
        count += 1

for num in count_up_to(5):
    print(num)

# send() 和 yield from
def accumulator():
    total = 0
    while True:
        value = yield total
        if value is None:
            break
        total += value

def main():
    yield from sub_generator()
```

---

## 迭代器

### 迭代器协议

```javascript
class Counter {
    constructor(start, end) {
        this.current = start;
        this.end = end;
    }
    
    [Symbol.iterator]() {
        return this;
    }
    
    next() {
        if (this.current > this.end) {
            return { value: undefined, done: true };
        }
        return { value: this.current++, done: false };
    }
}

// 使用
for (const num of new Counter(1, 5)) {
    console.log(num);  // 1, 2, 3, 4, 5
}
```

### 可迭代对象

```javascript
const iterable = {
    *[Symbol.iterator]() {
        yield 1;
        yield 2;
        yield 3;
    }
};

for (const num of iterable) {
    console.log(num);
}

// 展开运算符
[...iterable];  // [1, 2, 3]
```

### Python 语言对比

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

for num in Counter(1, 5):
    print(num)
```

---

## 装饰器

### 类装饰器

```javascript
// JavaScript 装饰器（Stage 3 提案）
function frozen(target, name, descriptor) {
    descriptor.writable = false;
    return descriptor;
}

class MyClass {
    @frozen
    method() {
        return 'frozen';
    }
}

// 类装饰器
function sealed(constructor) {
    Object.seal(constructor);
    Object.seal(constructor.prototype);
}

@sealed
class MyClass {}
```

### Python 语言对比

```python
# Python 装饰器
def frozen(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

class MyClass:
    @frozen
    def method(self):
        return 'frozen'

# 类装饰器
def sealed(cls):
    return cls

@sealed
class MyClass:
    pass
```

---

## Proxy

### Proxy 基础

```javascript
const target = {
    name: 'Alice',
    age: 25
};

const handler = {
    get(target, prop, receiver) {
        console.log(`Getting ${prop}`);
        return Reflect.get(target, prop, receiver);
    },
    set(target, prop, value, receiver) {
        console.log(`Setting ${prop} to ${value}`);
        return Reflect.set(target, prop, value, receiver);
    }
};

const proxy = new Proxy(target, handler);

proxy.name;  // Getting name
proxy.age = 26;  // Setting age to 26
```

### 应用示例

```javascript
// 验证
function createValidator(target) {
    return new Proxy(target, {
        set(target, prop, value) {
            if (prop === 'age' && (value < 0 || value > 150)) {
                throw new Error('Invalid age');
            }
            target[prop] = value;
            return true;
        }
    });
}

const person = createValidator({ name: 'Alice', age: 25 });
person.age = 26;  // OK
person.age = -1;  // Error

// 默认值
function withDefaults(target, defaults) {
    return new Proxy(target, {
        get(target, prop) {
            if (prop in target) {
                return target[prop];
            }
            return defaults[prop];
        }
    });
}

const config = withDefaults({}, { theme: 'light', lang: 'en' });
console.log(config.theme);  // light
```

---

## Reflect

### Reflect 方法

```javascript
const obj = { name: 'Alice', age: 25 };

// 获取属性
Reflect.get(obj, 'name');  // 'Alice'

// 设置属性
Reflect.set(obj, 'age', 26);

// 检查属性
Reflect.has(obj, 'name');  // true

// 删除属性
Reflect.deleteProperty(obj, 'age');

// 获取属性描述符
Reflect.getOwnPropertyDescriptor(obj, 'name');

// 调用函数
Reflect.apply(Math.max, null, [1, 2, 3]);

// 构造函数
Reflect.construct(Date, ['2024-01-01']);
```

---

## Node.js 与 Python 高级特性对比总结

| 特性 | JavaScript (Node.js) | Python |
|------|---------------------|--------|
| Promise | 原生支持 | asyncio.Future |
| async/await | 原生支持 | 原生支持 |
| 生成器 | `function*`, `yield` | `def`, `yield` |
| 迭代器 | `Symbol.iterator` | `__iter__`, `__next__` |
| 装饰器 | 提案阶段 | 原生支持 |
| Proxy | 原生支持 | `__getattr__` 等 |
| 上下文管理器 | 无 | `with`, `__enter__` |
