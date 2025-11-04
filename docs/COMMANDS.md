# Darwin Rules 命令速查手册

**Darwin Rules (dr) 命令系统** - 统一的`dr-*`命名规范

---

## 📋 命令总览

| 命令 | 用途 | 位置 | 状态 |
|------|------|------|------|
| `dr-update` | 智能双向同步 | scripts/sync/ | ✅ 推荐 |
| `dr-init` | 初始化新项目 | scripts/project/ | ✅ 推荐 |
| `dr-enhance` | 增强规则系统 | scripts/ | ✅ 推荐 |

---

## 🔄 dr-update - 智能双向同步

**用途：** 自动检测并同步本地和GitHub的Darwin规则

### 基本用法

```powershell
# 最简单 - 自动同步（推荐）
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -AutoCommit

# 指定提交信息
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -Message "更新规则"

# 强制同步，不需要确认
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -AutoCommit -Force
```

### 参数说明

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `-Message` | String | 提交信息 | 无 |
| `-Branch` | String | 分支名称 | main |
| `-Force` | Switch | 强制同步，跳过确认 | false |
| `-AutoCommit` | Switch | 自动生成提交信息 | false |

### 智能场景

1. **无变化** → 显示"已是最新"
2. **仅远程更新** → 自动 `git pull`
3. **仅本地更改** → 自动 `commit + push`
4. **双向都有** → 智能合并并推送

### 示例

```powershell
# 日常同步（最常用）
pwsh scripts\sync\dr-update.ps1 -AutoCommit

# 重大更新
pwsh scripts\sync\dr-update.ps1 -Message "feat: 添加新的编码规范"

# 紧急修复
pwsh scripts\sync\dr-update.ps1 -Message "fix: 修复规则加载问题" -Force
```

---

## 🚀 dr-init - 初始化新项目

**用途：** 30秒创建一个使用Darwin Rules的新项目

### 基本用法

```powershell
# 创建新项目
pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 -ProjectName "my-project"

# 指定项目路径
pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 -ProjectName "my-project" -ProjectPath "C:\Dev\projects"

# 不初始化Git
pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 -ProjectName "my-project" -NoGit
```

### 参数说明

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `-ProjectName` | String | 项目名称（必需） | 无 |
| `-ProjectPath` | String | 项目路径 | C:\Dev\projects |
| `-NoGit` | Switch | 不初始化Git | false |

### 创建的文件结构

```
my-project/
├── .clinerules/
│   ├── .darwin-link          # Darwin配置
│   └── project-specific/     # 项目规则
│       ├── custom-rules.mdc
│       ├── project-memory.mdc
│       ├── error-logs.mdc
│       └── lessons-learned.mdc
├── docs/                     # 文档目录
├── src/                      # 源代码目录
├── tests/                    # 测试目录
├── .gitignore
└── README.md
```

### 示例

```powershell
# 创建Web项目
pwsh scripts\project\dr-init.ps1 -ProjectName "my-web-app"

# 创建API项目
pwsh scripts\project\dr-init.ps1 -ProjectName "my-api" -ProjectPath "C:\Dev\apis"

# 创建库项目（不需要Git）
pwsh scripts\project\dr-init.ps1 -ProjectName "my-lib" -NoGit
```

---

## 🤖 dr-enhance - 规则系统增强

**用途：** AI分析错误模式，生成改进建议

### 基本用法

```powershell
# 运行增强分析
python C:\Dev\global-config\darwinRules\scripts\dr-enhance.py

# 或使用别名（如果已配置）
enhance
```

### 功能

1. **错误模式分析**
   - 识别高频错误
   - 计算置信度
   - 生成预防规则

2. **环境检测**
   - PowerShell版本检测
   - 编码设置检查
   - 依赖版本验证

3. **自动改进**
   - 更新 lessons-learned.mdc
   - 生成规则建议
   - 更新系统健康度统计

### 配置文件

位置：`scripts/config.yaml`

```yaml
analysis:
  min_frequency: 3          # 最小出现次数
  min_confidence: 0.7       # 最小置信度

auto_append:
  enabled: true             # 启用自动追加
  add_timestamp: true       # 添加时间戳
```

### 示例

```powershell
# 定期运行（每周一次）
python scripts\dr-enhance.py

# 在积累多个错误后运行
python scripts\dr-enhance.py

# 重大功能完成后运行
python scripts\dr-enhance.py
```

---

## 🎯 快速参考

### 日常开发流程

```powershell
# 1. 创建新项目
pwsh scripts\project\dr-init.ps1 -ProjectName "new-feature"

# 2. 开发中遇到问题 → 记录到项目的error-logs.mdc

# 3. 定期同步公用规则
pwsh scripts\sync\dr-update.ps1 -AutoCommit

# 4. 运行增强分析
python scripts\dr-enhance.py

# 5. 如果有规则改进 → 再次同步
pwsh scripts\sync\dr-update.ps1 -Message "improve: 优化规则"
```

### 常见任务

```powershell
# 更新公用规则
pwsh scripts\sync\dr-update.ps1 -AutoCommit

# 创建新项目
pwsh scripts\project\dr-init.ps1 -ProjectName "项目名"

# 分析错误并改进
python scripts\dr-enhance.py
```

---

## 🔧 高级用法

### 创建命令别名

在 PowerShell 配置文件中添加：

```powershell
# $PROFILE 中添加
function dr-update { pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 @args }
function dr-init { pwsh C:\Dev\global-config\darwinRules\scripts\project\dr-init.ps1 @args }
function dr-enhance { python C:\Dev\global-config\darwinRules\scripts\dr-enhance.py }
```

然后就可以直接使用：

```powershell
dr-update -AutoCommit
dr-init -ProjectName "my-project"
dr-enhance
```

### 集成到VS Code

在 `.vscode/tasks.json` 中添加：

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Darwin: Update Rules",
      "type": "shell",
      "command": "pwsh",
      "args": ["scripts/sync/dr-update.ps1", "-AutoCommit"],
      "options": {
        "cwd": "C:/Dev/global-config/darwinRules"
      }
    },
    {
      "label": "Darwin: Enhance Rules",
      "type": "shell",
      "command": "python",
      "args": ["scripts/dr-enhance.py"],
      "options": {
        "cwd": "C:/Dev/global-config/darwinRules"
      }
    }
  ]
}
```

---

## 📊 命令对比

### 旧命令 vs 新命令

| 旧命令 | 新命令 | 说明 |
|--------|--------|------|
| `sync-to-local.ps1` | `dr-update` | 已合并 |
| `sync-to-github.ps1` | `dr-update` | 已合并 |
| `init-project.ps1` | `dr-init` | 重命名 |
| `enhance.py` | `dr-enhance.py` | 重命名 |

### 迁移指南

```powershell
# 旧方式
pwsh scripts\sync\sync-to-local.ps1
pwsh scripts\sync\sync-to-github.ps1 -Message "update"
pwsh scripts\project\init-project.ps1 -ProjectName "test"
python scripts\enhance.py

# 新方式（推荐）
pwsh scripts\sync\dr-update.ps1 -AutoCommit
pwsh scripts\sync\dr-update.ps1 -Message "update"
pwsh scripts\project\dr-init.ps1 -ProjectName "test"
python scripts\dr-enhance.py
```

---

## 🆘 故障排除

### dr-update常见问题

**Q: 提示"需要提供提交信息"**
```powershell
# 解决：使用-AutoCommit或-Message
pwsh scripts\sync\dr-update.ps1 -AutoCommit
```

**Q: 合并冲突怎么办？**
```powershell
# dr-update会提供恢复指导
git add .
git commit -m "merge: 解决冲突"
git push origin main
```

### dr-init常见问题

**Q: 项目已存在**
```powershell
# 删除现有项目或使用不同的名称
rm -r C:\Dev\projects\my-project
pwsh scripts\project\dr-init.ps1 -ProjectName "my-project"
```

### dr-enhance常见问题

**Q: Python未安装**
```powershell
# 安装Python 3.7+
winget install Python.Python.3
```

**Q: PyYAML未安装**
```powershell
# 安装依赖
pip install pyyaml requests
```

---

## 📚 相关文档

- **核心文档**: `core/darwin-guide.mdc` - Darwin系统使用指南
- **架构文档**: `docs/darwin-architecture.md` - 系统架构设计
- **实施指南**: `docs/darwin-implementation-guide.md` - 实施步骤

---

**Darwin Rules - 统一、智能、高效的规则管理！** 🚀
