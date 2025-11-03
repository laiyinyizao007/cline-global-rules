# Cline 全局规则

> 统一的 AI 编码助手规则系统，支持 PLAN/ACT 双模式工作流

[![GitHub](https://img.shields.io/badge/GitHub-cline--global--rules-blue)](https://github.com/laiyinyizao007/cline-global-rules)

## 📚 规则文件

- **rules.mdc** - 通用规则（项目配置、依赖管理、编码规范）
- **ACT/implement.mdc** - 实现工作流
- **ACT/debug.mdc** - 调试工作流  
- **PLAN/plan.mdc** - 规划工作流
- **memory.mdc** - 项目记忆库系统
- **error-documentation.mdc** - 错误记录模板
- **lessons-learned.mdc** - 经验教训模板
- **directory-structure.mdc** - 目录结构规范

## 🚀 使用方法

### 方法 1：Git Submodule（推荐）

在项目中作为 submodule 使用：

```powershell
# 添加 submodule
cd C:\Dev\projects\your-project
git submodule add https://github.com/laiyinyizao007/cline-global-rules .clinerules-global

# 合并规则到 .clinerules
pwsh -File .clinerules-global/scripts/merge-to-parent.ps1
```

### 方法 2：直接克隆

克隆到全局配置目录：

```powershell
# 克隆仓库
cd C:\Dev\global-config
git clone https://github.com/laiyinyizao007/cline-global-rules clinerules

# 在项目中使用
cd C:\Dev\projects\your-project
pwsh -File "C:\Dev\global-config\clinerules\scripts\merge-to-project.ps1"
```

### 方法 3：符号链接

创建符号链接（需要管理员权限）：

```powershell
# 克隆到本地
git clone https://github.com/laiyinyizao007/cline-global-rules C:\Dev\global-config\clinerules

# 在项目中创建符号链接
cd C:\Dev\projects\your-project
New-Item -ItemType SymbolicLink -Path ".clinerules" -Target "C:\Dev\global-config\clinerules"
```

## 🔄 更新规则

### 更新本地规则

```powershell
cd C:\Dev\global-config\clinerules
git pull origin main
```

### 自动同步到所有项目

使用提供的脚本：

```powershell
pwsh -File C:\Dev\global-config\clinerules\scripts\sync-all-projects.ps1
```

## 📝 贡献规则

### 修改规则

```powershell
# 1. 编辑规则文件
code C:\Dev\global-config\clinerules\rules.mdc

# 2. 提交更改
cd C:\Dev\global-config\clinerules
git add .
git commit -m "更新: 描述你的更改"

# 3. 推送到 GitHub
git push origin main
```

### 自动推送（推荐）

使用自动推送脚本：

```powershell
# 编辑规则后，运行自动推送
cd C:\Dev\global-config\clinerules
.\scripts\auto-push.ps1 "更新描述"
```

## 🏗️ 目录结构

```
clinerules/
├── README.md                      # 本文件
├── .gitignore                     # Git 忽略规则
│
├── ACT/                           # 实现模式规则
│   ├── implement.mdc              # 实现工作流
│   └── debug.mdc                  # 调试工作流
│
├── PLAN/                          # 规划模式规则
│   └── plan.mdc                   # 规划工作流
│
├── rules.mdc                      # 通用规则
├── memory.mdc                     # 记忆库系统
├── error-documentation.mdc        # 错误记录
├── lessons-learned.mdc            # 经验教训
├── directory-structure.mdc        # 目录结构
│
└── scripts/                       # 工具脚本
    ├── auto-push.ps1              # 自动推送
    ├── merge-to-project.ps1       # 合并到项目
    └── sync-all-projects.ps1      # 同步所有项目
```

## 🌟 核心特性

- ✅ **统一规则** - 所有项目使用相同的规则
- ✅ **版本控制** - 通过 Git 管理规则变更
- ✅ **云端同步** - 自动推送到 GitHub
- ✅ **多机协作** - 支持多台电脑同步
- ✅ **团队共享** - 团队成员共用规则库
- ✅ **自动更新** - 脚本自动同步最新规则

## 📖 规则说明

### PLAN 模式
用于项目规划、架构设计、技术选型

### ACT 模式  
用于代码实现、调试、测试

### Memory 系统
7个核心文档构成项目知识库

## 🔗 相关链接

- **规则模板项目**: [rules_template](https://github.com/laiyinyizao007/rules_template)
- **中文编码规范**: `C:\Dev\rules\`

## 📄 许可

MIT License

---

**让 AI 编码助手更智能！** 🚀
