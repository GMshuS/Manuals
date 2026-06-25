# 第9章 TypeScript 项目全流程手册

> 本手册详细介绍 TypeScript 项目的工程化实践

## 目录

1. [项目初始化](#项目初始化)
2. [tsconfig 配置详解](#tsconfig-配置详解)
3. [包管理 (npm/yarn/pnpm)](#包管理-npmyarnpnpm)
4. [构建工具](#构建工具)
5. [代码质量 (ESLint + Prettier)](#代码质量-eslint--prettier)
6. [测试框架](#测试框架)
7. [调试](#调试)
8. [CI/CD 集成](#cicd-集成)
9. [TypeScript 与 Node.js](#typescript-与-nodejs)
10. [TypeScript 与 React](#typescript-与-react)

---

## 项目初始化

### 创建 TypeScript 项目

```bash
# 使用 npm 创建
mkdir my-project
cd my-project
npm init -y

# 安装 TypeScript
npm install --save-dev typescript

# 生成 tsconfig.json
npx tsc --init

# 使用模板工具
npx create-typescript-app my-app

# 使用更完整的模板
npm create vite@latest my-vite-app -- --template react-ts
npm create next-app@latest my-next-app -- --typescript

# 或使用 tsdx（库开发）
npx tsdx create my-lib
```

### 项目结构

```
my-project/
├── src/                  # 源代码目录
│   ├── index.ts          # 入口文件
│   ├── types/            # 类型定义
│   │   └── index.d.ts
│   ├── utils/            # 工具函数
│   ├── services/         # 服务层
│   ├── components/       # 组件（React 等）
│   └── __tests__/        # 测试文件
├── dist/                 # 编译输出
├── node_modules/         # 依赖
├── tsconfig.json         # TypeScript 配置
├── .eslintrc.cjs         # ESLint 配置
├── .prettierrc           # Prettier 配置
├── vitest.config.ts      # 测试配置
├── package.json          # 包配置
└── README.md
```

---

## tsconfig 配置详解

### 核心配置

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    // 目标设置
    "target": "ES2022",                // 编译目标版本
    "module": "Node16",                // 模块系统
    "moduleResolution": "Node16",      // 模块解析策略
    "lib": ["ES2022", "DOM"],          // 环境类型定义
    
    // 输出设置
    "outDir": "./dist",                // 输出目录
    "rootDir": "./src",                // 源码根目录
    "declaration": true,               // 生成 .d.ts 文件
    "declarationMap": true,            // 生成声明文件 sourcemap
    "sourceMap": true,                 // 生成 sourcemap
    
    // 严格检查
    "strict": true,                    // 启用所有严格检查
    "noImplicitAny": true,             // 禁止隐式 any
    "strictNullChecks": true,          // 严格的 null 检查
    "strictFunctionTypes": true,       // 严格函数类型
    "strictBindCallApply": true,       // 严格 bind/call/apply
    "strictPropertyInitialization": true, // 严格属性初始化
    "noUnusedLocals": true,            // 未使用局部变量报错
    "noUnusedParameters": true,        // 未使用参数报错
    "noFallthroughCasesInSwitch": true,// switch 穿透检查
    
    // 模块解析
    "baseUrl": ".",                    // 基础路径
    "paths": {
      "@/*": ["./src/*"]               // 路径别名
    },
    "esModuleInterop": true,           // ESM 互操作
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,         // 允许导入 JSON
    "allowSyntheticDefaultImports": true,
    
    // 高级
    "skipLibCheck": true,              // 跳过 node_modules 类型检查
    "isolatedModules": true,           // 每个文件独立编译
    "incremental": true                // 增量编译
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### tsconfig 继承

```jsonc
// tsconfig.base.json - 基础配置
{
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "target": "ES2022",
    "module": "Node16"
  }
}

// tsconfig.json - 项目配置
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}

// tsconfig.build.json - 构建配置
{
  "extends": "./tsconfig.json",
  "exclude": ["**/*.test.ts", "**/*.spec.ts"]
}
```

---

## 包管理 (npm/yarn/pnpm)

### npm 基本命令

```bash
# 初始化
npm init -y                 # 初始化 package.json

# 安装依赖
npm install express          # 安装到 dependencies
npm install -D typescript    # 安装到 devDependencies
npm install -g ts-node       # 全局安装

# 使用特定版本
npm install react@18.2.0
npm install react@"^18.0.0"

# 卸载
npm uninstall express

# 更新
npm update                   # 更新所有包
npm outdated                 # 查看过期包

# 运行脚本
npm run dev                  # 运行 dev 脚本
npm run build                # 运行 build 脚本
npm test                     # 运行 test 脚本

# 清理
npm cache clean --force      # 清理缓存
npm prune                    # 移除未使用的包
```

### package.json 配置

```jsonc
{
  "name": "my-app",
  "version": "1.0.0",
  "description": "A TypeScript project",
  "private": true,
  
  "type": "module",          // "module" = ESM, "commonjs" = CJS
  
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "lint": "eslint src/",
    "format": "prettier --write src/",
    "typecheck": "tsc --noEmit"
  },
  
  "dependencies": {
    "express": "^4.18.0"
  },
  
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/express": "^4.17.0",
    "vitest": "^1.0.0",
    "eslint": "^8.0.0"
  },
  
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### yarn / pnpm 对比

```bash
# yarn（替代 npm）
yarn init                 # npm init -y
yarn add express          # npm install express
yarn add -D typescript    # npm install -D typescript
yarn remove express       # npm uninstall express
yarn upgrade              # npm update
yarn start                # npm run start

# pnpm（磁盘空间优化）
pnpm init                 # npm init -y
pnpm add express          # npm install express
pnpm add -D typescript    # npm install -D typescript
pnpm remove express       # npm uninstall express
pnpm update               # npm update
```

---

## 构建工具

### TypeScript 编译器 (tsc)

```bash
# 编译
npx tsc                    # 编译所有 TypeScript 文件
npx tsc --watch            # 监视模式（自动重编译）
npx tsc --noEmit           # 仅类型检查，不生成文件
npx tsc --build            # 项目引用构建

# tsconfig 指定
npx tsc -p tsconfig.build.json
```

### 常用构建工具

| 工具 | 适用场景 | 特点 |
|------|----------|------|
| `tsc` | 简单项目、库 | TypeScript 原生编译器 |
| `esbuild` | 快速构建 | 极快的打包速度，Go 编写 |
| `tsup` | 库打包 | 基于 esbuild，零配置 |
| `rollup` | 库打包 | Tree-shaking 优秀 |
| `webpack` | 复杂应用 | 插件丰富，配置复杂 |
| `vite` | 前端应用 | 快速开发服务器 + esbuild |
| `swc` | 编译加速 | Rust 编写，替代 babel |

### 构建配置示例

```typescript
// tsup.config.ts - 库构建
import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["cjs", "esm"],    // 同时输出 CommonJS 和 ESM
  dts: true,                  // 生成类型声明文件
  sourcemap: true,
  clean: true,
  minify: true,
  target: "es2020",
});

// vite.config.ts - 前端应用
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: "dist",
    sourcemap: true,
  },
  server: {
    port: 3000,
    proxy: {
      "/api": "http://localhost:8080",
    },
  },
});
```

---

## 代码质量 (ESLint + Prettier)

### ESLint 配置

```javascript
// eslint.config.js (Flat Config - ESLint 9+)
import typescript from "@typescript-eslint/eslint-plugin";
import parser from "@typescript-eslint/parser";

export default [
  {
    files: ["src/**/*.ts"],
    languageOptions: {
      parser,
      parserOptions: {
        project: "./tsconfig.json",
      },
    },
    plugins: {
      "@typescript-eslint": typescript,
    },
    rules: {
      // TypeScript 推荐规则
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/explicit-function-return-type": "off",
      "@typescript-eslint/no-unused-vars": ["error", {
        argsIgnorePattern: "^_",
      }],
      "@typescript-eslint/strict-boolean-expressions": "error",
      
      // 通用规则
      "no-console": "warn",
      "prefer-const": "error",
      "no-var": "error",
      "eqeqeq": ["error", "always"],
    },
  },
  {
    ignores: ["dist/**", "node_modules/**"],
  },
];
```

### Prettier 配置

```jsonc
// .prettierrc
{
  "semi": true,
  "singleQuote": false,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf",
  "quoteProps": "as-needed"
}
```

### 集成命令

```bash
# 安装
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D prettier eslint-config-prettier

# 运行检查
npm run lint                    # ESLint 检查
npm run format                  # Prettier 格式化
npx eslint --fix src/           # 自动修复
npx prettier --write src/       # 格式化全部

# 类型检查
npx tsc --noEmit                # 仅类型检查
```

---

## 测试框架

### Vitest 配置与使用

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";
import path from "path";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

### 测试编写

```typescript
// src/utils/math.test.ts
import { describe, it, expect, vi, beforeEach } from "vitest";
import { add, divide, fetchData } from "./math";

// 单元测试
describe("add", () => {
  it("should add two numbers correctly", () => {
    expect(add(1, 2)).toBe(3);
    expect(add(-1, 1)).toBe(0);
    expect(add(0, 0)).toBe(0);
  });

  it("should handle decimals", () => {
    expect(add(0.1, 0.2)).toBeCloseTo(0.3);
  });
});

describe("divide", () => {
  it("should divide correctly", () => {
    expect(divide(10, 2)).toBe(5);
  });

  it("should throw on division by zero", () => {
    expect(() => divide(1, 0)).toThrow("Division by zero");
  });
});

// 异步测试
describe("fetchData", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("should fetch and parse data", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ data: "test" }),
    });

    const result = await fetchData("/api/test");
    expect(result).toEqual({ data: "test" });
  });

  it("should throw on HTTP error", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 404,
    });

    await expect(fetchData("/api/notfound")).rejects.toThrow("HTTP 404");
  });
});
```

### 其他测试工具

```bash
# 常用测试框架
npm install -D vitest           # 单元测试（推荐）
npm install -D jest             # 单元测试（传统）
npm install -D @playwright/test # E2E 测试
npm install -D @testing-library/react  # React 组件测试

# 运行测试
npx vitest            # 运行所有测试
npx vitest --watch    # 监视模式
npx vitest --coverage # 覆盖率报告
npx vitest run        # 单次运行（CI）
```

---

## 调试

### VS Code 调试配置

```jsonc
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug TypeScript",
      "program": "${workspaceFolder}/src/index.ts",
      "runtimeArgs": ["--loader", "tsx"],
      "skipFiles": ["<node_internals>/**"],
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "preLaunchTask": "tsc: build - tsconfig.json"
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Current File",
      "program": "${file}",
      "runtimeArgs": ["--loader", "tsx"],
      "skipFiles": ["<node_internals>/**"]
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to Process",
      "port": 9229
    }
  ]
}
```

### Node.js 调试命令

```bash
# 内置调试器
node --inspect dist/index.js          # 启动调试器
node --inspect-brk dist/index.js      # 在第一行暂停
node --inspect -r tsx src/index.ts    # 调试 TypeScript

# 使用 Chrome DevTools
# 打开 chrome://inspect 连接调试器

# 使用 Node.js REPL + 调试
node inspect dist/index.js            # 命令行调试器
```

### 调试技术

```typescript
// console.log 调试
console.log("value:", value);            // 基本日志
console.table(data);                     // 表格输出
console.group("Group");                  // 分组日志
console.time("operation");               // 计时开始
// ... code ...
console.timeEnd("operation");            // 计时结束
console.trace("Trace");                  // 堆栈跟踪

// Node.js 内置调试器
debugger;  // 调试器在此暂停

// 使用 util.inspect
import util from "node:util";

const complexObject = { nested: { deep: "value" } };
console.log(util.inspect(complexObject, {
  showHidden: true,
  depth: null,
  colors: true,
}));
```

---

## CI/CD 集成

### GitHub Actions 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npx tsc --noEmit

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test

      - name: Build
        run: npm run build

  # 可选：发布到 npm
  publish:
    needs: quality
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: "https://registry.npmjs.org"
      - run: npm ci
      - run: npm run build
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

## TypeScript 与 Node.js

### tsx - TypeScript 执行器

```bash
# tsx（推荐，esbuild 驱动，极快）
npm install -D tsx

# 直接运行 TypeScript
npx tsx src/index.ts
npx tsx watch src/index.ts  # 监视模式（类似 nodemon）

# package.json 脚本
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "start": "tsx src/index.ts"
  }
}
```

### ts-node（旧方案）

```bash
# ts-node（较慢，完整类型检查）
npm install -D ts-node

# 运行
npx ts-node src/index.ts
npx ts-node --transpile-only src/index.ts  # 跳过类型检查（更快）
```

### Node.js 类型定义

```typescript
// Node.js 内置模块类型
import fs from "node:fs";
import path from "node:path";
import { promisify } from "node:util";

// 使用 fs.promises（推荐）
async function readConfig(): Promise<unknown> {
  const content = await fs.promises.readFile(
    path.join(__dirname, "config.json"),
    "utf-8"
  );
  return JSON.parse(content);
}

// EventEmitter
import { EventEmitter } from "node:events";

class MyEmitter extends EventEmitter {
  emitData(data: unknown): void {
    this.emit("data", data);
  }
}

// HTTP 服务器
import http from "node:http";

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "ok" }));
});

server.listen(3000);
```

---

## TypeScript 与 React

### 组件类型定义

```typescript
// 函数组件
import React from "react";

interface ButtonProps {
  label: string;
  variant?: "primary" | "secondary";
  disabled?: boolean;
  onClick: (event: React.MouseEvent<HTMLButtonElement>) => void;
}

const Button: React.FC<ButtonProps> = ({
  label,
  variant = "primary",
  disabled = false,
  onClick,
}) => {
  return (
    <button
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {label}
    </button>
  );
};

// 泛型组件
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
}

function List<T>({ items, renderItem }: ListProps<T>): React.ReactElement {
  return <ul>{items.map((item, i) => renderItem(item, i))}</ul>;
}

// 使用
const NumberList = <List items={[1, 2, 3]} renderItem={n => <li>{n}</li>} />;
```

### Hooks 类型

```typescript
// useState - 类型推断
const [count, setCount] = useState(0);      // number
const [name, setName] = useState("");       // string
const [user, setUser] = useState<User | null>(null);  // 联合类型

// useRef
const inputRef = useRef<HTMLInputElement>(null);
const countRef = useRef<number>(0);

// useEffect
useEffect(() => {
  // 副作用逻辑
  return () => {
    // 清理函数
  };
}, [dependency]);

// 自定义 Hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

// 使用
const [theme, setTheme] = useLocalStorage("theme", "light");
```

### 事件处理类型

```typescript
// 表单事件
const handleSubmit = (e: React.FormEvent<HTMLFormElement>): void => {
  e.preventDefault();
  console.log("Submitted");
};

const handleChange = (e: React.ChangeEvent<HTMLInputElement>): void => {
  console.log(e.target.value);
};

// 鼠标事件
const handleClick = (e: React.MouseEvent<HTMLButtonElement>): void => {
  console.log(e.clientX, e.clientY);
};

// 键盘事件
const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>): void => {
  if (e.key === "Enter") {
    console.log("Enter pressed");
  }
};

// 拖拽事件
const handleDrag = (e: React.DragEvent<HTMLDivElement>): void => {
  e.dataTransfer.setData("text/plain", "data");
};
```
