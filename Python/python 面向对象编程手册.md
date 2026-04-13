# Python 面向对象编程手册

> 本手册对比 Go 语言，详细介绍 Python 的面向对象编程特性

## 目录

1. [类与对象](#类与对象)
2. [构造函数](#构造函数)
3. [实例方法和类方法](#实例方法和类方法)
4. [属性访问控制](#属性访问控制)
5. [继承](#继承)
6. [多态](#多态)
7. [特殊方法](#特殊方法)
8. [属性装饰器](#属性装饰器)
9. [抽象基类](#抽象基类)
10. [组合与Mixin](#组合与 mixin)

---

## 类与对象

### 类的定义

```python
class Person:
    """Person 类示例"""
    
    # 类属性（所有实例共享）
    species = "Homo sapiens"
    
    def __init__(self, name, age):
        # 实例属性
        self.name = name
        self.age = age
    
    def introduce(self):
        """实例方法"""
        return f"Hi, I'm {self.name}, {self.age} years old"

# 创建对象
person1 = Person("Alice", 25)
person2 = Person("Bob", 30)

print(person1.introduce())  # Hi, I'm Alice, 25 years old
print(Person.species)       # Homo sapiens
```

### Go 语言对比

```go
// Go 使用 struct + 方法
type Person struct {
    Name string
    Age  int
}

// 类属性需要用包级别变量或特殊模式
var Species = "Homo sapiens"

// 方法定义（接收者）
func (p Person) Introduce() string {
    return fmt.Sprintf("Hi, I'm %s, %d years old", p.Name, p.Age)
}

// 创建对象
person1 := Person{"Alice", 25}
person2 := Person{Name: "Bob", Age: 30}
```

### 动态属性

```python
# Python 可以动态添加属性
person = Person("Alice", 25)
person.email = "alice@example.com"  # 动态添加

# __dict__ 查看实例属性
print(person.__dict__)  # {'name': 'Alice', 'age': 25, 'email': 'alice@example.com'}
```

### Go 语言对比

```go
// Go 是静态类型，不能动态添加字段
// 可以使用 map 实现类似功能
type FlexiblePerson struct {
    Name string
    Data map[string]interface{}
}
```

---

## 构造函数

### `__init__` 方法

```python
class Rectangle:
    def __init__(self, width=1, height=1):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height

# 多种创建方式
r1 = Rectangle()           # 1x1
r2 = Rectangle(5)          # 5x1
r3 = Rectangle(5, 10)      # 5x10
r4 = Rectangle(height=10, width=5)  # 关键字参数
```

### 类方法作为替代构造函数

```python
class Date:
    def __init__(self, year, month, day):
        self.year = year
        self.month = month
        self.day = day
    
    @classmethod
    def from_string(cls, date_str):
        """从字符串创建日期"""
        year, month, day = map(int, date_str.split('-'))
        return cls(year, month, day)
    
    @classmethod
    def today(cls):
        """创建今天的日期"""
        import datetime
        today = datetime.date.today()
        return cls(today.year, today.month, today.day)

# 使用
d1 = Date(2024, 1, 15)
d2 = Date.from_string("2024-01-15")
d3 = Date.today()
```

### Go 语言对比

```go
// Go 没有构造函数，使用 New 函数模式
type Rectangle struct {
    Width  float64
    Height float64
}

func NewRectangle(width, height float64) *Rectangle {
    return &Rectangle{Width: width, Height: height}
}

// 替代构造函数
func NewRectangleFromArea(area, ratio float64) *Rectangle {
    height := math.Sqrt(area / ratio)
    return &Rectangle{Width: height * ratio, Height: height}
}
```

---

## 实例方法和类方法

### 方法类型

```python
class MyClass:
    class_var = "class"
    
    def __init__(self, value):
        self.value = value
    
    # 实例方法（需要 self）
    def instance_method(self):
        return f"Instance: {self.value}"
    
    # 类方法（需要 cls，使用 @classmethod）
    @classmethod
    def class_method(cls):
        return f"Class: {cls.class_var}"
    
    # 静态方法（不需要 self 或 cls，使用 @staticmethod）
    @staticmethod
    def static_method(x, y):
        return x + y

# 调用
obj = MyClass("test")
print(obj.instance_method())   # Instance: test
print(MyClass.class_method())  # Class: class
print(MyClass.static_method(1, 2))  # 3
```

### Go 语言对比

```go
type MyClass struct {
    Value string
}

var classVar = "class"

// 实例方法（值接收者）
func (m MyClass) InstanceMethod() string {
    return fmt.Sprintf("Instance: %s", m.Value)
}

// 类方法（Go 没有直接的等价物，使用包函数）
func ClassMethod() string {
    return fmt.Sprintf("Class: %s", classVar)
}

// 静态方法（包级别函数）
func StaticMethod(x, y int) int {
    return x + y
}
```

---

## 属性访问控制

### 公有、受保护和私有属性

```python
class MyClass:
    def __init__(self):
        self.public = "public"      # 公有
        self._protected = "protected"  # 受保护（约定）
        self.__private = "private"     # 私有（名称修饰）
    
    def get_private(self):
        return self.__private

obj = MyClass()
print(obj.public)        # 可以访问
print(obj._protected)    # 可以访问（但约定不应该）
# print(obj.__private)   # AttributeError!

# 私有属性通过名称修饰可以访问
print(obj._MyClass__private)  # 可以，但不推荐
```

### Go 语言对比

```go
// Go 使用大小写控制可见性
type MyClass struct {
    Public    string  // 大写=导出（公有）
    protected string  // 小写=未导出（私有，包内可见）
}

// 包外只能访问大写字段
```

### property 装饰器

```python
class Person:
    def __init__(self, name, age):
        self._name = name
        self._age = age
    
    @property
    def name(self):
        """获取 name"""
        return self._name
    
    @name.setter
    def name(self, value):
        """设置 name"""
        if not value:
            raise ValueError("Name cannot be empty")
        self._name = value
    
    @property
    def age(self):
        """获取 age"""
        return self._age
    
    @age.setter
    def age(self, value):
        """设置 age"""
        if value < 0 or value > 150:
            raise ValueError("Invalid age")
        self._age = value

# 使用
person = Person("Alice", 25)
print(person.name)  # 像属性一样访问
person.age = 26     # 像属性一样设置
```

### Go 语言对比

```go
// Go 使用 getter/setter 方法
type Person struct {
    name string
    age  int
}

func (p *Person) Name() string {
    return p.name
}

func (p *Person) SetName(name string) error {
    if name == "" {
        return fmt.Errorf("name cannot be empty")
    }
    p.name = name
    return nil
}
```

---

## 继承

### 单继承

```python
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        return "Some sound"

class Dog(Animal):
    def speak(self):
        return "Woof!"

class Cat(Animal):
    def speak(self):
        return "Meow!"

dog = Dog("Buddy")
cat = Cat("Whiskers")

print(dog.speak())  # Woof!
print(cat.speak())  # Meow!
```

### 多继承

```python
class Flyable:
    def fly(self):
        return "Flying!"

class Swimmable:
    def swim(self):
        return "Swimming!"

class Duck(Flyable, Swimmable):
    def quack(self):
        return "Quack!"

duck = Duck()
print(duck.fly())   # Flying!
print(duck.swim())  # Swimming!
print(duck.quack()) # Quack!
```

### Go 语言对比

```go
// Go 没有继承，使用组合
type Animal struct {
    Name string
}

func (a Animal) Speak() string {
    return "Some sound"
}

type Dog struct {
    Animal  // 嵌入（类似继承）
}

func (d Dog) Speak() string {
    return "Woof!"  // 重写
}

// 接口实现多态
type Speaker interface {
    Speak() string
}
```

### super() 函数

```python
class Parent:
    def __init__(self, name):
        self.name = name
    
    def greet(self):
        return f"Hello from {self.name}"

class Child(Parent):
    def __init__(self, name, age):
        super().__init__(name)  # 调用父类构造函数
        self.age = age
    
    def greet(self):
        parent_greeting = super().greet()
        return f"{parent_greeting}, I'm {self.age} years old"

child = Child("Alice", 10)
print(child.greet())  # Hello from Alice, I'm 10 years old
```

### Go 语言对比

```go
// Go 组合中可以调用嵌入类型的方法
type Parent struct {
    Name string
}

func (p Parent) Greet() string {
    return fmt.Sprintf("Hello from %s", p.Name)
}

type Child struct {
    Parent
    Age int
}

func (c Child) Greet() string {
    return fmt.Sprintf("%s, I'm %d years old", c.Parent.Greet(), c.Age)
}
```

### 方法解析顺序 (MRO)

```python
# 查看 MRO
print(Duck.__mro__)
# (<class '__main__.Duck'>, <class '__main__.Flyable'>, 
#  <class '__main__.Swimmable'>, <class 'object'>)

# 或使用 mro() 方法
print(Duck.mro())
```

---

## 多态

### 鸭子类型

```python
class Duck:
    def speak(self):
        return "Quack!"

class Person:
    def speak(self):
        return "Hello!"

def make_speak(entity):
    """不关心类型，只要有 speak 方法"""
    return entity.speak()

print(make_speak(Duck()))   # Quack!
print(make_speak(Person())) # Hello!
```

### Go 语言对比

```go
// Go 使用接口实现多态
type Speaker interface {
    Speak() string
}

type Duck struct{}
func (d Duck) Speak() string { return "Quack!" }

type Person struct{}
func (p Person) Speak() string { return "Hello!" }

func MakeSpeak(s Speaker) string {
    return s.Speak()
}
```

### isinstance 和类型检查

```python
class Animal:
    pass

class Dog(Animal):
    pass

dog = Dog()

print(isinstance(dog, Dog))    # True
print(isinstance(dog, Animal)) # True
print(issubclass(Dog, Animal)) # True
```

---

## 特殊方法（魔术方法）

### 字符串表示

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def __str__(self):
        """用户友好的字符串表示"""
        return f"Person({self.name}, {self.age})"
    
    def __repr__(self):
        """开发者友好的表示，用于调试"""
        return f"Person('{self.name}', {self.age})"

person = Person("Alice", 25)
print(str(person))   # Person(Alice, 25)
print(repr(person))  # Person('Alice', 25)
```

### Go 语言对比

```go
// Go 实现 String() 方法满足 fmt.Stringer 接口
type Person struct {
    Name string
    Age  int
}

func (p Person) String() string {
    return fmt.Sprintf("Person(%s, %d)", p.Name, p.Age)
}
```

### 数值运算方法

```python
class Vector:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, other):
        """v1 + v2"""
        return Vector(self.x + other.x, self.y + other.y)
    
    def __sub__(self, other):
        """v1 - v2"""
        return Vector(self.x - other.x, self.y - other.y)
    
    def __mul__(self, scalar):
        """v * scalar"""
        return Vector(self.x * scalar, self.y * scalar)
    
    def __eq__(self, other):
        """v1 == v2"""
        return self.x == other.x and self.y == other.y
    
    def __neg__(self):
        """-v"""
        return Vector(-self.x, -self.y)
    
    def __len__(self):
        """len(v)"""
        return int(math.sqrt(self.x**2 + self.y**2))

v1 = Vector(1, 2)
v2 = Vector(3, 4)
print(v1 + v2)  # Vector(4, 6)
print(v1 * 3)   # Vector(3, 6)
```

### 容器方法

```python
class MyList:
    def __init__(self, items):
        self._items = items
    
    def __len__(self):
        return len(self._items)
    
    def __getitem__(self, index):
        return self._items[index]
    
    def __setitem__(self, index, value):
        self._items[index] = value
    
    def __delitem__(self, index):
        del self._items[index]
    
    def __contains__(self, item):
        return item in self._items
    
    def __iter__(self):
        return iter(self._items)

ml = MyList([1, 2, 3])
print(len(ml))        # 3
print(ml[0])          # 1
print(2 in ml)        # True
```

### 上下文管理器方法

```python
class FileManager:
    def __init__(self, filename, mode):
        self.filename = filename
        self.mode = mode
        self.file = None
    
    def __enter__(self):
        self.file = open(self.filename, self.mode)
        return self.file
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.file.close()
        return False  # 不抑制异常

with FileManager("test.txt", "w") as f:
    f.write("Hello")
```

### 常用特殊方法一览表

| 方法 | 用途 | 示例 |
|------|------|------|
| `__str__` | 字符串表示（用户） | `str(obj)` |
| `__repr__` | 字符串表示（开发者） | `repr(obj)` |
| `__len__` | 长度 | `len(obj)` |
| `__getitem__` | 索引访问 | `obj[key]` |
| `__setitem__` | 索引赋值 | `obj[key] = value` |
| `__delitem__` | 删除索引 | `del obj[key]` |
| `__contains__` | 成员检查 | `key in obj` |
| `__iter__` | 迭代器 | `for x in obj` |
| `__next__` | 下一个元素 | `next(iterator)` |
| `__call__` | 调用对象 | `obj()` |
| `__enter__` | 进入上下文 | `with obj:` |
| `__exit__` | 退出上下文 | `with obj:` |
| `__add__` | 加法 | `a + b` |
| `__sub__` | 减法 | `a - b` |
| `__mul__` | 乘法 | `a * b` |
| `__truediv__` | 除法 | `a / b` |
| `__eq__` | 等于 | `a == b` |
| `__lt__` | 小于 | `a < b` |

---

## 属性装饰器

```python
class Circle:
    def __init__(self, radius):
        self._radius = radius
    
    @property
    def radius(self):
        """只读属性"""
        return self._radius
    
    @property
    def diameter(self):
        """计算属性"""
        return self._radius * 2
    
    @property
    def area(self):
        """计算属性"""
        return math.pi * self._radius ** 2

circle = Circle(5)
print(circle.radius)   # 5
print(circle.diameter) # 10
print(circle.area)     # 78.54...
```

---

## 抽象基类

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass
    
    @abstractmethod
    def perimeter(self):
        pass
    
    def describe(self):
        return "I am a shape"

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height
    
    def perimeter(self):
        return 2 * (self.width + self.height)

# shape = Shape()  # TypeError! 不能实例化抽象类
rect = Rectangle(5, 10)
print(rect.describe())  # I am a shape
```

### Go 语言对比

```go
// Go 使用接口实现类似功能
type Shape interface {
    Area() float64
    Perimeter() float64
}

type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r Rectangle) Perimeter() float64 {
    return 2 * (r.Width + r.Height)
}
```

---

## 组合与 Mixin

### 组合优于继承

```python
class Engine:
    def start(self):
        return "Engine started"
    
    def stop(self):
        return "Engine stopped"

class Car:
    def __init__(self):
        self.engine = Engine()  # 组合
    
    def start(self):
        return self.engine.start()

car = Car()
print(car.start())  # Engine started
```

### Mixin 模式

```python
class JSONMixin:
    def to_json(self):
        import json
        return json.dumps(self.__dict__)

class LoggingMixin:
    def log(self, message):
        print(f"[{self.__class__.__name__}] {message}")

class Person(JSONMixin, LoggingMixin):
    def __init__(self, name, age):
        self.name = name
        self.age = age

person = Person("Alice", 25)
print(person.to_json())  # {"name": "Alice", "age": 25}
person.log("Created")    # [Person] Created
```

---

## 数据类（Python 3.7+）

```python
from dataclasses import dataclass, field

@dataclass
class Point:
    x: float
    y: float
    label: str = "origin"
    tags: list = field(default_factory=list)

p1 = Point(1, 2)
p2 = Point(1, 2)
print(p1 == p2)  # True (自动生成 __eq__)
print(p1)        # Point(x=1, y=2, label='origin')
```

### Go 语言对比

```go
// Go 的 struct 类似但需要手动实现方法
type Point struct {
    X     float64
    Y     float64
    Label string
    Tags  []string
}
```

---

## Python 与 Go OOP 对比总结

| 特性 | Python | Go |
|------|--------|-----|
| 类定义 | `class Name:` | `type Name struct` |
| 构造函数 | `__init__` | `NewName()` 函数 |
| 方法接收者 | `self` | `(r Receiver)` |
| 继承 | 支持（单/多） | 不支持（用组合） |
| 接口 | 隐式（ABC） | 显式（interface） |
| 访问控制 | 命名约定 | 大小写 |
| 属性访问 | `@property` | getter/setter |
| 特殊方法 | 丰富 | 有限 |
| 泛型 | 动态/TypeVar | 泛型（1.18+） |
| 数据类 | `@dataclass` | 手动定义 |
