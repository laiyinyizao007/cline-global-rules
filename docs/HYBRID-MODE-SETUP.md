# Darwin Rules 混合模式快速设置

**方案三：混合模式（智能选择）⭐⭐**

优先使用GitHub最新版本，失败时自动回退到本地备份。

---

## 🎯 工作原理

```
加载规则
    ↓
尝试从GitHub获取最新版本
    ↓
GitHub可用？
    ├─ 是 → ✅ 使用GitHub最新版本（并同步到本地作为备份）
    └─ 否 → ⚠️ 使用本地备份版本
```

### 优势

✅ **总是最新** - 每次都尝试从GitHub获取
✅ **离线可用** - GitHub失败时使用本地备份
✅ **自动备份** - GitHub版本自动同步到本地
✅ **简单直接** - 无缓存过期概念

---

## 🚀 5分钟快速设置

### 步骤1：配置PowerShell Profile

```powershell
# 打开配置文件
notepad $PROFILE

# 添加以下内容：
```

```powershell
# Darwin Rules 混合模式配置

# 自动同步函数
function Sync-DarwinRules {
    $darwinPath = "C:\Dev\global-config\darwinRules"
    if (Test-Path $darwinPath) {
        Push-Location $darwinPath
        $before = git rev-parse HEAD
        git pull origin main --quiet 2>$null
        $after = git rev-parse HEAD
        
        if ($before -ne $after) {
            Write-Host "✅ Darwin Rules已更新" -ForegroundColor Green
        }
        Pop-Location
    }
}

# 每次打开终端自动同步（静默）
Sync-DarwinRules

# 便捷命令
function dr-update { pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 @args }
function dr-init { pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 @args }
function dr-enhance { python C:\Dev\global-config\darwinRules\scripts\dr-enhance.py }
function dr-sync { Sync-DarwinRules }
function dr-load { pwsh C:\Dev\global-config\darwinRules\scripts\utils\smart-loader.ps1 @args }
```

```powershell
# 保存并重新加载
. $PROFILE
```

### 步骤2：初始化项目（使用混合模式）

```powershell
# 创建新项目
dr-init -ProjectName "my-project"

# 进入项目目录
cd C:\Dev\projects\my-project

# 复制混合模式配置
cp C:\Dev\global-config\darwinRules\templates\hybrid-mode\.darwin-link.example .clinerules\.darwin-link
```

### 步骤3：测试智能加载

```powershell
# 测试加载一个规则文件（优先GitHub）
dr-load -RulePath "core/rules.mdc"

# 应该显示：
# 🔄 从GitHub加载最新版本: core/rules.mdc
# ✅ 使用GitHub最新版本（已同步到本地）

# 强制使用本地版本测试
dr-load -RulePath "core/rules.mdc" -ForceLocal

# 应该显示：
# ⚡ 强制使用本地版本
# ✅ 使用本地版本
```

---

## 📋 .darwin-link 配置详解

### 完整配置示例

```json
{
  "version": "1.0.0",
  "mode": "hybrid",
  
  "commonRules": {
    "sources": [
      {
        "type": "github",
        "url": "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main",
        "priority": 1,
        "description": "GitHub在线（优先）- 总是最新"
      },
      {
        "type": "local",
        "path": "C:\\Dev\\global-config\\darwinRules",
        "priority": 2,
        "description": "本地备份（回退）",
        "fallback": true
      }
    ],
    
    "loadOrder": [
      "core/rules.mdc",
      "core/mcp-tools.mdc",
      "core/darwin-guide.mdc"
    ],
    
    "loader": "C:\\Dev\\global-config\\darwinRules\\scripts\\utils\\smart-loader.ps1",
    "enabled": true
  },
  
  "projectRules": {
    "path": ".clinerules/project-specific",
    "enabled": true
  },
  
  "options": {
    "autoSync": true,
    "alwaysUseGitHub": true
  }
}
```

### 配置参数说明

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `priority` | 数据源优先级 | GitHub=1，本地=2 |
| `fallback` | 是否作为回退 | 本地=true |
| `autoSync` | 自动同步 | true |
| `alwaysUseGitHub` | 总是优先GitHub | true |

---

## 🔄 日常使用

### 查看规则（自动选择最优方式）

Cline在加载规则时会自动：

1. 尝试从GitHub获取最新版本
2. 成功 → 使用GitHub版本并同步到本地
3. 失败 → 使用本地备份版本

**完全自动！无需任何手动操作！**

### 修改公共规则

```powershell
# 1. 修改规则
cd C:\Dev\global-config\darwinRules
# 编辑规则文件...

# 2. 推送到GitHub
dr-update -Message "improve: 优化规则"

# 3. 所有项目立即生效
# 下次加载规则时会自动从GitHub获取最新版本
```

### 强制使用本地版本

```powershell
# 需要离线工作或测试本地修改时
dr-load -RulePath "core/rules.mdc" -ForceLocal
```

---

## 🎯 使用场景

### 场景1：正常开发（GitHub可用）

```
打开项目 → Cline加载规则
    ↓
尝试GitHub
    ↓
✅ 成功 → 使用最新版本 → 同步到本地
```

### 场景2：规则已更新（实时获取）

```
打开项目 → Cline加载规则
    ↓
从GitHub获取
    ↓
📥 获取最新更新 → ✅ 使用最新版本
```

### 场景3：离线开发（GitHub不可用）

```
打开项目 → Cline加载规则
    ↓
尝试GitHub
    ↓
❌ 连接失败
    ↓
⚠️ 使用本地备份版本（仍然可用）
```

---

## 🔧 高级配置

### 离线开发模式

如果需要长期离线工作，可以在加载时使用 `-ForceLocal` 参数：

```powershell
# 在.darwin-link中配置强制本地模式
{
  "options": {
    "forceLocal": true
  }
}
```

### 多环境配置

```powershell
# 开发环境 - 总是使用最新
# 使用默认配置

# 生产环境 - 锁定版本
# 修改GitHub URL指向特定tag
{
  "sources": [{
    "type": "github",
    "url": "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/v2.0.0"
  }]
}
```

---

## 📊 性能对比

| 场景 | 纯本地 | 纯在线 | 混合模式 |
|------|--------|--------|----------|
| GitHub可用 | 可能过时 | 最新 | **最新** |
| GitHub不可用 | ✅ | ❌ | ✅ |
| 离线可用 | ✅ | ❌ | ✅ |
| 总是最新 | ❌ | ✅ | ✅ |
| 网络故障 | ✅ | ❌ | ✅ |

**混合模式集合了两者的优点！**

---

## 🆘 故障排除

### Q: 总是从GitHub加载太慢

**A:** 检查网络连接

```powershell
# 测试GitHub连接速度
Measure-Command { 
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/laiyinyizao007/darwinRules/main/README.md" -UseBasicParsing 
}

# 如果网络不佳，可以临时使用本地模式
dr-load -RulePath "core/rules.mdc" -ForceLocal
```

### Q: GitHub连接失败

**A:** 检查网络和代理设置

```powershell
# 测试GitHub连接
Test-NetConnection raw.githubusercontent.com -Port 443

# 配置Git代理（如果需要）
git config --global http.proxy http://proxy.example.com:8080
```

### Q: 本地备份不存在

**A:** 首次使用前同步一次

```powershell
# 同步Darwin Rules到本地
dr-sync

# 或手动拉取
cd C:\Dev\global-config\darwinRules
git pull origin main
```

---

## 📚 相关文档

- **完整指南**: `docs/AUTO-SETUP.md`
- **命令手册**: `docs/COMMANDS.md`
- **Darwin指南**: `core/darwin-guide.mdc`

---

## 🎉 总结

混合模式提供了：

✅ **最新** - 总是尝试从GitHub获取
✅ **可靠** - 离线时使用本地备份
✅ **简单** - 无缓存过期概念
✅ **智能** - 自动选择最优方式
✅ **灵活** - 可强制使用本地版本

**这是生产环境的最佳选择！** 🚀
