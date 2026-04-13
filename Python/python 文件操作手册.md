# Python 文件操作手册

> 本手册对比 Go 语言，详细介绍 Python 的文件和 I/O 操作

## 目录

1. [文件打开与关闭](#文件打开与关闭)
2. [文件读取](#文件读取)
3. [文件写入](#文件写入)
4. [文件路径操作](#文件路径操作)
5. [文件和目录管理](#文件和目录管理)
6. [序列化](#序列化)
7. [文本与二进制文件](#文本与二进制文件)

---

## 文件打开与关闭

### open() 函数

```python
# 基本用法
file = open("example.txt", "r")
content = file.read()
file.close()

# 推荐：使用 with 语句
with open("example.txt", "r") as file:
    content = file.read()
# 自动关闭文件
```

### Go 语言对比

```go
// Go 使用 defer 关闭
file, err := os.Open("example.txt")
if err != nil {
    return err
}
defer file.Close()

content, err := io.ReadAll(file)
```

### 文件打开模式

| 模式 | 说明 | 文件不存在 |
|------|------|-----------|
| `'r'` | 只读（默认） | 报错 |
| `'w'` | 只写（覆盖） | 创建 |
| `'a'` | 追加 | 创建 |
| `'x'` | 独占创建 | 报错 |
| `'b'` | 二进制模式 | - |
| `'t'` | 文本模式（默认） | - |
| `'+'` | 读写 | - |

```python
# 常见组合
open("file.txt", "r")    # 只读
open("file.txt", "w")    # 写入（覆盖）
open("file.txt", "a")    # 追加
open("file.txt", "r+")   # 读写
open("file.txt", "rb")   # 二进制只读
open("file.txt", "wb")   # 二进制写入
open("file.txt", "x")    # 独占创建
```

### 文件对象属性

```python
with open("example.txt", "r") as f:
    print(f.name)      # 文件名
    print(f.mode)      # 打开模式
    print(f.closed)    # 是否已关闭
    print(f.encoding)  # 编码（文本模式）
```

---

## 文件读取

### 读取整个文件

```python
with open("example.txt", "r", encoding="utf-8") as f:
    content = f.read()      # 读取全部
    content = f.read(100)   # 读取 100 字符
```

### 按行读取

```python
# 读取所有行
with open("example.txt", "r") as f:
    lines = f.readlines()   # 返回列表

# 逐行迭代（推荐，内存高效）
with open("example.txt", "r") as f:
    for line in f:
        print(line.strip())  # strip() 去除换行符

# 读取指定行数
with open("large_file.txt", "r") as f:
    first_10 = [next(f) for _ in range(10)]
```

### Go 语言对比

```go
// Go 读取整个文件
content, err := os.ReadFile("example.txt")

// Go 逐行读取
file, _ := os.Open("example.txt")
defer file.Close()

scanner := bufio.NewScanner(file)
for scanner.Scan() {
    line := scanner.Text()
    fmt.Println(line)
}
```

### 读取二进制文件

```python
with open("image.png", "rb") as f:
    data = f.read()
    header = f.read(8)  # PNG 头 8 字节
```

---

## 文件写入

### 写入文本

```python
# 覆盖写入
with open("output.txt", "w", encoding="utf-8") as f:
    f.write("Hello, World!\n")
    f.write("Second line\n")

# 写入多行
lines = ["Line 1\n", "Line 2\n", "Line 3\n"]
with open("output.txt", "w") as f:
    f.writelines(lines)

# 追加写入
with open("log.txt", "a") as f:
    f.write("New log entry\n")
```

### Go 语言对比

```go
// Go 写入文件
err := os.WriteFile("output.txt", []byte("Hello"), 0644)

// 或使用 writer
file, _ := os.Create("output.txt")
defer file.Close()

file.WriteString("Hello\n")
fmt.Fprintf(file, "Value: %d\n", 42)
```

### 写入二进制

```python
data = bytes([0x89, 0x50, 0x4E, 0x47])  # PNG 签名
with open("output.bin", "wb") as f:
    f.write(data)
```

---

## 文件路径操作

### pathlib 模块（推荐）

```python
from pathlib import Path

# 创建路径对象
p = Path("data") / "subdir" / "file.txt"

# 路径属性
print(p.name)        # file.txt
print(p.stem)        # file
print(p.suffix)      # .txt
print(p.parent)      # data/subdir
print(p.parts)       # ('data', 'subdir', 'file.txt')

# 路径转换
print(p.absolute())  # 绝对路径
print(p.relative_to(Path.cwd()))  # 相对路径
```

### os.path 模块（传统）

```python
import os

# 路径拼接
path = os.path.join("data", "subdir", "file.txt")

# 路径信息
print(os.path.basename(path))  # file.txt
print(os.path.dirname(path))   # data/subdir
print(os.path.splitext(path))  # ('data/subdir/file', '.txt')

# 绝对路径
print(os.path.abspath(path))
print(os.path.realpath(path))  # 解析符号链接
```

### Go 语言对比

```go
import (
    "path/filepath"
    "os"
)

// 路径拼接
path := filepath.Join("data", "subdir", "file.txt")

// 路径信息
dir := filepath.Dir(path)
base := filepath.Base(path)
ext := filepath.Ext(path)

// 绝对路径
abs, _ := filepath.Abs(path)
```

### 常用路径操作

```python
from pathlib import Path

# 检查路径
path = Path("file.txt")
path.exists()     # 是否存在
path.is_file()    # 是否是文件
path.is_dir()     # 是否是目录
path.is_absolute() # 是否是绝对路径

# 创建目录
Path("new_dir").mkdir()
Path("nested/dir").mkdir(parents=True, exist_ok=True)

# 删除
path.unlink()      # 删除文件
path.rmdir()       # 删除空目录
```

---

## 文件和目录管理

### 列出目录内容

```python
from pathlib import Path

# 列出目录
dir_path = Path(".")
for item in dir_path.iterdir():
    print(item.name)

# 带过滤的列表
files = [f for f in dir_path.iterdir() if f.is_file()]
dirs = [d for d in dir_path.iterdir() if d.is_dir()]

# 使用 glob 模式
py_files = list(Path(".").glob("*.py"))
all_files = list(Path(".").rglob("*.txt"))  # 递归
```

### Go 语言对比

```go
// Go 读取目录
entries, _ := os.ReadDir(".")
for _, entry := range entries {
    fmt.Println(entry.Name())
}

// Glob 匹配
files, _ := filepath.Glob("*.py")
```

### 文件操作

```python
from pathlib import Path
import shutil

# 复制文件
shutil.copy("source.txt", "dest.txt")
shutil.copy2("source.txt", "dest.txt")  # 保留元数据

# 移动/重命名
Path("old.txt").rename("new.txt")
shutil.move("source.txt", "dest/")

# 删除
Path("file.txt").unlink()        # 删除文件
shutil.rmtree("directory/")      # 递归删除目录

# 创建副本
shutil.copytree("src/", "backup/")
```

### Go 语言对比

```go
// Go 文件操作
os.Copy("dest.txt", "source.txt")
os.Rename("old.txt", "new.txt")
os.Remove("file.txt")
os.RemoveAll("directory/")
```

### 文件信息

```python
from pathlib import Path
import os

path = Path("file.txt")

# 文件信息
stat = path.stat()
print(stat.st_size)      # 文件大小（字节）
print(stat.st_mtime)     # 修改时间
print(stat.st_ctime)     # 创建时间

# 便捷方法
print(path.stat().st_size)
print(os.path.getsize("file.txt"))
```

### Go 语言对比

```go
// Go 文件信息
info, _ := os.Stat("file.txt")
fmt.Println(info.Size())
fmt.Println(info.ModTime())
fmt.Println(info.Mode())
```

---

## 序列化

### JSON 处理

```python
import json

# 序列化（Python -> JSON）
data = {"name": "Alice", "age": 25, "city": "NYC"}
json_str = json.dumps(data)           # 转为字符串
json_str = json.dumps(data, indent=2) # 格式化

# 写入文件
with open("data.json", "w") as f:
    json.dump(data, f, indent=2)

# 反序列化（JSON -> Python）
data = json.loads(json_str)           # 从字符串

# 从文件读取
with open("data.json", "r") as f:
    data = json.load(f)
```

### Go 语言对比

```go
import "encoding/json"

// 序列化
data := map[string]interface{}{
    "name": "Alice",
    "age":  25,
}
jsonBytes, _ := json.Marshal(data)
jsonStr := string(jsonBytes)

// 格式化
jsonBytes, _ := json.MarshalIndent(data, "", "  ")

// 写入文件
os.WriteFile("data.json", jsonBytes, 0644)

// 反序列化
var result map[string]interface{}
json.Unmarshal(jsonBytes, &result)
```

### pickle 模块（Python 专用）

```python
import pickle

# 序列化
data = {"complex": {"nested": [1, 2, 3]}}
with open("data.pkl", "wb") as f:
    pickle.dump(data, f)

# 反序列化
with open("data.pkl", "rb") as f:
    data = pickle.load(f)

# 注意：pickle 不安全，不要加载不可信的数据
```

### YAML 处理

```python
import yaml

# 需要安装：pip install pyyaml

# 序列化
data = {"name": "Alice", "age": 25}
yaml_str = yaml.dump(data)

with open("data.yaml", "w") as f:
    yaml.dump(data, f)

# 反序列化
data = yaml.safe_load(yaml_str)

with open("data.yaml", "r") as f:
    data = yaml.safe_load(f)
```

### CSV 处理

```python
import csv

# 写入 CSV
with open("data.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Name", "Age", "City"])
    writer.writerow(["Alice", 25, "NYC"])
    writer.writerow(["Bob", 30, "LA"])

# 读取 CSV
with open("data.csv", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)

# 使用 DictWriter/DictReader
with open("data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["Name", "Age"])
    writer.writeheader()
    writer.writerow({"Name": "Alice", "Age": 25})
```

### Go 语言对比

```go
import "encoding/csv"

// Go CSV 读取
file, _ := os.Open("data.csv")
reader := csv.NewReader(file)
records, _ := reader.ReadAll()

// Go CSV 写入
file, _ := os.Create("data.csv")
writer := csv.NewWriter(file)
writer.Write([]string{"Name", "Age"})
writer.Write([]string{"Alice", "25"})
writer.Flush()
```

---

## 文本与二进制文件

### 文本文件

```python
# 自动处理编码和换行符
with open("text.txt", "r", encoding="utf-8") as f:
    content = f.read()

# 指定编码
with open("chinese.txt", "r", encoding="gbk") as f:
    content = f.read()

# 处理编码错误
with open("file.txt", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# errors 参数选项：
# - 'strict': 默认，遇到错误抛出异常
# - 'ignore': 忽略错误
# - 'replace': 用替换字符
# - 'backslashreplace': 使用转义序列
```

### 二进制文件

```python
# 读取二进制
with open("image.png", "rb") as f:
    data = f.read()

# 写入二进制
with open("output.bin", "wb") as f:
    f.write(bytes([0x00, 0x01, 0x02]))

# 使用 bytes 和 bytearray
data = b"binary data"
mutable = bytearray(data)
mutable[0] = 65  # 修改字节
```

### Go 语言对比

```go
// Go 没有文本/二进制的区分
// 所有文件都以二进制方式处理
data, _ := os.ReadFile("file.txt")

// 字符串转换
text := string(data)
data = []byte(text)
```

---

## 标准输入输出

### sys 模块

```python
import sys

# 标准输入
for line in sys.stdin:
    print(f"Input: {line.strip()}")

# 标准输出
sys.stdout.write("Hello\n")
print("Hello")  # 更常用

# 标准错误
sys.stderr.write("Error occurred\n")
print("Error", file=sys.stderr)

# 命令行参数
args = sys.argv  # argv[0] 是脚本名
script_name = sys.argv[0]
first_arg = sys.argv[1] if len(sys.argv) > 1 else None
```

### Go 语言对比

```go
import (
    "os"
    "bufio"
)

// 标准输入
scanner := bufio.NewScanner(os.Stdin)
for scanner.Scan() {
    fmt.Println(scanner.Text())
}

// 标准输出
fmt.Println("Hello")
os.Stdout.WriteString("Hello\n")

// 标准错误
fmt.Fprintln(os.Stderr, "Error")

// 命令行参数
args := os.Args  // args[0] 是程序名
```

### input() 函数

```python
# 简单输入
name = input("Enter your name: ")

# 类型转换
age = int(input("Enter your age: "))

# 多行输入（使用循环）
lines = []
while True:
    line = input()
    if line == "":
        break
    lines.append(line)
```

---

## 高级 I/O

### io 模块

```python
import io

# 字符串缓冲区
buffer = io.StringIO()
buffer.write("Hello ")
buffer.write("World")
content = buffer.getvalue()
buffer.close()

# 字节缓冲区
buffer = io.BytesIO()
buffer.write(b"Binary data")
content = buffer.getvalue()

# 用作文件对象
with io.StringIO("Initial content") as f:
    print(f.read())
```

### Go 语言对比

```go
import "bytes"
import "strings"

// 字节缓冲区
var buf bytes.Buffer
buf.WriteString("Hello ")
buf.WriteString("World")
content := buf.String()

// 字符串读取器
reader := strings.NewReader("content")
```

### 文件对象方法

```python
with open("file.txt", "r+") as f:
    # 文件指针操作
    pos = f.tell()       # 当前位置
    f.seek(0)            # 移到开头
    f.seek(0, 2)         # 移到末尾
    f.seek(10, 0)        # 从开头偏移 10
    
    # 刷新缓冲区
    f.flush()
    
    # 截断文件
    f.truncate(100)      # 截断到 100 字节
```

---

## Python 与 Go 文件操作对比总结

| 操作 | Python | Go |
|------|--------|-----|
| 打开文件 | `open(path, mode)` | `os.Open(path)` |
| 关闭文件 | `with` / `close()` | `defer file.Close()` |
| 读取全部 | `f.read()` | `io.ReadAll(f)` |
| 按行读取 | `for line in f` | `bufio.Scanner` |
| 写入 | `f.write()` | `f.WriteString()` |
| 路径操作 | `pathlib.Path` | `filepath` |
| 目录列表 | `Path.iterdir()` | `os.ReadDir()` |
| 文件复制 | `shutil.copy()` | 手动实现 |
| JSON | `json.dumps/loads` | `json.Marshal/Unmarshal` |
| CSV | `csv.reader/writer` | `encoding/csv` |
