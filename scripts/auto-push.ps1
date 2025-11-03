# 自动提交并推送规则变更到 GitHub
# 用途：简化 git add + commit + push 流程

param(
    [string]$Message = "🤖 自动更新规则",
    [string]$Branch = "main"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "自动推送规则到 GitHub" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查是否在规则目录中
$currentPath = Get-Location
if (-not (Test-Path "rules.mdc")) {
    Write-Host "❌ 错误：请在规则目录中运行此脚本" -ForegroundColor Red
    Write-Host "   当前路径: $currentPath" -ForegroundColor Yellow
    exit 1
}

# 2. 检查是否有变更
Write-Host "📝 检查变更..." -ForegroundColor Cyan
$status = git status --porcelain
if (-not $status) {
    Write-Host "✅ 没有需要提交的变更" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 提示：如果你修改了文件，请确保已保存" -ForegroundColor Yellow
    exit 0
}

Write-Host "📋 检测到以下变更：" -ForegroundColor Yellow
Write-Host ""
git status --short
Write-Host ""

# 3. 添加所有变更
Write-Host "➕ 添加所有变更..." -ForegroundColor Cyan
git add .

# 4. 提交变更
Write-Host "💾 提交变更..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$fullMessage = "$Message`n`n自动提交时间: $timestamp"

git commit -m $fullMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 提交失败" -ForegroundColor Red
    exit 1
}

# 5. 推送到 GitHub
Write-Host "🚀 推送到 GitHub..." -ForegroundColor Cyan
git push origin $Branch

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 推送失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 可能的原因：" -ForegroundColor Yellow
    Write-Host "   1. 远程仓库未设置" -ForegroundColor Gray
    Write-Host "   2. 网络连接问题" -ForegroundColor Gray
    Write-Host "   3. 认证失败" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔧 解决方法：" -ForegroundColor Cyan
    Write-Host "   1. 设置远程仓库：" -ForegroundColor Gray
    Write-Host "      git remote add origin https://github.com/laiyinyizao007/cline-global-rules.git" -ForegroundColor Gray
    Write-Host "   2. 检查网络连接" -ForegroundColor Gray
    Write-Host "   3. 配置 GitHub 认证" -ForegroundColor Gray
    exit 1
}

# 6. 成功！
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ 成功推送到 GitHub！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 提交信息: $Message" -ForegroundColor Yellow
Write-Host "🕐 提交时间: $timestamp" -ForegroundColor Yellow
Write-Host "🌲 分支: $Branch" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔗 查看仓库: https://github.com/laiyinyizao007/cline-global-rules" -ForegroundColor Cyan
Write-Host ""
