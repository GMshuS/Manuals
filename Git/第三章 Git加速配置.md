我给你整理一套**国内最实用、亲测有效的 GitHub 加速方案**，从简单到进阶都列出来，你按需选就行。

# 一、通过URL嵌套设置代理【最简单，但只能pull/clone，不能push】
## 1. 全局配置

**1. 用 `ghproxy.net`（目前很稳）**
```bash
git config --global url."https://ghproxy.net/https://github.com/".insteadOf "https://github.com/"
```

**2. 用 `ghproxy.com`**
```bash
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
```

**3. 用 fastgit 镜像**
```bash
git config --global url."https://hub.fastgit.xyz/".insteadOf "https://github.com/"
```

**4. wj2 github clone 加速【推荐，亲测有效】**
```bash
# gh-proxy.org(富哥可以给这位活佛捐点https://gh-proxy.com/donate/)
git config --global url."https://gh-proxy.org/https://github.com/".insteadOf "https://github.com/"
# Fastly CDN
git config --global url."https://cdn.gh-proxy.org/https://github.com/".insteadOf "https://github.com/"
```

**5. 取消任意代理**
```bash
git config --global --unset url.https://xxx.insteadof
```

> 缺点：公共代理只允许读（pull/clone），不允许写（push），想要push时需要取消代理设置

## 2. 单个仓库配置

```bash
# 假设你的参考地址为:https://github.com/xxx/xxx.git
git remote set-url origin https://ghproxy.net/https://github.com/xxx/xxx.git

# 恢复
git remote set-url origin https://github.com/xxx/xxx.git
```

> 优点：不污染全局 Git，想用就用。


## 3. 单条指令配置
不想改 Git 配置，就在克隆时**直接在链接前加代理**：

```bash
# 假设你的参考地址为:https://github.com/xxx/xxx.git
git clone https://ghproxy.net/https://github.com/xxx/xxx.git
```

> 优点：不污染全局 Git，想用就用。

# 二、使用 Git 内置 HTTP/HTTPS 代理（走你自己的梯子）

如果你有自己的科学上网工具，可以让 Git 直接走代理：

> 免费代理网站：https://proxyfreeonly.com/zh/free-proxy-list?country=&protocols=http

## 1. HTTP 代理
```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

## 2. SOCKS5 代理
```bash
git config --global http.proxy socks5://127.0.0.1:7890
git config --global https.proxy socks5://127.0.0.1:7890
```

取消：
```bash
git config --global --unset http.proxy
git config --global --unset https.proxy

```

# 三、修改 HOSTS（最硬核、速度最快）
直接让电脑把 GitHub 解析到国内能高速访问的 IP，**不用任何代理**。

步骤：
1. 打开网站查可用 IP：
   - https://ipaddress.com/website/github.com
2. 把查到的 IP 加到系统 hosts：
   - Windows：`C:\Windows\System32\drivers\etc\hosts`
   - macOS/Linux：`/etc/hosts`
3. 添加类似格式：
   ```
   140.82.121.4 github.com
   185.199.108.153 raw.githubusercontent.com
   185.199.109.153 raw.githubusercontent.com
   185.199.110.153 raw.githubusercontent.com
   185.199.111.153 raw.githubusercontent.com
   ```

   | 配置条目 | 作用说明 |
   | :--- | :--- |
   | `140.82.121.4 github.com` | 强制把 `github.com` 解析到 IP `140.82.121.4`，让你访问 GitHub 网站、Git 克隆时，直接走这个更稳定、更快的服务器节点，绕过 DNS 污染和慢解析 |
   | `185.199.108.153 raw.githubusercontent.com` | 强制把 `raw.githubusercontent.com`（GitHub 用来托管原始文件、图片、脚本的域名）解析到 `185.199.108.153`，解决 README 图片加载失败、`git clone` 时依赖拉取失败的问题 |

4. 刷新 DNS 生效。

   以管理员身份打开 CMD 或 PowerShell，执行：
   ```bash
   ipconfig /flushdns
   ```
   看到「已成功刷新 DNS 解析缓存」就说明生效了。

> 优点：**全局加速，包括浏览器、Git、下载**，体验最好。
> 缺点：IP 会变，偶尔要更新。

# 四、下载 ZIP 时加速（不用 Git）
很多时候你只是想下代码，不用 Git：
- 打开：https://download.fastgit.org/
- 粘贴 GitHub 下载链接，直接高速下载。

# 五、使用镜像站（完全不用访问 GitHub）
- https://hub.fastgit.xyz/
- https://github.moeyy.xyz/
- https://gitee.com/mirrors

很多热门项目都有镜像，克隆速度拉满。

---
