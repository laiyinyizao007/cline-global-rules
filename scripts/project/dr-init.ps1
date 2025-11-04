# init-project.ps1
# 初始化新项目并配置Darwin规则系统

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [string]$ProjectPath = "C:\Dev\projects",
    [string]$Template = "base-project"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 开始初始化项目：$ProjectName" -ForegroundColor Cyan
Write-Host ""

# 检查Darwin Rules是否存在
$darwinRoot = "C:\Dev\global-config\darwinRules"
if (-not (Test-Path $darwinRoot)) {
    Write-Host "❌ 错误：找不到darwinRules" -ForegroundColor Red
    Write-Host "   请先克隆darwinRules到：$darwinRoot" -ForegroundColor Yellow
    exit 1
}

# 创建项目目录
$fullPath = Join-Path $ProjectPath $ProjectName
if (Test-Path $fullPath) {
    Write-Host "❌ 错误：项目目录已存在" -ForegroundColor Red
    Write-Host "   路径：$fullPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 创建项目目录..." -ForegroundColor Green
New-Item -Path $fullPath -ItemType Directory -Force | Out-Null

# 创建基础目录结构
Write-Host "📦 创建目录结构..." -ForegroundColor Green
$directories = @(
    ".clinerules",
    ".clinerules\project-specific",
    "docs",
    "docs\core",
    "tasks",
    "src",
    "tests"
)

foreach ($dir in $directories) {
    New-Item -Path (Join-Path $fullPath $dir) -ItemType Directory -Force | Out-Null
}

# 创建.darwin-link配置文件
Write-Host "🔗 创建Darwin配置..." -ForegroundColor Green
$darwinLink = @"
{
  "darwinRules": {
    "enabled": true,
    "localPath": "C:\\Dev\\global-config\\darwinRules",
    "version": "2.0.0",
    "lockVersion": false
  },
  "rules": {
    "loadOrder": [
      "darwin-common",
      "project-specific"
    ],
    "overrides": {
      "priority": "project-first"
    }
  },
  "sync": {
    "autoUpdate": false,
    "checkInterval": "weekly"
  }
}
"@

$darwinLink | Out-File -FilePath (Join-Path $fullPath ".clinerules\.darwin-link") -Encoding utf8

# 创建项目特定规则文件
Write-Host "📝 创建项目规则文件..." -ForegroundColor Green

# custom-rules.mdc
$customRules = @"
# $ProjectName - 项目特定规则

> 这些规则仅适用于本项目

---

## 项目信息

- **项目名称**: $ProjectName
- **创建日期**: $(Get-Date -Format "yyyy-MM-dd")
- **Darwin版本**: 2.0.0

---

## 项目特定规范

### 命名约定
（在此添加项目特定的命名规范）

### 业务规则
（在此添加项目特定的业务逻辑规则）

### 技术栈约定
（在此添加项目技术栈的特定约定）

---

**提示：** 通用的规范应该贡献到Darwin公用规则中
"@

$customRules | Out-File -FilePath (Join-Path $fullPath ".clinerules\project-specific\custom-rules.mdc") -Encoding utf8

# project-memory.mdc
$projectMemory = @"
# $ProjectName - 项目记忆

> 项目关键信息和决策记录

---

## 项目架构

### 技术栈
- 

### 核心模块
- 

---

## 重要决策

### [日期] - 决策标题
**背景：**
**决策：**
**理由：**

---

## 项目里程碑

- [ ] 项目初始化
- [ ] 基础架构搭建
- [ ] 核心功能开发
- [ ] 测试和优化
- [ ] 上线部署

---
"@

$projectMemory | Out-File -FilePath (Join-Path $fullPath ".clinerules\project-specific\project-memory.mdc") -Encoding utf8

# 创建README.md
Write-Host "📄 创建README..." -ForegroundColor Green
$readme = @"
# $ProjectName

> 项目简介

## 🎯 项目说明

（在此添加项目说明）

## 🚀 快速开始

\`\`\`bash
# 安装依赖
npm install

# 运行开发服务器
npm run dev
\`\`\`

## 📁 项目结构

\`\`\`
$ProjectName/
├── .clinerules/           # Darwin规则配置
│   ├── .darwin-link       # Darwin链接配置
│   └── project-specific/  # 项目特定规则
├── docs/                  # 文档
├── src/                   # 源代码
├── tests/                 # 测试
└── README.md
\`\`\`

## 🎓 Darwin规则系统

本项目使用Darwin规则系统进行AI辅助开发：

- **公用规则**: C:\Dev\global-config\darwinRules
- **项目规则**: .clinerules/project-specific/

### 更新公用规则

\`\`\`powershell
cd C:\Dev\global-config\darwinRules
git pull
\`\`\`

---

创建日期：$(Get-Date -Format "yyyy-MM-dd")
"@

$readme | Out-File -FilePath (Join-Path $fullPath "README.md") -Encoding utf8

# 创建.gitignore
Write-Host "🚫 创建.gitignore..." -ForegroundColor Green
$gitignore = @"
# Dependencies
node_modules/
__pycache__/
*.pyc

# Environment
.env
.env.local

# Build
dist/
build/
*.log

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
"@

$gitignore | Out-File -FilePath (Join-Path $fullPath ".gitignore") -Encoding utf8

# 初始化Git
Write-Host "🔧 初始化Git..." -ForegroundColor Green
Set-Location $fullPath
git init
git add .
git commit -m "Initial commit: Initialize project with Darwin Rules"

Write-Host ""
Write-Host "✅ 项目初始化完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📊 项目信息：" -ForegroundColor Cyan
Write-Host "   名称：$ProjectName" -ForegroundColor White
Write-Host "   路径：$fullPath" -ForegroundColor White
Write-Host "   Darwin：v2.0.0" -ForegroundColor White
Write-Host ""
Write-Host "🎯 下一步：" -ForegroundColor Yellow
Write-Host "   1. cd $fullPath" -ForegroundColor White
Write-Host "   2. code ." -ForegroundColor White
Write-Host "   3. 开始开发！" -ForegroundColor White
Write-Host ""
Write-Host "💡 提示：" -ForegroundColor Yellow
Write-Host "   - Darwin公用规则会自动加载" -ForegroundColor White
Write-Host "   - 项目特定规则在 .clinerules/project-specific/" -ForegroundColor White
Write-Host "   - 更新公用规则：cd C:\Dev\global-config\darwinRules && git pull" -ForegroundColor White
