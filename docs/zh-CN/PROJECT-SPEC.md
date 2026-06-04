# 项目规格

## 产品目标

自媒体爆款助手是一个本地优先的桌面工作台，面向公众号内容团队。它负责采集文章数据、本地保存、查看爆款信号、生成选题建议，并导出可复用报告。

## 目标流程

```text
配置 API 参数
  -> 按关键词、爆文表单或接口目录采集
  -> 将文章、任务和运行历史写入 SQLite
  -> 在内容库查看文章详情
  -> 生成爆款评分和拆解报告
  -> 生成选题推荐
  -> 导出 Markdown 或 XML
```

## 已包含模块

| 模块 | 已包含能力 |
|---|---|
| 仪表盘 | 统计、快速采集、全流程自检。 |
| 内容库 | 文章列表、文章详情、刷新、Markdown 导出、XML 导出。 |
| 接口库 | 仓库内置内容数据服务 索引、分类筛选、endpoint 详情、按 endpoint 采集。 |
| 公众号爆文 | 覆盖 `key`、`keyword`、`pub_type`、`category`、`page`、`start_time`、`end_time` 的可编辑控件。 |
| 拆解报告 | 阅读、点赞、爆款评分、结构化观察。 |
| 选题推荐 | 从内容库高表现文章生成选题。 |
| 插件 | Provider、Exporter、Analyzer 注册表、描述详情和扫描报告。 |
| 设置 | API Key、验证码、endpoint、采集频率、最大运行次数、QPS、导出目录、任务和运行历史。 |

## 技术契约

- 语言与构建：C++20、CMake。
- 界面：Qt6、QML。
- 持久化：SQLite。
- API：内容数据 endpoint 请求与仓库内置 API 目录。
- 扩展性：CTK 风格 Provider、Exporter、Analyzer 接口。
- 导出：Markdown、XML。
- 平台：Linux、Windows、Docker；源码对 x86_64 与 ARM64 Qt 构建保持中立。

## 安全契约

- 本地自检不需要 API Key。
- 缺少凭据时使用安全示例采集。
- vendor API 示例必须保持脱敏。
- 运行产物、本地数据库、打包产物和构建产物不得提交。
- 配置不得要求把密钥写进源码文件。

## 验收门禁

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

候选交付版本必须通过以上全部门禁。
