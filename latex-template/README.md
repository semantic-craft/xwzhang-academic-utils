# 中文法学论文 LaTeX 模板

这个工作区用于在 VS Code + LaTeX Workshop 中写中文法学论文。格式按 `现代法学投稿模板.dotx` 抽取主要版式，目标是能稳定生成接近 Word 投稿模板的 PDF 样稿。

## 使用方式

1. 用 VS Code 打开本目录。
2. 编辑 `main.tex` 中的题名、作者信息、摘要、关键词和正文。
3. 在 VS Code 命令面板运行 `LaTeX Workshop: Build LaTeX project`，或保存文件触发自动编译。
4. 生成文件在 `build/main.pdf`。

## 命令行编译

```bash
/Library/TeX/texbin/latexmk -xelatex -outdir=build main.tex
```

清理中间文件：

```bash
/Library/TeX/texbin/latexmk -C -outdir=build main.tex
```

## 文件说明

- `main.tex`：论文入口与样张。
- `lawreview-zh.sty`：中文法学论文版式包。
- `.vscode/settings.json`：LaTeX Workshop 配置，使用绝对路径调用 `/Library/TeX/texbin/latexmk`，避免 VS Code GUI 启动时找不到 TeX。
- `.latexmkrc`：命令行编译配置。
- `docs/modern-law-dotx-mapping.md`：从 Word 模板抽取出的格式映射。

## 写作约定

- 使用 XeLaTeX，不使用 pdfLaTeX。
- 正文脚注用 `\footnote{...}`，编号会自动显示为 `〔1〕`。
- 一级标题用 `\section{...}`，输出为 `一、...`。
- 二级标题用 `\subsection{...}`，输出为 `（一）...`。
- 三级标题用 `\subsubsection{...}`，输出为 `1. ...`。
