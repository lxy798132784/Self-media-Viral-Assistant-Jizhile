# 自媒体爆款助手

跨平台桌面应用，用于采集、管理、拆解公众号爆款文章，并支持 Markdown/XML 导出。

## 构建
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## 运行
```bash
./build/media-hit-assistant
```

## 配置
API Key 可在设置页填写，也可用环境变量：
- `JIZHILIA_API_KEY`
- `JIZHILIA_VERIFY_CODE`
