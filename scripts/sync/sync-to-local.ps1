# sync-to-local.ps1
# 从GitHub同步最新的Darwin规则到本地

param(
    [string]$Branch = "main",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 开始同步Darwin规则..." -ForegroundColor Cyan
Write-Host ""

# 确认在正确的目录
$darwinRoot = "C:\Dev\global-config\darwinRules"
if (-not (Test-Path $darwinRoot)) {
    Write-Host "❌ 错误：找不到darwinRules目录" -ForegroundColor Red
    Write-Host "   路径：$darwinRoot" -ForegroundColor Yellow
    exit 1
}

Set-Location $darwinRoot

# 检查是否是Git仓库
if (-not (Test-Path ".git")) {
    Write-Host "❌ 错误：当前目录不是Git仓库" -ForegroundColor Red
    exit 1
}

# 检查是否有未提交的更改
$status = git status --porcelain
if ($status -and -not $Force) {
    Write-Host "⚠️  警告：检测到未提交的更改" -ForegroundColor Yellow
    Write-Host ""
    Write-Host $status
    Write-Host ""
    Write-Host "请先提交或暂存更改，或使用 -Force 参数强制同步" -ForegroundColor Yellow
    exit 1
}

Write-Host "📡 从GitHub获取最新更新..." -ForegroundColor Green

try {
    # 获取远程更新
    git fetch origin $Branch
    
    # 检查是否有更新
    $localCommit = git rev-parse HEAD
    $remoteCommit = git rev-parse "origin/$Branch"
    
    if ($localCommit -eq $remoteCommit) {
        Write-Host "✅ 本地规则已是最新版本" -ForegroundColor Green
        Write-Host ""
        
        # 显示当前版本
        if (Test-Path "VERSION") {
            $version = Get-Content "VERSION" -Raw
            Write-Host "📊 当前版本：$version" -ForegroundColor Cyan
        }
        
        exit 0
    }
    
    Write-Host "📥 发现新更新，正在拉取..." -ForegroundColor Yellow
    
    # 拉取更新
    if ($Force) {
        git reset --hard "origin/$Branch"
        Write-Host "✅ 强制同步完成" -ForegroundColor Green
    } else {
        git pull origin $Branch
        Write-Host "✅ 同步完成" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # 显示更新日志
    Write-Host "📋 最近的更新：" -ForegroundColor Cyan
    git log --oneline -5
    
    Write-Host ""
    
    # 显示当前版本
    if (Test-Path "VERSION") {
        $version = Get-Content "VERSION" -Raw
        Write-Host "📊 更新后版本：$version" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "✅ Darwin规则同步成功！" -ForegroundColor Green
    Write-Host "💡 所有使用Darwin系统的项目将在下次加载时使用新规则" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ 同步失败：$_" -ForegroundColor Red
    exit 1
}
