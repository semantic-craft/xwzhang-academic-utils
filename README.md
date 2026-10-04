# xwzhang-academic-utils

自制学术工具集（monorepo）。

## 子项目

- [`latex-template/`](./latex-template/) — 中文法学论文 LaTeX 模板（CLSCI / 三大刊取向），含 `lawreview-zh.sty` 与 latexmk 配置。
- [`rename-academic-pdf/`](./rename-academic-pdf/) — 学术 PDF 文件批量重命名工具（uv / Python）。

## 子项目 history

两个子项目通过 `git subtree add` 引入，原仓库 commit history 已保留在各自子目录路径下。


- [`cli-tools/westlaw-prime/`](./cli-tools/westlaw-prime/README.md) — retained Westlaw context entrypoint; the candidate uses Scholar's public CLI, explicit browser context and read-only defaults. See its authorization and recovery contract before selecting a Client ID.
