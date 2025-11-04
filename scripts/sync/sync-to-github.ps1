# sync-to-github.ps1
# 推送本地Darwin规则更新到GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$Message,
    
    [string]$Branch = "main",
    [switch]$Push
)

$ErrorActionPreference = "Stop"

Write-Host "📤 准备推送Darwin规则更新..." -ForegroundColor Cyan
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

# 显示当前状态
Write-Host "📋 当前更改：" -ForegroundColor Cyan
$status = git status --short
if (-not $status) {
    Write-Host "   没有更改需要提交" -ForegroundColor Yellow
    exit 0
}

Write-Host $status
Write-Host ""

# 确认提交
if (-not $Push) {
    $confirm = Read-Host "是否继续提交并推送？(y/n)"
    if ($confirm -ne 'y') {
        Write-Host "❌ 操作已取消" -ForegroundColor Yellow
        exit 0
    }
}

try {
    # 添加所有更改
    Write-Host "📝 添加更改..." -ForegroundColor Green
    git add .
    
    # 提交
    Write-Host "💾 提交更改..." -ForegroundColor Green
    git commit -m $Message
    
    # 推送
    Write-Host "📤 推送到GitHub..." -ForegroundColor Green
    git push origin $Branch
    
    Write-Host ""
    Write-Host "✅ 成功推送到GitHub！" -ForegroundColor Green
    
    # 显示当前版本
    if (Test-Path "VERSION") {
        $version = Get-Content "VERSION" -Raw
        Write-Host "📊 当前版本：$version" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "💡 提示：" -ForegroundColor Yellow
    Write-Host "   - 所有使用Darwin系统的项目可以通过 git pull 获取更新" -ForegroundColor Yellow
    Write-Host "   - 或运行 sync-to-local.ps1 自动同步" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ 推送失败：$_" -ForegroundColor Red
    exit 1
}
