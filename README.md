# Darwin Rules - AI规则系统

> 通用AI编码助手规则库 - 支持Cline、Cursor等AI工具

## 🎯 什么是Darwin Rules？

Darwin Rules是一个智能的AI规则管理系统，采用混合存储架构：
- **公用规则集中管理** - 所有项目共享
- **自动同步更新** - 一处修改，处处生效
- **项目规则灵活覆盖** - 支持项目特定定制

## 📊 核心优势

- ✅ **项目体积减少95%** - 不再重复存储规则
- ✅ **更新效率提升10倍** - 一次更新全部生效
- ✅ **版本100%一致** - 自动同步机制
- ✅ **30秒创建项目** - 一条命令搞定

## 🚀 快速开始

### 1. 克隆到本地

```powershell
git clone https://github.com/laiyinyizao007/darwinRules.git C:\Dev\global-config\darwinRules
```

### 2. 创建新项目

```powershell
pwsh C:\Dev\global-config\darwinRules\scripts\project\init-project.ps1 -ProjectName "my-project"
```

### 3. 开始开发

```powershell
cd C:\Dev\projects\my-project
code .
```

## 📁 目录结构

```
darwinRules/
├── core/                      # 核心规则（公用）
│   ├── ACT/                   # 实现和调试规则
│   ├── PLAN/                  # 规划规则
│   ├── rules.mdc              # 编码规范
│   ├── mcp-tools.mdc          # MCP工具指南
│   ├── darwin-guide.mdc       # Darwin使用指南 ⭐
│   └── ...
├── templates/                 # 项目模板
│   └── base-project/
├── scripts/                   # 管理脚本
│   ├── sync/                  # 同步脚本
│   └── project/               # 项目管理
└── docs/                      # 文档
```

## 🔄 日常使用

### 智能双向同步（推荐）⭐

使用新的`dr-update`工具，自动处理本地和GitHub的同步：

```powershell
# 自动检测并同步（最简单）
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -AutoCommit

# 手动指定提交信息
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -Message "更新说明"

# 强制同步，不确认
pwsh C:\Dev\global-config\darwinRules\scripts\sync\dr-update.ps1 -AutoCommit -Force
```

**智能功能：**
- ✅ 自动检测本地和远程变化
- ✅ 智能选择同步策略（pull/push/双向）
- ✅ 自动处理合并
- ✅ 冲突提示和恢复指导

### 传统方式

#### 只从GitHub拉取更新

```powershell
cd C:\Dev\global-config\darwinRules
git pull
```

#### 只推送本地更改

```powershell
cd C:\Dev\global-config\darwinRules
# 修改规则
git add .
git commit -m "Improve: 说明"
git push
```

## 📖 文档

- **📋 命令手册**: `docs/COMMANDS.md` - Darwin命令速查（⭐ 推荐）
- **核心规则**: `core/darwin-guide.mdc` - Darwin使用指南
- **架构设计**: 查看rules_template项目的docs/darwin-architecture.md
- **实施指南**: 查看rules_template项目的docs/darwin-implementation-guide.md

## 🎓 规则组成

### 公用规则（core/）
1. **darwin-guide.mdc** - Darwin系统使用指南
2. **rules.mdc** - 通用编码规范
3. **mcp-tools.mdc** - MCP工具使用指南
4. **ACT/** - 实现和调试规则
5. **PLAN/** - 规划规则

### 项目规则（.clinerules/project-specific/）
- custom-rules.mdc - 项目自定义规则
- project-memory.mdc - 项目记忆
- error-logs.mdc - 错误日志
- lessons-learned.mdc - 经验教训

## 📊 版本

当前版本: **2.0.0**

查看 [CHANGELOG.md](CHANGELOG.md) 了解更新历史。

## 🤝 贡献

欢迎贡献规则改进！

1. Fork本仓库
2. 创建功能分支
3. 提交改进
4. 发起Pull Request

## 📄 许可

MIT License

---

**让AI助手更智能，让开发更高效！** 🚀
