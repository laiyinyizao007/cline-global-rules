# Darwin Rules 自动化配置指南

**实现目标：**
1. ✅ 新建项目时自动初始化Darwin规则结构
2. ✅ 公共规则在GitHub集中管理
3. ✅ 修改公共规则后自动同步到本地
4. ✅ 所有项目自动读取最新的公共规则

---

## 🎯 架构设计

### 规则存储架构

```
GitHub (darwinRules仓库)
    ↓ (自动同步)
本地镜像 (C:\Dev\global-config\darwinRules)
    ↓ (符号链接/引用)
项目A, 项目B, 项目C... (通过.darwin-link配置)
```

### 关键特性

1. **单一数据源**: GitHub是公共规则的唯一真实来源
2. **本地缓存**: C:\Dev\global-config\darwinRules作为本地镜像（性能优化）
3. **自动同步**: 修改GitHub后自动同步到本地
4. **实时读取**: 所有项目总是读取最新的公共规则

---

## 📋 方案一：基于本地镜像（推荐）⭐

**特点：** 快速、离线可用、自动同步

### 1. Cline全局配置

创建或编辑Cline的全局配置：

**位置：** `%APPDATA%\Code\User\settings.json`

添加以下配置：

```json
{
  "cline.customInstructions": "# Darwin Rules 自动加载\n\n在开始任何任务前，检查项目根目录是否存在`.clinerules/.darwin-link`配置文件。\n\n如果不存在，询问用户是否需要初始化Darwin Rules系统。\n\n如果用户同意，运行：\n```powershell\npwsh C:\\Dev\\global-config\\darwinRules\\scripts\\project\\dr-init.ps1 -ProjectName [当前项目名]\n```",
  
  "cline.beforeTaskHook": "pwsh -Command \"if (Test-Path C:\\Dev\\global-config\\darwinRules) { cd C:\\Dev\\global-config\\darwinRules; git pull --quiet }\"",
  
  "cline.projectTemplates": {
    "darwinRules": {
      "description": "使用Darwin Rules的标准项目",
      "initScript": "pwsh C:\\Dev\\global-config\\darwinRules\\scripts\\project\\dr-init.ps1 -ProjectName $PROJECT_NAME"
    }
  }
}
```

### 2. PowerShell Profile配置

在PowerShell配置文件中添加自动同步：

**编辑：** `$PROFILE`

```powershell
# Darwin Rules 自动同步函数
function Sync-DarwinRules {
    $darwinPath = "C:\Dev\global-config\darwinRules"
    if (Test-Path $darwinPath) {
        Push-Location $darwinPath
        git fetch origin main --quiet
        $local = git rev-parse HEAD
        $remote = git rev-parse origin/main
        
        if ($local -ne $remote) {
            Write-Host "🔄 Darwin Rules有更新，正在同步..." -ForegroundColor Cyan
            git pull origin main --quiet
            Write-Host "✅ 同步完成！" -ForegroundColor Green
        }
        Pop-Location
    }
}

# 每次打开新终端时自动同步
Sync-DarwinRules

# 创建别名
function dr-update { pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 @args }
function dr-init { pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 @args }
function dr-enhance { python C:\Dev\global-config\darwinRules\scripts\dr-enhance.py }
function dr-sync { Sync-DarwinRules }
```

### 3. Git Hooks配置

在darwinRules仓库中设置Git Hooks：

**创建文件：** `C:\Dev\global-config\darwinRules\.git\hooks\post-merge`

```bash
#!/bin/sh
# 合并后通知
echo "✅ Darwin Rules已更新到最新版本！"
echo "📢 所有使用Darwin的项目将在下次加载时使用新规则"
```

**Windows用户创建：** `C:\Dev\global-config\darwinRules\.git\hooks\post-merge.ps1`

```powershell
Write-Host "✅ Darwin Rules已更新到最新版本！" -ForegroundColor Green
Write-Host "📢 所有使用Darwin的项目将在下次加载时使用新规则" -ForegroundColor Cyan

# 可选：自动提醒打开的项目
$openProjects = Get-Process code -ErrorAction SilentlyContinue
if ($openProjects) {
    Write-Host "💡 建议重新加载VS Code以应用新规则" -ForegroundColor Yellow
}
```

### 4. VS Code任务配置

在每个项目的`.vscode/tasks.json`中添加：

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Darwin: 同步公共规则",
      "type": "shell",
      "command": "pwsh",
      "args": [
        "-Command",
        "cd C:\\Dev\\global-config\\darwinRules; git pull"
      ],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      },
      "problemMatcher": []
    },
    {
      "label": "Darwin: 初始化项目",
      "type": "shell",
      "command": "pwsh",
      "args": [
        "C:\\Dev\\global-config\\darwinRules\\scripts\\project\\dr-init.ps1",
        "-ProjectName",
        "${workspaceFolderBasename}"
      ],
      "problemMatcher": []
    }
  ]
}
```

---

## 📋 方案二：直接从GitHub读取（在线模式）

**特点：** 总是最新、无需同步、需要网络

### 1. 修改.darwin-link配置

在项目初始化时使用GitHub raw URL：

```json
{
  "version": "1.0.0",
  "commonRules": {
    "source": "github",
    "repository": "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main",
    "loadOrder": ["core/rules.mdc", "core/mcp-tools.mdc", "..."],
    "enabled": true,
    "priority": "common-first"
  },
  "projectRules": {
    "path": ".clinerules/project-specific",
    "enabled": true
  }
}
```

### 2. 创建动态加载脚本

**文件：** `.clinerules/scripts/load-darwin.ps1`

```powershell
# 动态从GitHub加载Darwin规则
param([string]$RulePath)

$repo = "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main"
$fullUrl = "$repo/$RulePath"

try {
    $content = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing
    return $content.Content
} catch {
    Write-Warning "无法从GitHub加载规则: $RulePath"
    # 回退到本地缓存
    $localPath = "C:\Dev\global-config\darwinRules\$RulePath"
    if (Test-Path $localPath) {
        return Get-Content $localPath -Raw
    }
    throw "规则加载失败"
}
```

---

## 📋 方案三：混合模式（智能选择）⭐⭐

**特点：** 优先本地、回退在线、最佳性能

### 1. 智能加载配置

```json
{
  "version": "1.0.0",
  "commonRules": {
    "sources": [
      {
        "type": "local",
        "path": "C:\\Dev\\global-config\\darwinRules",
        "priority": 1,
        "autoSync": true
      },
      {
        "type": "github",
        "url": "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main",
        "priority": 2,
        "fallback": true
      }
    ],
    "loadOrder": ["core/rules.mdc", "core/mcp-tools.mdc"],
    "enabled": true
  }
}
```

### 2. 智能加载脚本

**文件：** `C:\Dev\global-config\darwinRules\scripts\utils\smart-loader.ps1`

```powershell
# Darwin Rules 智能加载器
function Load-DarwinRule {
    param(
        [string]$RulePath,
        [int]$MaxAge = 3600  # 1小时缓存
    )
    
    $localPath = "C:\Dev\global-config\darwinRules\$RulePath"
    $githubUrl = "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main/$RulePath"
    
    # 检查本地文件是否存在且新鲜
    if (Test-Path $localPath) {
        $fileAge = (Get-Date) - (Get-Item $localPath).LastWriteTime
        
        if ($fileAge.TotalSeconds -lt $MaxAge) {
            # 本地文件新鲜，直接使用
            Write-Host "✅ 从本地加载: $RulePath" -ForegroundColor Green
            return Get-Content $localPath -Raw
        }
    }
    
    # 尝试从GitHub更新
    try {
        Write-Host "🔄 从GitHub更新: $RulePath" -ForegroundColor Cyan
        $content = Invoke-WebRequest -Uri $githubUrl -UseBasicParsing -TimeoutSec 5
        
        # 保存到本地缓存
        $content.Content | Set-Content $localPath -Encoding UTF8
        Write-Host "✅ 更新成功" -ForegroundColor Green
        return $content.Content
    }
    catch {
        # GitHub失败，使用本地缓存
        if (Test-Path $localPath) {
            Write-Warning "GitHub连接失败，使用本地缓存"
            return Get-Content $localPath -Raw
        }
        throw "无法加载规则: $RulePath"
    }
}
```

---

## 🚀 推荐实施步骤

### 第1步：配置PowerShell Profile

```powershell
# 编辑PowerShell配置
notepad $PROFILE

# 添加上面的"PowerShell Profile配置"内容
# 保存并重新加载
. $PROFILE
```

### 第2步：测试自动同步

```powershell
# 测试同步功能
dr-sync

# 应该显示：
# 🔄 Darwin Rules有更新，正在同步...
# ✅ 同步完成！
```

### 第3步：配置新项目自动初始化

**选项A：手动初始化（简单）**
```powershell
# 创建新项目时运行
dr-init -ProjectName "my-new-project"
```

**选项B：VS Code任务（推荐）**
1. 创建新项目文件夹
2. 打开VS Code
3. 运行任务：`Terminal > Run Task > Darwin: 初始化项目`

**选项C：Git模板（高级）**
```powershell
# 设置Git项目模板
git config --global init.templatedir C:\Dev\global-config\git-templates

# 创建模板目录
mkdir C:\Dev\global-config\git-templates\hooks -Force

# 创建post-init hook
@'
#!/bin/sh
pwsh -Command "pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 -ProjectName $(basename $(pwd))"
'@ | Set-Content C:\Dev\global-config\git-templates\hooks\post-init
```

### 第4步：测试完整流程

```powershell
# 1. 创建测试项目
mkdir C:\Dev\projects\test-darwin
cd C:\Dev\projects\test-darwin

# 2. 初始化Darwin
dr-init -ProjectName "test-darwin"

# 3. 打开VS Code
code .

# 4. 验证配置
# - 检查.clinerules目录存在
# - 检查.darwin-link配置正确
# - Cline应该能读取公共规则
```

---

## 🔄 日常工作流程

### 修改公共规则

```powershell
# 1. 修改本地规则
cd C:\Dev\global-config\darwinRules
# 编辑core/rules.mdc等文件

# 2. 测试规则
# 在一个项目中测试新规则

# 3. 推送到GitHub
dr-update -Message "improve: 优化编码规范"

# 4. 其他项目自动同步
# PowerShell Profile会在打开新终端时自动同步
# 或手动运行：dr-sync
```

### 创建新项目

```powershell
# 方式1：使用dr-init
dr-init -ProjectName "new-project"
cd C:\Dev\projects\new-project
code .

# 方式2：VS Code任务
# 1. 创建文件夹并打开
# 2. 运行任务"Darwin: 初始化项目"
```

---

## 🎯 最佳实践

### 1. 定期同步
```powershell
# 每天开始工作时
dr-sync

# 或设置定时任务（每小时）
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-Command Sync-DarwinRules"
Register-ScheduledTask -TaskName "DarwinRulesSync" -Trigger $trigger -Action $action
```

### 2. 版本锁定（生产环境）
```json
{
  "commonRules": {
    "source": "local",
    "path": "C:\\Dev\\global-config\\darwinRules",
    "version": "2.0.0",
    "lockVersion": true
  }
}
```

### 3. 监控同步状态
```powershell
# 检查本地是否最新
function Check-DarwinRulesStatus {
    cd C:\Dev\global-config\darwinRules
    git fetch origin main --quiet
    $behind = (git rev-list --count HEAD..origin/main)
    
    if ($behind -gt 0) {
        Write-Host "⚠️  Darwin Rules有 $behind 个更新未同步" -ForegroundColor Yellow
        Write-Host "运行 dr-sync 同步" -ForegroundColor Cyan
    } else {
        Write-Host "✅ Darwin Rules已是最新版本" -ForegroundColor Green
    }
}
```

---

## 🆘 故障排除

### Q: 同步失败

```powershell
# 检查网络连接
Test-NetConnection github.com -Port 443

# 强制同步
cd C:\Dev\global-config\darwinRules
git fetch --all
git reset --hard origin/main
```

### Q: 规则未生效

```powershell
# 1. 检查.darwin-link配置
cat .clinerules\.darwin-link

# 2. 手动同步
dr-sync

# 3. 重启VS Code
```

### Q: 冲突处理

```powershell
# 如果本地有修改
cd C:\Dev\global-config\darwinRules
git stash
git pull
git stash pop

# 或丢弃本地修改
git reset --hard origin/main
```

---

## 📊 性能优化

### 1. 使用浅克隆
```powershell
git clone --depth 1 https://github.com/laiyinyizao007/darwinRules.git C:\Dev\global-config\darwinRules
```

### 2. 启用Git缓存
```powershell
git config --global credential.helper wincred
git config --global core.autocrlf false
```

### 3. 使用符号链接（仅限管理员）
```powershell
# 在项目中创建符号链接
New-Item -ItemType SymbolicLink -Path ".clinerules\common" -Target "C:\Dev\global-config\darwinRules\core"
```

---

**Darwin Rules - 自动化、智能化、高效化！** 🚀
