# Node.js 面向对象编程手册

> 本手册对比 Python 语言，详细介绍 Node.js (JavaScript) 的面向对象编程特性

## 目录

1. [类与对象](#类与对象)
2. [构造函数](#构造函数)
3. [实例方法和类方法](#实例方法和类方法)
4. [访问修饰符](#访问修饰符)
5. [继承](#继承)
6. [原型链](#原型链)
7. [this 绑定](#this-绑定)
8. [Getter/Setter](#gettersetter)
9. [静态成员](#静态成员)

---

## 类与对象

### 类的定义（ES6+）

```javascript
class Person {
    // 构造函数
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
    
    // 实例方法
    introduce() {
        return `Hi, I'm ${this.name}, ${this.age} years old`;
    }
    
    // 方法可以简写
    greet(greeting = "Hello") {
        return `${greeting}, ${this.name}!`;
    }
}

// 创建对象
const person1 = new Person("Alice", 25);
const person2 = new Person("Bob", 30);

console.log(person1.introduce());  // Hi, I'm Alice, 25 years old
console.log(person2.greet("Hi"));  // Hi, Bob!
```

### Python 语言对比

```python
class Person:
    # 类属性（所有实例共享）
    species = "Homo sapiens"
    
    def __init__(self, name, age):
        # 实例属性
        self.name = name
        self.age = age
    
    def introduce(self):
        return f"Hi, I'm {self.name}, {self.age} years old"

# 创建对象
person1 = Person("Alice", 25)
person2 = Person("Bob", 30)
```

### 类属性

```javascript
class Person {
    // 静态属性（类属性）
    static species = "Homo sapiens";
    static count = 0;
    
    constructor(name, age) {
        this.name = name;
        this.age = age;
        Person.count++;
    }
}

console.log(Person.species);  // "Homo sapiens"
console.log(Person.count);    // 已创建的对象数
```

---

## 构造函数

### constructor 方法

```javascript
class Rectangle {
    constructor(width = 1, height = 1) {
        this.width = width;
        this.height = height;
    }
    
    area() {
        return this.width * this.height;
    }
}

// 多种创建方式
const r1 = new Rectangle();           // 1x1
const r2 = new Rectangle(5);          // 5x1
const r3 = new Rectangle(5, 10);      // 5x10
```

### 工厂方法（替代构造函数）

```javascript
class Date {
    constructor(year, month, day) {
        this.year = year;
        this.month = month;
        this.day = day;
    }
    
    // 静态工厂方法
    static fromString(dateStr) {
        const [year, month, day] = dateStr.split('-').map(Number);
        return new Date(year, month, day);
    }
    
    static today() {
        const now = new global.Date();
        return new Date(now.getFullYear(), now.getMonth() + 1, now.getDate());
    }
}

const d1 = Date.fromString("2024-01-15");
const d2 = Date.today();
```

### Python 语言对比

```python
# Python 使用 @classmethod 作为替代构造函数
class Date:
    def __init__(self, year, month, day):
        self.year = year
        self.month = month
        self.day = day
    
    @classmethod
    def from_string(cls, date_str):
        year, month, day = map(int, date_str.split('-'))
        return cls(year, month, day)
    
    @classmethod
    def today(cls):
        import datetime
        today = datetime.date.today()
        return cls(today.year, today.month, today.day)
```

---

## 实例方法和类方法

### 方法类型

```javascript
class MyClass {
    static classVar = "class";
    
    constructor(value) {
        this.value = value;
    }
    
    // 实例方法
    instanceMethod() {
        return `Instance: ${this.value}`;
    }
    
    // 类方法（静态方法）
    static classMethod() {
        return `Class: ${this.classVar}`;
    }
    
    // 静态工具方法
    static staticMethod(x, y) {
        return x + y;
    }
}

// 调用
const obj = new MyClass("test");
console.log(obj.instanceMethod());   // Instance: test
console.log(MyClass.classMethod());  // Class: class
console.log(MyClass.staticMethod(1, 2));  // 3
```

### Python 语言对比

```python
class MyClass:
    class_var = "class"
    
    def __init__(self, value):
        self.value = value
    
    def instance_method(self):
        return f"Instance: {self.value}"
    
    @classmethod
    def class_method(cls):
        return f"Class: {cls.class_var}"
    
    @staticmethod
    def static_method(x, y):
        return x + y
```

---

## 访问修饰符

### 公共、受保护和私有属性

```javascript
class MyClass {
    constructor() {
        this.public = "public";       // 公有
        this._protected = "protected"; // 受保护（约定）
        this.#private = "private";    // 私有（ES2022）
    }
    
    // 私有字段（ES2022）
    #private = "private";
    
    // 访问私有字段
    getPrivate() {
        return this.#private;
    }
}

const obj = new MyClass();
console.log(obj.public);      // 可以访问
console.log(obj._protected);  // 可以访问（但约定不应该）
// console.log(obj.#private); // SyntaxError!
```

### Python 语言对比

```python
class MyClass:
    def __init__(self):
        self.public = "public"      # 公有
        self._protected = "protected"  # 受保护（约定）
        self.__private = "private"     # 私有（名称修饰）

obj = MyClass()
obj.public         # 可以访问
obj._protected     # 可以访问（但约定不应该）
# obj.__private    # AttributeError!
```

---

## 继承

### 单继承

```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    
    speak() {
        return "Some sound";
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);  // 调用父类构造函数
        this.breed = breed;
    }
    
    // 重写父类方法
    speak() {
        return "Woof!";
    }
    
    // 新增方法
    fetch() {
        return `${this.name} is fetching`;
    }
}

class Cat extends Animal {
    speak() {
        return "Meow!";
    }
}

const dog = new Dog("Buddy", "Golden");
const cat = new Cat("Whiskers");

console.log(dog.speak());  // Woof!
console.log(cat.speak());  // Meow!
console.log(dog.fetch());  // Buddy is fetching
```

### Python 语言对比

```python
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        return "Some sound"

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)
        self.breed = breed
    
    def speak(self):
        return "Woof!"

class Cat(Animal):
    def speak(self):
        return "Meow!"
```

### super() 用法

```javascript
class Parent {
    constructor(name) {
        this.name = name;
    }
    
    greet() {
        return `Hello from ${this.name}`;
    }
}

class Child extends Parent {
    constructor(name, age) {
        super(name);
        this.age = age;
    }
    
    greet() {
        const parentGreeting = super.greet();
        return `${parentGreeting}, I'm ${this.age} years old`;
    }
}

const child = new Child("Alice", 10);
console.log(child.greet());  // Hello from Alice, I'm 10 years old
```

---

## 原型链

### 原型基础

```javascript
// ES5 原型语法（了解）
function Person(name) {
    this.name = name;
}

Person.prototype.introduce = function() {
    return `I'm ${this.name}`;
};

// ES6 class 语法（推荐）
class Person2 {
    constructor(name) {
        this.name = name;
    }
    
    introduce() {
        return `I'm ${this.name}`;
    }
}

// 原型链
console.log(Person2.prototype);
console.log({}.__proto__ === Object.prototype);  // true
console.log([] instanceof Array);  // true
```

### Python 语言对比

```python
# Python 使用 __class__ 和 MRO
class Person:
    pass

p = Person()
print(p.__class__)
print(Person.__mro__)  # 方法解析顺序
```

---

## this 绑定

### this 的四种绑定方式

```javascript
// 1. 默认绑定（独立函数调用）
function greet() {
    console.log(this.name);
}
const name = "Global";
greet();  // "Global" (浏览器) 或 undefined (Node.js strict mode)

// 2. 隐式绑定（作为对象方法调用）
const obj = {
    name: "Alice",
    greet: function() {
        console.log(this.name);
    }
};
obj.greet();  // "Alice"

// 3. 显式绑定（call/apply/bind）
function introduce(greeting) {
    console.log(`${greeting}, I'm ${this.name}`);
}

const person = { name: "Bob" };
introduce.call(person, "Hello");     // Hello, I'm Bob
introduce.apply(person, ["Hello"]);  // Hello, I'm Bob

const boundGreet = introduce.bind(person);
boundGreet("Hi");  // Hi, I'm Bob

// 4. new 绑定（构造函数调用）
function Person(name) {
    this.name = name;
}
const p = new Person("Charlie");

// 箭头函数的 this（词法绑定）
const obj2 = {
    name: "Alice",
    friends: ["Bob", "Charlie"],
    greetFriends() {
        this.friends.forEach(friend => {
            // 箭头函数的 this 继承自外层
            console.log(`${this.name} greets ${friend}`);
        });
    }
};
obj2.greetFriends();
```

### Python 语言对比

```python
# Python 需要显式 self 参数
class Person:
    def __init__(self, name):
        self.name = name
    
    def greet(self):  # self 必须作为第一个参数
        print(f"Hello, I'm {self.name}")
```

---

## Getter/Setter

### 属性访问器

```javascript
class Person {
    constructor(name, age) {
        this._name = name;
        this._age = age;
    }
    
    // Getter
    get name() {
        return this._name;
    }
    
    // Setter
    set name(value) {
        if (!value) {
            throw new Error("Name cannot be empty");
        }
        this._name = value;
    }
    
    get age() {
        return this._age;
    }
    
    set age(value) {
        if (value < 0 || value > 150) {
            throw new Error("Invalid age");
        }
        this._age = value;
    }
    
    // 计算属性
    get info() {
        return `${this._name}, ${this._age} years old`;
    }
}

const person = new Person("Alice", 25);
console.log(person.name);  // "Alice" (调用 getter)
person.age = 26;           // 调用 setter
console.log(person.info);  // "Alice, 26 years old"
```

### Python 语言对比

```python
class Person:
    def __init__(self, name, age):
        self._name = name
        self._age = age
    
    @property
    def name(self):
        return self._name
    
    @name.setter
    def name(self, value):
        if not value:
            raise ValueError("Name cannot be empty")
        self._name = value
    
    @property
    def age(self):
        return self._age
    
    @age.setter
    def age(self, value):
        if value < 0 or value > 150:
            raise ValueError("Invalid age")
        self._age = value
```

---

## 静态成员

### 静态方法和属性

```javascript
class MathUtils {
    static PI = 3.14159;
    
    static add(a, b) {
        return a + b;
    }
    
    static multiply(a, b) {
        return a * b;
    }
    
    // 静态方法可以调用其他静态方法
    static calculate(a, b) {
        return this.add(a, b) * this.PI;
    }
}

console.log(MathUtils.PI);           // 3.14159
console.log(MathUtils.add(2, 3));    // 5
console.log(MathUtils.calculate(2, 3));  // 15.70795
```

### Python 语言对比

```python
class MathUtils:
    PI = 3.14159
    
    @staticmethod
    def add(a, b):
        return a + b
    
    @staticmethod
    def multiply(a, b):
        return a * b
```

---

## JavaScript 与 Python OOP 对比总结

| 特性 | JavaScript (Node.js) | Python |
|------|---------------------|--------|
| 类定义 | `class Name {}` | `class Name:` |
| 构造函数 | `constructor()` | `__init__()` |
| 继承 | `extends` | 类名后加父类 |
| 调用父类 | `super()` | `super()` |
| 方法接收者 | `this` | `self` (显式) |
| 访问控制 | `#private`, `_protected` | `_protected`, `__private` |
| 属性访问器 | `get`/`set` | `@property` |
| 静态成员 | `static` 关键字 | `@staticmethod`, `@classmethod` |
| 多继承 | 不支持 | 支持 |
| 接口/抽象类 | 不支持（用 TypeScript） | ABC 模块 |
| 数据类 | 需要手动定义 | `@dataclass` |
