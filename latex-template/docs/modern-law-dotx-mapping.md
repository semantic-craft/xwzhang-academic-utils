# 现代法学投稿模板格式映射

来源：`$HOME/Library/CloudStorage/Dropbox/中文法学期刊投稿排版指南及排版模板/现代法学投稿模板.dotx`

## 页面

- A4：`11906 x 16838` twips。
- 页边距：上/下 `1418` twips，约 `25mm`；左/右 `1588` twips，约 `28mm`。
- 页眉/页脚距边界：`851` twips，约 `15mm`。

## 字体与行距

- 正文：宋体五号，`10.5pt`；固定行距 `315` twips，约 `15.75pt`；首行缩进 2 字符。
- 一级标题：18pt，加粗，居中，约 27pt 行距。
- 二级标题：14pt，加粗，约 21pt 行距。
- 三级标题：12pt，加粗，约 18pt 行距。
- 四级标题：10.5pt。
- 摘要/关键词：楷体；标签 12pt 加粗，正文 10.5pt。
- 脚注：9pt，约 12pt 行距，全文连续编号，示例为 `〔1〕`。

## LaTeX 对应

- 编译引擎：XeLaTeX。
- 正文字体：macOS 使用 `Songti SC`，缺失时退回 TeX Live 的 `FandolSong`。
- 摘要字体：macOS 使用 `Kaiti SC`，缺失时退回 `FandolKai`。
- 标题黑体：macOS 使用 `Heiti SC`，缺失时退回 `FandolHei`。
- 页面布局、标题编号、页眉页脚、脚注样式由 `lawreview-zh.sty` 统一控制。
