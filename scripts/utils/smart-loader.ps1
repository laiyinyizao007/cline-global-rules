# Darwin Rules 智能加载器
# 优先GitHub在线版本，失败时回退到本地备份

param(
    [Parameter(Mandatory=$true)]
    [string]$RulePath,
    
    [switch]$ForceLocal  # 强制使用本地版本
)

$ErrorActionPreference = "Stop"

# 配置
$localBase = "C:\Dev\global-config\darwinRules"
$githubBase = "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main"

$localPath = Join-Path $localBase $RulePath
$githubUrl = "$githubBase/$RulePath"

# ====================================
# 函数：从GitHub加载（优先）
# ====================================
function Load-FromGitHub {
    param([string]$Url, [string]$LocalPath)
    
    try {
        Write-Host "🔄 从GitHub加载最新版本: $RulePath" -ForegroundColor Cyan
        
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            $content = $response.Content
            
            # 保存到本地作为备份
            $directory = Split-Path $LocalPath -Parent
            if (-not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            
            $content | Set-Content $LocalPath -Encoding UTF8 -Force
            Write-Host "✅ 使用GitHub最新版本（已同步到本地）" -ForegroundColor Green
            
            return $content
        }
    }
    catch {
        Write-Verbose "GitHub访问失败: $_"
        return $null
    }
    
    return $null
}

# ====================================
# 函数：从本地加载（备份）
# ====================================
function Load-FromLocal {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        return $null
    }
    
    Write-Host "⚠️  GitHub不可用，使用本地备份版本" -ForegroundColor Yellow
    return Get-Content $Path -Raw -Encoding UTF8
}

# ====================================
# 主逻辑：智能加载
# ====================================

Write-Verbose "智能加载规则: $RulePath"

# 强制本地模式
if ($ForceLocal) {
    Write-Host "⚡ 强制使用本地版本" -ForegroundColor Yellow
    
    if (Test-Path $localPath) {
        Write-Host "✅ 使用本地版本" -ForegroundColor Green
        return Get-Content $localPath -Raw -Encoding UTF8
    }
    
    throw "本地文件不存在: $RulePath"
}

# 策略1：优先从GitHub获取最新版本
$content = Load-FromGitHub -Url $githubUrl -LocalPath $localPath

if ($content) {
    return $content
}

# 策略2：GitHub失败，使用本地备份
$content = Load-FromLocal -Path $localPath

if ($content) {
    return $content
}

# 所有策略都失败
throw "无法加载规则: $RulePath (GitHub不可用且本地无备份)"
