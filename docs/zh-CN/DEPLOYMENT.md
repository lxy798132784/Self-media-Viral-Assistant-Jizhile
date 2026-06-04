# 部署与开发指南

本文按平台和 CPU 架构说明自媒体爆款助手如何安装、运行、卸载和开发。

## 已验证平台矩阵

| 平台 | 架构 | 适用场景 | 资产或命令 | 状态 |
|---|---:|---|---|---|
| Linux 桌面或带 GUI 库的服务器 | amd64 / x86_64 | 普通用户安装 | GitHub Release `media-hit-assistant-<version>-linux-amd64.tar.gz` | CI 原生打包 |
| Linux 桌面或带 GUI 库的服务器 | arm64 / aarch64 | 树莓派、RK3588、NanoPC、ARM 工作站 | 安装 Qt6 后源码构建 | 源码支持，本机 aarch64 已验证 |
| Windows 10/11 | x64 | 普通桌面使用 | GitHub Release `media-hit-assistant-<version>-windows-x64.zip` | CI 原生打包 |
| Docker / CI | amd64 或 arm64 主机 | 自动化验证 | `docker build` 或 `./scripts/verify-all.sh` | 无头自测路径 |
| macOS | arm64 或 x64 | 开发者手动构建 | 手动安装 Qt6 后源码构建 | 暂无签名发布包 |

## 截图

仓库内置了一张界面预览图，也可以从真实二进制生成新的运行截图。

![仪表盘预览](../assets/dashboard-preview.svg)

需要从当前构建产物生成真实截图时运行：

```bash
cmake --build build -j2
QT_QPA_PLATFORM=vnc QT_QUICK_BACKEND=software ./build/media-hit-assistant --screenshot docs/assets/local-install-dashboard.png
```

这个命令会启动同一套 QML 应用、加载示例文章、截取第一个仪表盘窗口、保存 PNG，然后自动退出。它适合 CI 或没有物理显示器的服务器。

## Linux amd64：从 Release 压缩包部署

### 干什么

这是普通 Linux x86_64 桌面、云桌面和 CI Runner 的首选使用路径。Release 压缩包由 GitHub Actions 在 Ubuntu 24.04 上构建，是一个已安装目录树。

### 怎么安装

```bash
VERSION=0.1.1
curl -L -o media-hit-assistant-linux-amd64.tar.gz \
  "https://github.com/lxy798132784/Self-media-Viral-Assistant-Jizhile/releases/download/v${VERSION}/media-hit-assistant-${VERSION}-linux-amd64.tar.gz"
tar -xzf media-hit-assistant-linux-amd64.tar.gz
cd "media-hit-assistant-${VERSION}-linux-amd64"
./usr/bin/media-hit-assistant
```

### 怎么校验

```bash
curl -L -o SHA256SUMS \
  "https://github.com/lxy798132784/Self-media-Viral-Assistant-Jizhile/releases/download/v${VERSION}/SHA256SUMS"
sha256sum media-hit-assistant-linux-amd64.tar.gz
grep "linux-amd64" SHA256SUMS
```

这样做是为了确认下载到的包与 Release 产物一致，避免网络中断或错误文件导致运行问题。

### 怎么卸载

如果只是解压运行，删除解压目录和下载文件即可：

```bash
cd ..
rm -rf "media-hit-assistant-${VERSION}-linux-amd64" media-hit-assistant-linux-amd64.tar.gz SHA256SUMS
```

如果用 CMake 安装到了单独前缀，删除该前缀：

```bash
rm -rf /tmp/media-hit-install
```

## Linux arm64 / aarch64：从源码部署

### 干什么

这是树莓派、RK3588 开发板、NanoPC-T6、ARM 服务器和其他 aarch64 机器的推荐路径。直接在设备上编译本机二进制，不需要搭交叉编译链。

### 安装依赖

Ubuntu 22.04 / 24.04 示例：

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3 \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev qt6-tools-dev-tools \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
```

### 构建、测试、运行

```bash
git clone https://github.com/lxy798132784/Self-media-Viral-Assistant-Jizhile.git
cd Self-media-Viral-Assistant-Jizhile
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
./build/media-hit-assistant
```

### 本地隔离安装

```bash
cmake --install build --prefix /tmp/media-hit-install
/tmp/media-hit-install/bin/media-hit-assistant
```

这样不会污染系统目录。它会把可执行文件、README、更新日志、文档、图标、桌面元数据、插件目录和内置 API 索引安装到 `/tmp/media-hit-install` 下。

### 卸载

```bash
rm -rf /tmp/media-hit-install
```

## Windows x64：普通用户部署

### 干什么

这是 Windows 10/11 x64 用户的使用路径。zip 包由 GitHub Actions 在 `windows-2022` 上构建，并包含 Windows 打包脚本生成的应用目录。

### 怎么安装运行

1. 到 GitHub Release 页面下载 `media-hit-assistant-<version>-windows-x64.zip`。
2. 右键 zip，选择“全部解压”。
3. 打开解压后的目录。
4. 双击 `media-hit-assistant.exe`。

PowerShell 方式：

```powershell
$Version = "0.1.1"
Invoke-WebRequest `
  -Uri "https://github.com/lxy798132784/Self-media-Viral-Assistant-Jizhile/releases/download/v$Version/media-hit-assistant-$Version-windows-x64.zip" `
  -OutFile "media-hit-assistant-windows-x64.zip"
Expand-Archive .\media-hit-assistant-windows-x64.zip -DestinationPath .\media-hit-assistant
.\media-hit-assistant\media-hit-assistant.exe
```

### 安装后一闪而过怎么办

如果双击 `media-hit-assistant.exe` 后命令窗口一闪而过，先不要反复双击，改运行同目录下的诊断启动器：

```powershell
.\media-hit-assistant\run-with-log.bat
```

它会在同目录生成 `media-hit-assistant.log`，并在启动失败时停住窗口显示错误。这样能区分三类问题：Qt 或运行时 DLL 缺失、Windows 安全策略拦截未签名程序、QML/图形后端/路径加载失败。

新版 Windows 包在打包时会直接运行解压目录里的 `media-hit-assistant.exe --self-test`，并强制包含 `run-with-log.bat`，避免只有构建目录可运行、发布目录不可运行。

### 怎么卸载

删除解压后的 `media-hit-assistant` 文件夹和下载的 zip 文件即可。当前版本不需要 Windows 安装服务。

## Windows x64：开发构建

### 依赖

需要安装：

- Visual Studio 2022，并勾选 **Desktop development with C++**；
- CMake；
- Qt 6.7.x MSVC x64；
- Python 3。

### 构建和打包

打开 “x64 Native Tools Command Prompt for VS 2022”，或加载了 MSVC 环境的 PowerShell：

```powershell
.\scripts\package-windows.ps1 -BuildDir build-win -Config Release -DistDir media-hit-assistant-dev-windows-x64
```

脚本会配置 CMake、编译、运行 CTest、运行 offscreen 自测、在可用时调用 `windeployqt`、复制文档/插件/vendor 资产，并输出 zip 包。

## Docker 与 CI 使用

### 无头验证

```bash
./scripts/verify-all.sh
```

全量门禁会执行：

1. CMake 构建；
2. CTest 单元测试；
3. offscreen 自检；
4. Markdown/XML 导出产物检查；
5. QML 控件审计；
6. 文档对齐审计；
7. offscreen 启动烟测。

### Docker

```bash
docker build -t media-hit-assistant .
docker run --rm media-hit-assistant
```

Docker 主要用于验证和自动化，不是普通用户的首选 GUI 分发方式。

## 架构差异说明

### amd64 / x86_64

这是 Linux 预构建包的主目标。只使用软件时优先下载 Release；需要改 C++ 或 QML 时再源码构建。

### arm64 / aarch64

建议本机源码构建。很多 ARM 板的 Ubuntu 源里已经有 Qt6，本项目没有架构相关 C++ 逻辑。小内存板子建议 `-j2`，避免编译时内存压力过大。

### Windows x64

普通用户用预构建 zip。开发者用 `scripts/package-windows.ps1` 复现构建和发布流程。

### macOS

当前没有签名 macOS 包。开发者可以手动安装 Qt6 和 CMake 后构建，但 Release 资产目前覆盖 Linux amd64 与 Windows x64。

## 按角色选择工作流

### 普通用户

1. 下载匹配平台的 Release 资产。
2. 必要时校验 SHA256。
3. 解压。
4. 运行可执行文件。
5. API 密钥只保存在本地设置中。

### 开发者

1. 安装 Qt6 和 CMake。
2. 执行 `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release`。
3. 执行 `ctest --test-dir build --output-on-failure`。
4. 提交前执行 `./scripts/verify-all.sh`。
5. 可见行为变化时同步更新文档和截图。

### 发布维护者

1. 推送 `v*` tag。
2. GitHub Actions 构建 Linux amd64 与 Windows x64 资产。
3. publish job 上传源码包、文档包、Release notes 和 `SHA256SUMS`。
4. 至少下载一个资产，检查结构和校验和。

## 运行数据与密钥

本地测试不需要真实密钥。没有配置 API Key 时，软件使用安全示例采集。真实 API Key 只能保存在本地设置或环境变量中，不能提交到仓库。
