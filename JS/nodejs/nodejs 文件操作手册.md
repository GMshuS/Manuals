# Node.js 文件操作手册

> 本手册对比 Python 语言，详细介绍 Node.js 的文件和 I/O 操作

## 目录

1. [fs 模块基础](#fs-模块基础)
2. [文件读取](#文件读取)
3. [文件写入](#文件写入)
4. [路径操作](#路径操作)
5. [流式读写](#流式读写)
6. [Buffer 操作](#buffer-操作)
7. [文件和目录管理](#文件和目录管理)

---

## fs 模块基础

### 导入 fs 模块

```javascript
const fs = require('fs');
const fsPromises = require('fs').promises;
const path = require('path');
```

### 同步 vs 异步

```javascript
// 同步读取（阻塞）
try {
    const data = fs.readFileSync('file.txt', 'utf-8');
    console.log(data);
} catch (error) {
    console.error(error);
}

// 异步读取（回调）
fs.readFile('file.txt', 'utf-8', (err, data) => {
    if (err) {
        console.error(err);
        return;
    }
    console.log(data);
});

// Promise 方式
fsPromises.readFile('file.txt', 'utf-8')
    .then(data => console.log(data))
    .catch(err => console.error(err));

// async/await（推荐）
async function readFileAsync() {
    try {
        const data = await fsPromises.readFile('file.txt', 'utf-8');
        console.log(data);
    } catch (err) {
        console.error(err);
    }
}
```

### Python 语言对比

```python
# Python 同步读取
with open('file.txt', 'r', encoding='utf-8') as f:
    data = f.read()
    print(data)

# Python 异步（asyncio）
import aiofiles
async with aiofiles.open('file.txt', 'r') as f:
    data = await f.read()
```

---

## 文件读取

### 读取整个文件

```javascript
// 同步
const data = fs.readFileSync('file.txt', 'utf-8');

// 异步
fs.readFile('file.txt', 'utf-8', (err, data) => {
    if (err) throw err;
    console.log(data);
});

// Promise
const data = await fsPromises.readFile('file.txt', 'utf-8');

// 读取为 Buffer（二进制）
const buffer = fs.readFileSync('image.png');
```

### 按行读取

```javascript
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
    input: fs.createReadStream('file.txt'),
    crlfDelay: Infinity
});

for await (const line of rl) {
    console.log(line);
}
```

### Python 语言对比

```python
# 按行读取
with open('file.txt', 'r') as f:
    for line in f:
        print(line.strip())

# 读取所有行
with open('file.txt', 'r') as f:
    lines = f.readlines()
```

---

## 文件写入

### 写入文本

```javascript
// 同步写入（覆盖）
fs.writeFileSync('output.txt', 'Hello, World!', 'utf-8');

// 异步写入
fs.writeFile('output.txt', 'Hello, World!', 'utf-8', (err) => {
    if (err) throw err;
    console.log('File saved');
});

// Promise
await fsPromises.writeFile('output.txt', 'Hello, World!', 'utf-8');

// 追加写入
fs.appendFileSync('log.txt', 'New log entry\n', 'utf-8');
await fsPromises.appendFile('log.txt', 'Entry\n', 'utf-8');
```

### 写入多行

```javascript
const lines = ['Line 1\n', 'Line 2\n', 'Line 3\n'];
fs.writeFileSync('output.txt', lines.join(''), 'utf-8');
```

### Python 语言对比

```python
# Python 写入
with open('output.txt', 'w', encoding='utf-8') as f:
    f.write('Hello, World!\n')
    f.writelines(['Line 1\n', 'Line 2\n'])

# 追加
with open('log.txt', 'a') as f:
    f.write('New entry\n')
```

---

## 路径操作

### path 模块

```javascript
const path = require('path');

// 路径拼接
const fullPath = path.join('data', 'subdir', 'file.txt');

// 路径信息
console.log(path.basename('/path/to/file.txt'));      // file.txt
console.log(path.dirname('/path/to/file.txt'));       // /path/to
console.log(path.extname('/path/to/file.txt'));       // .txt
console.log(path.parse('/path/to/file.txt'));
// { root: '/', dir: '/path/to', base: 'file.txt', ext: '.txt', name: 'file' }

// 绝对路径
console.log(path.resolve('file.txt'));  // 当前目录的绝对路径
console.log(path.resolve('data', 'file.txt'));

// 相对路径
console.log(path.relative('/a/b', '/a/b/c/d'));  // ../c/d
```

### Python 语言对比

```python
from pathlib import Path

# 路径拼接
full_path = Path('data') / 'subdir' / 'file.txt'

# 路径信息
print(full_path.name)        # file.txt
print(full_path.stem)        # file
print(full_path.suffix)      # .txt
print(full_path.parent)      # data/subdir

# 绝对路径
print(full_path.absolute())
```

---

## 流式读写

### 读取流

```javascript
const fs = require('fs');

const readStream = fs.createReadStream('large-file.txt', {
    encoding: 'utf-8',
    highWaterMark: 1024  // 每次读 1KB
});

readStream.on('data', (chunk) => {
    console.log('Chunk:', chunk);
});

readStream.on('end', () => {
    console.log('Done reading');
});

readStream.on('error', (err) => {
    console.error('Error:', err);
});
```

### 写入流

```javascript
const writeStream = fs.createWriteStream('output.txt', 'utf-8');

writeStream.write('Line 1\n');
writeStream.write('Line 2\n');
writeStream.end();  // 结束写入

writeStream.on('finish', () => {
    console.log('Done writing');
});

writeStream.on('error', (err) => {
    console.error('Error:', err);
});
```

### 管道（Pipe）

```javascript
// 从读取流管道到写入流
const readStream = fs.createReadStream('input.txt');
const writeStream = fs.createWriteStream('output.txt');

readStream.pipe(writeStream);

// 带转换
const readStream = fs.createReadStream('input.txt', 'utf-8');
const writeStream = fs.createWriteStream('output.txt', 'utf-8');
const transform = new Transform({
    transform(chunk, encoding, callback) {
        callback(null, chunk.toString().toUpperCase());
    }
});

readStream.pipe(transform).pipe(writeStream);
```

### Python 语言对比

```python
# Python 流式读取
with open('large-file.txt', 'r') as f:
    for line in f:
        process(line)

# shutil 复制文件
import shutil
shutil.copyfile('input.txt', 'output.txt')
```

---

## Buffer 操作

### Buffer 基础

```javascript
// 创建 Buffer
const buf1 = Buffer.from('Hello', 'utf-8');
const buf2 = Buffer.from([0x48, 0x65, 0x6c, 0x6c, 0x6f]);
const buf3 = Buffer.alloc(10);  // 分配 10 字节
const buf4 = Buffer.allocUnsafe(10);  // 未初始化

// Buffer 操作
console.log(buf1.toString());           // "Hello"
console.log(buf1.toString('hex'));      // 十六进制
console.log(buf1.length);               // 5
console.log(buf1[0]);                   // 72 (H 的 ASCII 码)

// Buffer 拼接
const combined = Buffer.concat([buf1, buf2]);

// Buffer 拷贝
buf1.copy(buf3, 0, 0, 3);  // 拷贝前 3 字节
```

### Python 语言对比

```python
# Python bytes
buf = b'Hello'
print(buf.decode('utf-8'))  # "Hello"
print(len(buf))             # 5

# bytearray（可变）
mutable = bytearray(b'Hello')
mutable[0] = 65  # 修改
```

---

## 文件和目录管理

### 文件操作

```javascript
// 检查文件是否存在
fs.existsSync('file.txt');
await fsPromises.access('file.txt').then(() => true).catch(() => false);

// 获取文件信息
const stats = fs.statSync('file.txt');
console.log(stats.isFile());      // true
console.log(stats.isDirectory()); // false
console.log(stats.size);          // 文件大小（字节）
console.log(stats.mtime);         // 修改时间

// 重命名/移动
fs.renameSync('old.txt', 'new.txt');
await fsPromises.rename('old.txt', 'new.txt');

// 复制文件
fs.copyFileSync('source.txt', 'dest.txt');
await fsPromises.copyFile('source.txt', 'dest.txt');

// 删除文件
fs.unlinkSync('file.txt');
await fsPromises.unlink('file.txt');
```

### 目录操作

```javascript
// 创建目录
fs.mkdirSync('new-dir');
fs.mkdirSync('nested/dir', { recursive: true });  // 递归创建
await fsPromises.mkdir('new-dir', { recursive: true });

// 列出目录内容
const files = fs.readdirSync('directory');
const filesWithStats = await fsPromises.readdir('directory', { withFileTypes: true });

for (const file of filesWithStats) {
    if (file.isFile()) console.log('File:', file.name);
    if (file.isDirectory()) console.log('Dir:', file.name);
}

// 删除目录
fs.rmdirSync('empty-dir');
await fsPromises.rmdir('empty-dir');

// 递归删除
fs.rmSync('directory', { recursive: true, force: true });
await fsPromises.rm('directory', { recursive: true, force: true });
```

### glob 模式匹配

```javascript
const glob = require('glob');

// 回调方式
glob('**/*.js', (err, files) => {
    console.log('JS files:', files);
});

// Promise 方式
const files = await globPromise('**/*.txt');
```

### Python 语言对比

```python
from pathlib import Path
import shutil

# 文件操作
Path('file.txt').exists()
Path('file.txt').stat().st_size
Path('old.txt').rename('new.txt')
shutil.copy('source.txt', 'dest.txt')
Path('file.txt').unlink()

# 目录操作
Path('new-dir').mkdir()
Path('nested/dir').mkdir(parents=True)
list(Path('.').iterdir())
shutil.rmtree('directory')

# glob
from pathlib import Path
files = list(Path('.').glob('**/*.js'))
```

---

## 序列化

### JSON 处理

```javascript
// 序列化
const data = { name: 'Alice', age: 25 };
const jsonStr = JSON.stringify(data);
const jsonPretty = JSON.stringify(data, null, 2);  // 格式化

// 写入文件
await fsPromises.writeFile('data.json', JSON.stringify(data, null, 2));

// 反序列化
const data = JSON.parse(jsonStr);

// 从文件读取
const fileData = await fsPromises.readFile('data.json', 'utf-8');
const data = JSON.parse(fileData);
```

### Python 语言对比

```python
import json

# 序列化
data = {'name': 'Alice', 'age': 25}
json_str = json.dumps(data)
json_pretty = json.dumps(data, indent=2)

# 写入文件
with open('data.json', 'w') as f:
    json.dump(data, f, indent=2)

# 反序列化
data = json.loads(json_str)

# 从文件读取
with open('data.json', 'r') as f:
    data = json.load(f)
```

---

## Node.js 与 Python 文件操作对比总结

| 操作 | Node.js | Python |
|------|---------|--------|
| 打开文件 | `fs.readFile` | `open()` |
| 关闭文件 | 自动 | `with` / `close()` |
| 读取全部 | `fs.readFile` | `f.read()` |
| 按行读取 | `readline` | `for line in f` |
| 写入 | `fs.writeFile` | `f.write()` |
| 路径操作 | `path` 模块 | `pathlib.Path` |
| 目录列表 | `fs.readdir` | `Path.iterdir()` |
| 文件复制 | `fs.copyFile` | `shutil.copy` |
| JSON | `JSON.parse/stringify` | `json.load/dump` |
| 流式读写 | `createReadStream` | 迭代器 |
