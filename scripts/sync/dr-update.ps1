# dr-update.ps1
# Darwin Rules 双向同步工具
# 智能比较本地和GitHub版本，自动更新到最新状态

param(
    [string]$Message,
    [string]$Branch = "main",
    [switch]$Force,
    [switch]$AutoCommit
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🔄 Darwin Rules 双向同步工具" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# ====================================
# 1. 环境检查
# ====================================

$darwinRoot = "C:\Dev\global-config\darwinRules"
if (-not (Test-Path $darwinRoot)) {
    Write-Host "❌ 错误：找不到darwinRules目录" -ForegroundColor Red
    Write-Host "   路径：$darwinRoot" -ForegroundColor Yellow
    exit 1
}

Set-Location $darwinRoot

if (-not (Test-Path ".git")) {
    Write-Host "❌ 错误：当前目录不是Git仓库" -ForegroundColor Red
    exit 1
}

# ====================================
# 2. 检查本地状态
# ====================================

Write-Host "📊 检查本地状态..." -ForegroundColor Cyan

$localChanges = git status --porcelain
$hasLocalChanges = $localChanges -ne $null -and $localChanges.Length -gt 0

if ($hasLocalChanges) {
    Write-Host "   📝 检测到本地未提交的更改：" -ForegroundColor Yellow
    Write-Host $localChanges
    Write-Host ""
}

# ====================================
# 3. 获取远程状态
# ====================================

Write-Host "📡 获取GitHub最新状态..." -ForegroundColor Cyan

try {
    git fetch origin $Branch 2>&1 | Out-Null
    Write-Host "   ✅ 远程状态获取成功" -ForegroundColor Green
} catch {
    Write-Host "   ❌ 无法连接到GitHub" -ForegroundColor Red
    exit 1
}

$localCommit = git rev-parse HEAD
$remoteCommit = git rev-parse "origin/$Branch"
$hasRemoteChanges = $localCommit -ne $remoteCommit

if ($hasRemoteChanges) {
    $ahead = (git rev-list --count "origin/$Branch..HEAD")
    $behind = (git rev-list --count "HEAD..origin/$Branch")
    
    Write-Host "   📊 本地领先：$ahead 个提交" -ForegroundColor Yellow
    Write-Host "   📊 本地落后：$behind 个提交" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ 本地与远程同步" -ForegroundColor Green
}

Write-Host ""

# ====================================
# 4. 判断同步策略
# ====================================

# 场景1: 本地和远程都没有更改
if (-not $hasLocalChanges -and -not $hasRemoteChanges) {
    Write-Host "✅ 规则已是最新状态，无需同步！" -ForegroundColor Green
    
    if (Test-Path "VERSION") {
        $version = Get-Content "VERSION" -Raw
        Write-Host "📦 当前版本：$version" -ForegroundColor Cyan
    }
    
    exit 0
}

# 场景2: 只有远程有更新
if (-not $hasLocalChanges -and $hasRemoteChanges) {
    Write-Host "📥 检测到GitHub有新更新" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "策略：从GitHub同步到本地" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    
    # 显示即将同步的更新
    Write-Host "📋 将同步以下更新：" -ForegroundColor Cyan
    git log --oneline HEAD..origin/$Branch
    Write-Host ""
    
    if (-not $Force) {
        $confirm = Read-Host "是否继续同步？(y/n)"
        if ($confirm -ne 'y') {
            Write-Host "❌ 操作已取消" -ForegroundColor Yellow
            exit 0
        }
    }
    
    try {
        git pull origin $Branch
        Write-Host ""
        Write-Host "✅ 成功从GitHub同步到本地！" -ForegroundColor Green
        
        if (Test-Path "VERSION") {
            $version = Get-Content "VERSION" -Raw
            Write-Host "📦 更新后版本：$version" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "❌ 同步失败：$_" -ForegroundColor Red
        exit 1
    }
    
    exit 0
}

# 场景3: 只有本地有更改
if ($hasLocalChanges -and -not $hasRemoteChanges) {
    Write-Host "📤 检测到本地有新更改" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "策略：从本地推送到GitHub" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "📋 待推送的更改：" -ForegroundColor Cyan
    Write-Host $localChanges
    Write-Host ""
    
    # 检查是否提供了提交信息
    if (-not $Message -and -not $AutoCommit) {
        Write-Host "❌ 错误：需要提供提交信息" -ForegroundColor Red
        Write-Host "   使用方法：dr-update.ps1 -Message '你的提交说明'" -ForegroundColor Yellow
        Write-Host "   或使用：dr-update.ps1 -AutoCommit (自动生成提交信息)" -ForegroundColor Yellow
        exit 1
    }
    
    # 自动生成提交信息
    if ($AutoCommit -and -not $Message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $Message = "chore: 自动同步更新 - $timestamp"
    }
    
    if (-not $Force) {
        $confirm = Read-Host "是否提交并推送到GitHub？(y/n)"
        if ($confirm -ne 'y') {
            Write-Host "❌ 操作已取消" -ForegroundColor Yellow
            exit 0
        }
    }
    
    try {
        Write-Host "📝 添加更改..." -ForegroundColor Green
        git add .
        
        Write-Host "💾 提交更改..." -ForegroundColor Green
        git commit -m $Message
        
        Write-Host "📤 推送到GitHub..." -ForegroundColor Green
        git push origin $Branch
        
        Write-Host ""
        Write-Host "✅ 成功推送到GitHub！" -ForegroundColor Green
        
        if (Test-Path "VERSION") {
            $version = Get-Content "VERSION" -Raw
            Write-Host "📦 当前版本：$version" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "❌ 推送失败：$_" -ForegroundColor Red
        exit 1
    }
    
    exit 0
}

# 场景4: 本地和远程都有更改（最复杂的情况）
if ($hasLocalChanges -and $hasRemoteChanges) {
    Write-Host "⚠️  检测到本地和GitHub都有更改！" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "策略：先同步远程，再推送本地" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "📋 本地更改：" -ForegroundColor Cyan
    Write-Host $localChanges
    Write-Host ""
    
    Write-Host "📋 远程更新：" -ForegroundColor Cyan
    git log --oneline HEAD..origin/$Branch
    Write-Host ""
    
    # 检查是否提供了提交信息
    if (-not $Message -and -not $AutoCommit) {
        Write-Host "❌ 错误：需要提供提交信息" -ForegroundColor Red
        Write-Host "   使用方法：dr-update.ps1 -Message '你的提交说明'" -ForegroundColor Yellow
        Write-Host "   或使用：dr-update.ps1 -AutoCommit (自动生成提交信息)" -ForegroundColor Yellow
        exit 1
    }
    
    # 自动生成提交信息
    if ($AutoCommit -and -not $Message) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $Message = "chore: 自动同步更新 - $timestamp"
    }
    
    Write-Host "⚠️  同步流程：" -ForegroundColor Yellow
    Write-Host "   1️⃣  提交本地更改" -ForegroundColor White
    Write-Host "   2️⃣  拉取远程更新（可能需要合并）" -ForegroundColor White
    Write-Host "   3️⃣  推送合并后的结果" -ForegroundColor White
    Write-Host ""
    
    if (-not $Force) {
        $confirm = Read-Host "是否继续双向同步？(y/n)"
        if ($confirm -ne 'y') {
            Write-Host "❌ 操作已取消" -ForegroundColor Yellow
            exit 0
        }
    }
    
    try {
        # 步骤1: 提交本地更改
        Write-Host ""
        Write-Host "📝 [1/3] 提交本地更改..." -ForegroundColor Green
        git add .
        git commit -m $Message
        
        # 步骤2: 拉取远程更新
        Write-Host "📥 [2/3] 拉取远程更新..." -ForegroundColor Green
        $pullResult = git pull origin $Branch 2>&1
        
        # 检查是否有冲突
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "⚠️  检测到合并冲突！" -ForegroundColor Red
            Write-Host $pullResult
            Write-Host ""
            Write-Host "请手动解决冲突后运行：" -ForegroundColor Yellow
            Write-Host "   git add ." -ForegroundColor White
            Write-Host "   git commit -m 'merge: 解决冲突'" -ForegroundColor White
            Write-Host "   git push origin $Branch" -ForegroundColor White
            exit 1
        }
        
        # 步骤3: 推送合并结果
        Write-Host "📤 [3/3] 推送合并结果..." -ForegroundColor Green
        git push origin $Branch
        
        Write-Host ""
        Write-Host "✅ 双向同步成功完成！" -ForegroundColor Green
        
        if (Test-Path "VERSION") {
            $version = Get-Content "VERSION" -Raw
            Write-Host "📦 当前版本：$version" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "📊 同步摘要：" -ForegroundColor Cyan
        Write-Host "   ✓ 本地更改已提交" -ForegroundColor Green
        Write-Host "   ✓ 远程更新已合并" -ForegroundColor Green
        Write-Host "   ✓ 合并结果已推送" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ 同步失败：$_" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 提示：你可以手动运行以下命令恢复：" -ForegroundColor Yellow
        Write-Host "   git reset --hard origin/$Branch" -ForegroundColor White
        exit 1
    }
    
    exit 0
}

# 不应该到达这里
Write-Host "❌ 未知状态" -ForegroundColor Red
exit 1
