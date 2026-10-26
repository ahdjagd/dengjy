---
name: auto-update-index
description: 自动维护项目首页 index.html。当用户新增、删除或重命名 .html 文件，或要求更新首页、同步文件列表时触发。重新扫描目录并通过 update-index.ps1 生成 index.html。不要在与首页无关的修改中调用。
---

# Auto Update Index

本项目的 `index.html` 是所有课堂练习页面的导航入口，必须始终与目录中的 `.html` 文件保持同步。

## 何时触发

- 用户新增了 `.html` 文件（如 `16-1.html`）
- 用户删除或重命名了 `.html` 文件
- 用户说"更新首页"、"同步文件列表"、"重新生成 index.html"
- 即将 commit 且工作区有新增/删除的 `.html` 文件

## 操作步骤

1. 运行生成脚本（用 PowerShell 直接执行，不要套 powershell.exe 前缀，当前 shell 已是 PowerShell）：
   ```
   & "<workspaceFolder>\update-index.ps1"
   ```
2. 确认输出显示 `index.html generated with N page links`。
3. 如果脚本因编码报错，将 `.ps1` 转为 UTF-8 BOM：
   ```
   $p = "<workspaceFolder>\update-index.ps1"
   $t = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($p))
   [System.IO.File]::WriteAllText($p, $t, (New-Object System.Text.UTF8Encoding $true))
   ```
4. commit 时 pre-commit hook 会自动再次运行并暂存 index.html，无需手动处理。

## 关键设计

- `update-index.ps1` 扫描根目录所有 `*.html`（排除自身），按文件名开头数字排序。
- 生成的 `index.html` 复用 `index.css` 样式，每页一张卡片，含编号、标题、链接。
- `.git/hooks/pre-commit` 自动在每次 commit 前重跑脚本，保证首页不落后。
- 脚本用 `[System.IO.File]::WriteAllText` 以 UTF-8 输出，中文不乱码。

## 不需要做的事

- 不要手动编辑 `index.html` 的卡片列表——那会被下次脚本覆盖。
- 不要把 `update-index.ps1` 加入 `.gitignore`，它需要随仓库分发。
