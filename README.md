# docker-golang

多版本 Golang Docker 构建环境，支持 Ubuntu LTS 系列和 RHEL。

## 📋 项目概述

本项目提供针对不同 Linux 发行版版本的 Docker 构建环境，用于 Golang 应用的容器化开发。确保 Go 应用在不同操作系统基础镜像下的构建一致性和兼容性。

### ✨ 特性

- 🐳 多版本 Ubuntu LTS 支持（20.04、22.04、24.04、26.04）
- 🔴 Red Hat Enterprise Linux (RHEL) 支持
- 🚀 预装最新稳定版 Golang
- 🌐 OpenResty + Lua 生态集成
- 📦 丰富的开发工具链（protobuf、ta-lib、jemalloc 等）
- 🔒 安全的敏感信息处理机制（Docker BuildKit secrets）
- 🛠️ 完整的 Go 开发工具集（golangci-lint、gopls、delve 等）

## 📁 目录结构

```
.
├── 20.04/              # Ubuntu 20.04 LTS 环境
│   └── Dockerfile
├── 22.04/              # Ubuntu 22.04 LTS 环境
│   └── Dockerfile
├── 24.04/              # Ubuntu 24.04 LTS 环境
│   └── Dockerfile
├── 26.04/              # Ubuntu 26.04 环境
│   └── Dockerfile
├── .github/
│   └── workflows/      # GitHub Actions CI/CD 配置
│       └── docker.yml
└── README.md
```

## 🚀 快速开始

### 前置要求

- Docker Engine 19.03+（支持 BuildKit）
- Git

### 构建镜像

选择你需要的版本进行构建：

```bash
# Ubuntu 20.04 LTS
docker build -t go-app:20.04 ./20.04

# Ubuntu 22.04 LTS
docker build -t go-app:22.04 ./22.04

# Ubuntu 24.04 LTS
docker build -t go-app:24.04 ./24.04

# Ubuntu 26.04
docker build -t go-app:26.04 ./26.04

```

### 使用 BuildKit Secrets 传递敏感信息

根据 Docker 敏感数据处理规范，**禁止使用 ARG 或 ENV 传递密码等敏感数据**。应使用 Docker BuildKit 的 secrets 功能：

#### 方法一：从文件读取

```bash
# 创建包含密码的文件
echo "your_password" > ldap_password.txt

# 构建时挂载 secret
docker build --secret id=ldap_password,src=./ldap_password.txt -t go-app:26.04 ./26.04
```

#### 方法二：从环境变量读取

```bash
export LDAP_PASSWORD="your_password"
docker build --secret id=ldap_password,env=LDAP_PASSWORD -t go-app:26.04 ./26.04
```

#### 在 Dockerfile 中使用

```dockerfile
RUN --mount=type=secret,id=ldap_password \
    bash -c 'LDAP_PASSWORD=$(cat /run/secrets/ldap_password) && \
    echo "slapd slapd/root_password password ${LDAP_PASSWORD}" | debconf-set-selections'
```

### 运行容器

```bash
# 交互式运行
docker run -it --rm go-app:24.04 bash

# 挂载本地代码目录
docker run -it --rm -v $(pwd):/home/www/src go-app:24.04 bash

# 运行 Go 应用
docker run -it --rm -v $(pwd):/app -w /app go-app:24.04 go run main.go
```

## 🛠️ 预装组件

### 核心语言环境

- **Golang**: 1.26.4
- **OpenResty**: 1.31.1.1 （基于 Nginx + LuaJIT）
- **LuaRocks**: 3.13.0（Lua 包管理器）

### 系统库与依赖

- **jemalloc**: 5.3.1（高性能内存分配器）
- **OpenSSL**: 4.0.0
- **PCRE2**: 10.47
- **libvips**: 8.13.0（图像处理库）
- **TA-Lib**: 0.6.4（技术分析库）
- **Protocol Buffers**: 35.1

### Go 开发工具

- `go-bindata` / `go-bindata-assetfs` - 资源嵌入工具
- `protoc-gen-go` / `protoc-gen-go-grpc` - gRPC 代码生成
- `golangci-lint` - Go linter 聚合工具
- `gopls` - Go 语言服务器
- `delve (dlv)` - Go 调试器
- `staticcheck` - 静态分析工具
- `govulncheck` - 漏洞检查工具
- `goimports` - 导入管理
- `gotests` - 测试生成
- `gomodifytags` - 结构体标签修改
- `impl` - 接口实现生成
- `goplay` - Go playground 客户端
- `protoc-gen-openapi` - OpenAPI 生成
- `protoc-go-inject-tag` - Protobuf 标签注入
- `go-mod-upgrade` - 依赖升级工具

### Lua 模块

- `lua-resty-http` - HTTP 客户端
- `lua-resty-jwt` - JWT 支持
- `lua-resty-mlcache` - 多层缓存

### Nginx 模块

- `nginx-http-concat` - 资源合并
- `nginx-http-user-agent` - User-Agent 处理
- `nginx-http-trim` - HTML 压缩

### 系统工具

- 编译工具链：gcc, g++, cmake, make, autoconf, automake
- 调试工具：gdb, valgrind, strace, tcpdump
- 网络工具：curl, wget, net-tools, iputils-ping
- 图像处理：imagemagick, jpegoptim, optipng, pngquant
- 其他：git, vim, zsh, htop, tree, supervisor

## ⚙️ 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `BUILD` | `/home/www/golang` | Go 工作区根目录 |
| `GOENV` | `${BUILD}/env` | Go 环境目录 |
| `GOTMPDIR` | `${BUILD}/tmp` | Go 临时目录 |
| `GOBIN` | `${BUILD}/bin` | Go 二进制输出目录 |
| `GOCACHE` | `${BUILD}/cache` | Go 缓存目录 |
| `GOPATH` | `${BUILD}` | Go PATH |
| `GO111MODULE` | `on` | 启用 Go Modules |
| `CHROMEDP_NO_SANDBOX` | `true` | ChromeDP 无沙箱模式 |
| `CHROMEDP_HEADLESS` | `true` | ChromeDP 无头模式 |

## 🔧 自定义构建参数

可以通过 `--build-arg` 自定义组件版本：

```bash
docker build \
  --build-arg GOLANG_VERSION="1.21.0" \
  --build-arg RESTY_VERSION="1.25.3.1" \
  --build-arg LDAP_PASSWORD="custom_password" \
  -t go-app:custom ./24.04
```

支持的构建参数：

- `LDAP_DOMAIN` - LDAP 域名（默认：localhost）
- `LDAP_ORG` - LDAP 组织（默认：ldap）
- `LDAP_HOSTNAME` - LDAP 主机名（默认：localhost）
- `LDAP_PASSWORD` - LDAP 密码（⚠️ 建议使用 secrets）
- `JEMALLOC_VERSION` - jemalloc 版本
- `RESTY_VERSION` - OpenResty 版本
- `LUAROCKS_VERSION` - LuaRocks 版本
- `OPENSSL_VERSION` - OpenSSL 版本
- `PCRE_VERSION` - PCRE 版本
- `VIPS_VERSION` - libvips 版本
- `GOLANG_VERSION` - Golang 版本
- `PROTOBUF_VERSION` - Protocol Buffers 版本
- `TALIB_VERSION` - TA-Lib 版本

## 🔄 CI/CD

项目包含 GitHub Actions 工作流配置（`.github/workflows/docker.yml`），支持自动构建和推送 Docker 镜像。

### GitHub Secrets 配置

在 GitHub 仓库设置中配置以下 Secrets：

1. 进入 **Settings → Secrets and variables → Actions**
2. 添加所需的 repository secrets（如 `LDAP_PASSWORD`）
3. 在工作流中使用 `secrets` 参数传递

示例工作流配置：

```yaml
- name: Build Docker image
  uses: docker/build-push-action@v5
  with:
    context: ./24.04
    push: true
    tags: your-image:latest
    secrets: |
      ldap_password=${{ secrets.LDAP_PASSWORD }}
```

## 📝 最佳实践

### 1. 敏感信息处理

✅ **推荐做法**：
```bash
# 使用 secrets 传递密码
docker build --secret id=ldap_password,env=LDAP_PASSWORD -t image ./24.04
```

❌ **避免做法**：
```bash
# 不要使用 ARG 或 ENV 传递敏感数据
docker build --build-arg LDAP_PASSWORD=xxx -t image ./24.04
```

### 2. 镜像优化

- 构建完成后清理缓存和临时文件
- 使用多阶段构建减小镜像体积（可根据需要扩展）
- 定期更新基础镜像和安全补丁

### 3. 开发工作流

```bash
# 1. 克隆项目
git clone <repository-url>
cd docker-golang

# 2. 构建镜像
docker build -t go-dev:latest ./24.04

# 3. 启动开发容器
docker run -it --rm \
  -v $(pwd)/my-project:/home/www/src/my-project \
  -w /home/www/src/my-project \
  go-dev:latest \
  bash

# 4. 在容器中开发
go mod init my-project
go run main.go
```

## 🐛 常见问题

### Q: 构建速度慢怎么办？

A: 可以使用 Docker 层缓存和国内镜像源加速：

```bash
# 启用 BuildKit 缓存
DOCKER_BUILDKIT=1 docker build --cache-from go-app:24.04 -t go-app:24.04 ./24.04
```

### Q: 如何更新某个组件的版本？

A: 修改对应版本目录下的 Dockerfile 中的 `ARG` 版本号，然后重新构建。

### Q: Ubuntu 26.04 是否稳定？

A: Ubuntu 26.04 可能尚未正式发布或处于测试阶段，生产环境建议使用稳定的 LTS 版本（20.04、22.04、24.04）。

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 👤 维护者

- **Abulo Hoo** - [abulo.hoo@gmail.com](mailto:abulo.hoo@gmail.com)

## 🙏 致谢

感谢以下开源项目：

- [Golang](https://golang.org/)
- [OpenResty](https://openresty.org/)
- [Ubuntu](https://ubuntu.com/)
- [Docker](https://www.docker.com/)

---

**注意**: 请确保在使用前了解各个组件的许可证要求，特别是在商业环境中使用时。
