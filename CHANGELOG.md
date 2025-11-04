# Changelog

All notable changes to Darwin Rules will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 🚀 **dr-update.ps1** - 智能双向同步工具（合并sync-to-local和sync-to-github）
  - 自动检测本地和远程变化
  - 智能选择同步策略（pull/push/双向）
  - 支持4种场景：无变化/仅远程/仅本地/双向更新
  - 自动合并处理
  - 冲突检测和恢复指导
  - 支持-AutoCommit自动生成提交信息
  - 支持-Force强制同步
- 🎯 **混合模式（Hybrid Mode）** - 智能规则加载系统 ⭐⭐
  - **scripts/utils/smart-loader.ps1** - 智能加载器脚本
    * 优先从GitHub获取最新版本
    * 自动同步到本地作为备份
    * GitHub失败时使用本地备份
    * 支持-ForceLocal强制使用本地版本
    * 无缓存过期概念，总是尝试获取最新
  - **templates/hybrid-mode/.darwin-link.example** - 混合模式配置模板
    * GitHub优先级1，本地优先级2
    * 完整的规则加载顺序定义
    * 支持自动同步和详细日志
  - **docs/HYBRID-MODE-SETUP.md** - 5分钟快速设置指南
    * PowerShell Profile配置示例
    * 完整的使用场景说明（在线/离线）
    * 性能对比表格
    * 详细的故障排除指南
- 📋 **COMMANDS.md** - Darwin命令速查手册
  - 完整的dr-*命令系统文档
  - 详细的参数说明和示例
  - 故障排除指南
  - 高级用法（别名、VS Code集成）

### Changed
- 📝 统一命令命名规范为`dr-*`格式
  - `init-project.ps1` → `dr-init.ps1`
  - `enhance.py` → `dr-enhance.py`
- 📝 更新README.md
  - 推荐使用dr-update进行同步
  - 添加命令手册链接

### Documentation
- 📋 **AUTO-SETUP.md** - 自动化配置完整指南
  - 三种实施方案（本地镜像/在线模式/混合模式）
  - PowerShell Profile自动同步配置
  - VS Code任务集成
  - 完整的故障排除指南
  - 性能优化建议

## [2.0.0] - 2025-11-04

### Added
- 🎉 **Darwin Rules 系统首次发布**
- ✅ 完整的公用规则系统
- ✅ Darwin使用指南（darwin-guide.mdc）
- ✅ ACT模式工作流规则（implement.mdc, debug.mdc）
- ✅ PLAN模式工作流规则（plan.mdc）
- ✅ 通用编码规范（rules.mdc）
- ✅ MCP工具使用指南（mcp-tools.mdc）
- ✅ 目录结构规范（directory-structure.mdc）
- ✅ 快速入门指南（README.mdc）

### Features
- 📚 **混合存储架构** - 公用规则GitHub存储，项目规则本地存储
- 🔄 **规则同步机制** - 一处更新，全部生效
- 🎯 **规则优先级控制** - 支持项目规则优先或公用规则优先
- 📦 **版本锁定支持** - 生产环境可锁定规则版本
- 🚀 **项目初始化脚本** - 一键创建新项目

### Documentation
- 完整的README.md
- Darwin使用指南
- 各类规则文档

### Architecture
- 模块化规则组织
- 清晰的目录结构
- 扩展友好的设计

---

## 更新规范

### 版本号规则
- **MAJOR**: 重大破坏性变更
- **MINOR**: 新增功能，向后兼容
- **PATCH**: Bug修复，向后兼容

### 类型标记
- `Added`: 新功能
- `Changed`: 功能变更
- `Deprecated`: 即将废弃
- `Removed`: 已移除
- `Fixed`: Bug修复
- `Security`: 安全修复

---

**让AI助手更智能，让开发更高效！** 🚀
