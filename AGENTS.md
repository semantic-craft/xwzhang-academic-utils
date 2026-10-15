# 学术工具集维护

按子项目定位；各子项目的 README、构建配置与 tests 拥有自己的运行方式。

| 任务 | 入口 |
| --- | --- |
| PDF 重命名 | [rename-academic-pdf/README](rename-academic-pdf/README.md)、[源码](rename-academic-pdf/src/)、[tests](rename-academic-pdf/tests/)、[justfile](rename-academic-pdf/justfile) |
| LaTeX 样式 | [latex-template](latex-template/) |
| 历史 CLI 工具 | [cli-tools](cli-tools/)，先读具体工具 README 核对是否仍启用 |
| 本地效率工具壳 | [productivity-cli/README](productivity-cli/README.md)，原 Todoist CLI 已退役 |

PDF 子项目在其目录运行 `uv run pytest`；其他检查按 justfile 选择，注意 `just check` 包含会写文件的格式化步骤。LaTeX 变更须编译代表性稿件并查看输出。目录存在不代表工具已经安装或仍被调用。
实现、评审或验收前读相关 [lessons](lessons.md)；出现可复用的纠正或漏验时更新原条目。
