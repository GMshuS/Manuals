# 第6章 TypeScript 面向对象编程手册

> 本手册详细介绍 TypeScript 的面向对象编程特性

## 目录

1. [类定义](#类定义)
2. [访问修饰符](#访问修饰符)
3. [接口实现](#接口实现)
4. [继承](#继承)
5. [抽象类与抽象方法](#抽象类与抽象方法)
6. [静态成员](#静态成员)
7. [Getter/Setter](#gettersetter)
8. [this 关键字](#this-关键字)
9. [混入 (Mixin)](#混入-mixin)
10. [装饰器](#装饰器)

---

## 类定义

### 基本类语法

```typescript
class Person {
  // 属性声明
  name: string;
  age: number;

  // 构造函数
  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }

  // 实例方法
  greet(): string {
    return `Hello, I'm ${this.name}`;
  }

  // 方法重载
  describe(): string;
  describe(detail: boolean): string;
  describe(detail?: boolean): string {
    if (detail) {
      return `${this.name} (${this.age} years old)`;
    }
    return this.name;
  }
}

const alice = new Person("Alice", 30);
console.log(alice.greet());  // "Hello, I'm Alice"
```

### 参数属性（简化声明）

```typescript
// TypeScript 的简写语法：在构造函数参数前加修饰符
class Person2 {
  constructor(
    public name: string,
    public readonly age: number,
    private ssn?: string
  ) {}

  greet(): string {
    return `Hello, I'm ${this.name}`;
  }
}

// 等价于：
class Person3 {
  public name: string;
  public readonly age: number;
  private ssn?: string;

  constructor(name: string, age: number, ssn?: string) {
    this.name = name;
    this.age = age;
    this.ssn = ssn;
  }
}
```

---

## 访问修饰符

### TypeScript 修饰符

| 修饰符 | 类内部 | 子类 | 外部 | Python 对应 |
|--------|--------|------|------|-------------|
| `public` | ✅ | ✅ | ✅ | 默认（无下划线） |
| `protected` | ✅ | ✅ | ❌ | `_`（单下划线，约定） |
| `private` | ✅ | ❌ | ❌ | `__`（名称修饰，严格） |
| `readonly` | ✅ 读 | ✅ 读 | ✅ 读 | `@property`（只读） |

```typescript
class Animal {
  public name: string;        // 公开（默认）
  protected age: number;      // 类内和子类可访问
  private dna: string;        // 仅类内可访问
  readonly species: string;   // 只读

  constructor(name: string, age: number, species: string) {
    this.name = name;
    this.age = age;
    this.dna = "secret";
    this.species = species;
  }

  public speak(): string {
    return `${this.name} makes a sound`;
  }

  protected getAge(): number {
    return this.age;
  }

  private getDna(): string {
    return this.dna;
  }
}

class Dog extends Animal {
  constructor(name: string, age: number) {
    super(name, age, "Canine");
  }

  public showAge(): number {
    return this.getAge();  // OK: protected 可访问
  }

  // public showDna(): string {
  //   return this.getDna();  // Error: private 不可访问
  // }
}

const dog = new Dog("Rex", 3);
console.log(dog.name);       // OK: public
// console.log(dog.age);     // Error: protected
// console.log(dog.dna);     // Error: private
// dog.species = "Feline";  // Error: readonly
```

### 最新 private 语法（#）

```typescript
// ECMAScript 原生私有字段（# 前缀）
class Counter {
  #count = 0;  // 原生私有字段（真正不可访问）

  increment(): void {
    this.#count++;
  }

  get value(): number {
    return this.#count;
  }
}

const c = new Counter();
c.increment();
// console.log(c.#count);  // SyntaxError: 编译和运行时都不可访问
```

---

## 接口实现

### implements 关键字

```typescript
interface Flyable {
  fly(): string;
  land(): void;
}

interface Swimmable {
  swim(): string;
}

class Duck implements Flyable, Swimmable {
  fly(): string {
    return "Duck is flying";
  }

  land(): void {
    console.log("Duck lands");
  }

  swim(): string {
    return "Duck is swimming";
  }
}

// 多接口实现
class FlyingFish implements Flyable, Swimmable {
  fly(): string {
    return "Flying fish glides";
  }

  land(): void {
    console.log("Flying fish returns to water");
  }

  swim(): string {
    return "Flying fish swims";
  }
}
```

### 接口与类的区别

```typescript
interface Point {
  x: number;
  y: number;
}

// 类实现接口必须实现所有成员
class Point3D implements Point {
  constructor(
    public x: number,
    public y: number,
    public z: number  // 额外的成员 OK
  ) {}
}

// 接口可以继承类（提取类结构）
class RealPoint {
  constructor(public x: number, public y: number) {}
}

interface PointInterface extends RealPoint {
  z: number;
}

const p: PointInterface = { x: 1, y: 2, z: 3 };
```


    
    def land(self) -> None:
        print("Duck lands")
    
    def swim(self) -> str:
        return "Duck is swimming"

# Duck 自动满足 Flyable 和 Swimmable 协议
```

---

## 继承

### extends 关键字

```typescript
class Vehicle {
  constructor(
    public brand: string,
    public year: number
  ) {}

  start(): string {
    return `${this.brand} starts`;
  }

  getAge(currentYear: number = 2024): number {
    return currentYear - this.year;
  }
}

class Car extends Vehicle {
  constructor(
    brand: string,
    year: number,
    public doors: number  // 新增属性
  ) {
    super(brand, year);  // 必须调用父类构造器
  }

  // 方法重写
  start(): string {
    return `${super.start()} with ${this.doors} doors`;
  }

  // 新增方法
  honk(): string {
    return "Beep beep!";
  }
}

const car = new Car("Toyota", 2020, 4);
console.log(car.start());    // "Toyota starts with 4 doors"
console.log(car.honk());     // "Beep beep!"
console.log(car.getAge());   // 4
```

### 重写与多态

```typescript
// 使用 override 关键字（TypeScript 5.0+）
class Base {
  greet(): string {
    return "Hello";
  }
}

class Derived extends Base {
  override greet(): string {
    return "Hi";
  }
  
  // override greet2(): string {  // Error: 没有要重写的方法
  //   return "Hey";
  // }
}

// 多态
const vehicles: Vehicle[] = [
  new Vehicle("Generic", 2020),
  new Car("Honda", 2022, 2),
];

vehicles.forEach(v => {
  console.log(v.start());  // 运行时根据实际类型调用
});

// 使用 instanceof 检查
if (car instanceof Car) {
  console.log(car.honk());  // 类型收窄后可用 Car 的方法
}
```

---

## 抽象类与抽象方法

### abstract 关键字

```typescript
abstract class Shape {
  // 抽象属性
  abstract name: string;

  // 抽象方法（子类必须实现）
  abstract area(): number;

  // 具体方法（可选重写）
  describe(): string {
    return `${this.name} with area ${this.area()}`;
  }
}

class Circle extends Shape {
  name = "Circle";

  constructor(private radius: number) {
    super();
  }

  area(): number {
    return Math.PI * this.radius ** 2;
  }
}

class Square extends Shape {
  name = "Square";

  constructor(private side: number) {
    super();
  }

  area(): number {
    return this.side ** 2;
  }
}

// const shape = new Shape();  // Error: 抽象类不能实例化

const shapes: Shape[] = [new Circle(5), new Square(4)];
shapes.forEach(s => console.log(s.describe()));
```

### 抽象类 vs 接口

| 特征 | 抽象类 | 接口 |
|------|--------|------|
| 实例化 | ❌ | ❌ |
| 实现方法 | ✅ 可以有实现 | ❌（TypeScript 接口无实现） |
| 属性 | ✅ | ✅ |
| 构造函数 | ✅ | ❌ |
| 访问修饰符 | ✅ | ❌ |
| 多继承 | ❌（单继承） | ✅（多接口） |

---

## 静态成员

### static 关键字

```typescript
class MathUtils {
  // 静态属性
  static PI = 3.14159;
  static E = 2.71828;

  // 静态方法
  static add(a: number, b: number): number {
    return a + b;
  }

  static max(arr: number[]): number {
    return Math.max(...arr);
  }

  // 静态代码块（TypeScript 5.0+ / ES2022）
  static {
    console.log("MathUtils loaded");
  }

  // 非静态方法不能直接访问静态成员
  instanceMethod(): void {
    console.log(MathUtils.PI);  // 通过类名访问
    console.log(this.constructor);  // 另一种方式
  }
}

// 通过类名访问
console.log(MathUtils.PI);      // 3.14159
console.log(MathUtils.add(2, 3));  // 5

// 静态工厂方法
class UserFactory {
  static createAdmin(name: string): User {
    return new User(name, "admin");
  }

  static createGuest(): User {
    return new User("Guest", "guest");
  }
}

const admin = UserFactory.createAdmin("Alice");
```

### 静态成员继承

```typescript
class Parent {
  static type = "Parent";
  static getType(): string {
    return this.type;  // this 指向当前类
  }
}

class Child extends Parent {
  static type = "Child";
}

console.log(Parent.getType());  // "Parent"
console.log(Child.getType());   // "Child"
```

---

## Getter/Setter

### TypeScript 存取器

```typescript
class Temperature {
  constructor(private _celsius: number = 0) {}

  // getter
  get celsius(): number {
    return this._celsius;
  }

  // setter
  set celsius(value: number) {
    if (value < -273.15) {
      throw new Error("Temperature below absolute zero");
    }
    this._celsius = value;
  }

  // 计算属性（只有 getter）
  get fahrenheit(): number {
    return this._celsius * 9 / 5 + 32;
  }

  set fahrenheit(value: number) {
    this._celsius = (value - 32) * 5 / 9;
  }
}

const temp = new Temperature();
temp.celsius = 25;
console.log(temp.celsius);     // 25
console.log(temp.fahrenheit);  // 77
temp.fahrenheit = 100;
console.log(temp.celsius);     // 37.777...
// temp.fahrenheit = -500;     // Error（通过 setter 连锁保护）
```

---

## this 关键字

### this 指向问题

```typescript
class Button {
  constructor(private label: string) {}

  // 方法作为事件处理器时 this 会丢失
  handleClick(): void {
    console.log(`Button ${this.label} clicked`);
  }

  // 箭头函数方法 - this 绑定到实例
  handleClickArrow = (): void => {
    console.log(`Button ${this.label} clicked`);
  };
}

const btn = new Button("Submit");

// 方法引用丢失 this
const handler = btn.handleClick;
// handler();  // Error: this 是 undefined（严格模式）

// 箭头函数方法自动绑定
const arrowHandler = btn.handleClickArrow;
arrowHandler();  // OK: "Button Submit clicked"

// 解决方案 1: bind
const bound = btn.handleClick.bind(btn);

// 解决方案 2: 箭头函数包装
const wrapper = () => btn.handleClick();

// 解决方案 3: 箭头函数方法（已内置绑定）
```

### this 参数

```typescript
interface DOMElement {
  text: string;
  onClick(this: DOMElement, event: MouseEvent): void;
}

const element: DOMElement = {
  text: "Click me",
  onClick(this: DOMElement, event: MouseEvent) {
    console.log(this.text);  // this 类型安全
  },
};

// this 参数在回调中的类型保护
type Handler = (this: HTMLElement, event: Event) => void;
```

---

## 混入 (Mixin)

### TypeScript 混入模式

```typescript
// 混入是组合而非继承
type Constructor<T = {}> = new (...args: any[]) => T;

// 混入函数：接受一个类，返回扩展后的类
function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    createdAt = new Date();
    updatedAt = new Date();

    touch(): void {
      this.updatedAt = new Date();
    }
  };
}

function Activatable<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    isActive = false;

    activate(): void {
      this.isActive = true;
    }

    deactivate(): void {
      this.isActive = false;
    }
  };
}

// 使用混入
class BasicUser {
  constructor(public name: string) {}
}

const TimestampedUser = Timestamped(Activatable(BasicUser));

const user = new TimestampedUser("Alice");
console.log(user.name);       // "Alice"
console.log(user.createdAt);  // Date
user.activate();
console.log(user.isActive);   // true
```

### 替代方案：组合优于继承

```typescript
// 使用组合模式替代混入
class User3 {
  constructor(
    public name: string,
    public timestamps = new TimestampManager(),
    public activation = new ActivationManager()
  ) {}
}

class TimestampManager {
  createdAt = new Date();
  updatedAt = new Date();
  
  touch(): void {
    this.updatedAt = new Date();
  }
}

class ActivationManager {
  isActive = false;
  
  activate(): void {
    this.isActive = true;
  }
  
  deactivate(): void {
    this.isActive = false;
  }
}

const user3 = new User3("Bob");
user3.activation.activate();
console.log(user3.activation.isActive);  // true
```

---

## 装饰器

### TypeScript 装饰器（标准）

TypeScript 5.0+ 支持标准 ECMAScript 装饰器：

```typescript
// 方法装饰器
function log(target: Function, context: ClassMethodDecoratorContext) {
  const methodName = String(context.name);

  return function (this: unknown, ...args: unknown[]) {
    console.log(`Calling ${methodName} with`, args);
    const result = target.call(this, ...args);
    console.log(`Called ${methodName}, result:`, result);
    return result;
  };
}

class Calculator {
  @log
  add(a: number, b: number): number {
    return a + b;
  }
}

const calc = new Calculator();
calc.add(2, 3);  // logs: Calling add with [2, 3], Called add, result: 5
```

### 实验性装饰器语法（旧）

```typescript
// 需要启用 "experimentalDecorators": true
function readonly(target: any, key: string): void {
  Object.defineProperty(target, key, {
    writable: false,
  });
}

function enumerable(value: boolean) {
  return function (target: any, key: string, descriptor: PropertyDescriptor) {
    descriptor.enumerable = value;
  };
}

class MyClass {
  @readonly
  PI = 3.14159;

  @enumerable(false)
  secretMethod(): void {
    console.log("This is secret");
  }
}
```
