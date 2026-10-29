﻿# update-index.ps1
# 自动扫描项目中的所有 .html 文件并重新生成 index.html
# 用法: powershell -ExecutionPolicy Bypass -File update-index.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

# 收集所有 html 文件，排除 index.html 自身
$htmlFiles = Get-ChildItem -Path $root -Filter "*.html" -File |
    Where-Object { $_.Name -ne "index.html" } |
    Sort-Object {
        # 按文件名开头的数字排序（如 1, 2, 3...10, 15）
        if ($_.BaseName -match '^(\d+)') { [int]$matches[1] } else { 9999 }
    }, Name

$count = $htmlFiles.Count

# 生成卡片 HTML
$cards = @()
$idx = 0
foreach ($f in $htmlFiles) {
    $idx++
    # 文件名做 URL 编码（处理空格、中文、逗号等）
    $href = [System.Uri]::EscapeDataString($f.Name)

    # 显示标题：去掉扩展名，把分隔符替换为空格
    $rawName = $f.BaseName
    # 尝试从文件名提取可读标题
    $displayName = $rawName -replace '[-_]', ' ' -replace '\s+', ' '

    # 描述
    $num = $idx
    $desc = "课堂练习页面 · $($f.Name)"

    $cards += @"
                    <a class="work-card" href="$href">
                        <div>
                            <span class="card-number">$("{0:D2}" -f $num)</span>
                            <h3>$displayName</h3>
                            <p>$desc</p>
                        </div>
                        <span class="open-link">打开页面 ↗</span>
                    </a>
"@
}
$cardsHtml = ($cards -join "`n")

$now = Get-Date -Format "yyyy-MM-dd HH:mm"

$html = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="袁磊的《高级网页设计》课堂实践作品集入口">
    <title>高级网页设计 · 课堂实践</title>
    <link rel="stylesheet" href="index.css">
</head>
<body>
    <div class="page-shell">
        <header class="topbar">
            <div class="brand-mark">课堂实践档案 · 2026</div>
            <nav class="topbar-links">
                <a href="#works">浏览全部作品 ↓</a>
                <a href="update-index.ps1">自动更新脚本 ↻</a>
            </nav>
        </header>

        <main>
            <section class="hero" aria-labelledby="page-title">
                <div>
                    <p class="eyebrow">YUAN LEI / ADVANCED WEB DESIGN</p>
                    <h1 id="page-title">高级网页设计<br>课堂实践</h1>
                    <p class="hero-copy">袁磊的课程练习入口。这里收录了 HTML 表单、CSS 选择器与页面样式等阶段性实践，点击卡片即可查看对应作品。</p>
                </div>
                <div class="hero-note">
                    <strong>从结构开始，向体验延伸。</strong>
                    每一个页面，都是一次把代码变成可见表达的练习。
                </div>
            </section>

            <section id="works" aria-labelledby="works-title">
                <div class="section-heading">
                    <h2 id="works-title">实践作品</h2>
                    <p>按目录中的网页文件整理，共 $count 个练习页面。</p>
                </div>

                <div class="works">
$cardsHtml
                </div>
            </section>

            <section class="prompt-section" aria-labelledby="prompt-title">
                <div>
                    <h2 id="prompt-title">本提示词</h2>
                    <p class="prompt-label">本页面根据以下课堂实践要求创建。</p>
                </div>
                <blockquote>“创建一个新页面，包括本目录下的所有网页的超链接，使用原生代码，不使用cdn，新页面名称为index.html，主题为袁磊的《高级网页设计》课堂实践，美化页面，页面中包括本提示词。”</blockquote>
            </section>
        </main>

        <footer>
            <p>袁磊 · 《高级网页设计》</p>
            <p>原生 HTML + CSS · 无 CDN · 更新于 $now</p>
        </footer>
    </div>
</body>
</html>
"@

$outPath = Join-Path $root "index.html"
[System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)

Write-Host "[OK] index.html generated with $count page links." -ForegroundColor Green
Write-Host "     timestamp: $now" -ForegroundColor DarkGray
