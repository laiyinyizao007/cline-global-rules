#!/usr/bin/env python3
"""
.clinerules 增强脚本 v3.0 - 智能记录系统
功能：
  1. 自动分析和增强现有 .mdc 文件
  2. 环境检测（PowerShell版本、编码）
  3. 自动记录新发现的问题
原则：无侵入，只追加，不修改
"""
import re
import sys
import platform
import subprocess
import locale
from pathlib import Path
from collections import Counter, defaultdict
from datetime import datetime
import traceback

# 尝试导入 yaml，如果不存在则使用内置配置
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False
    print("⚠️  PyYAML 未安装，使用默认配置")


class ClinerRulesEnhancer:
    """规则系统增强器 - 基于现有文件工作"""
    
    def __init__(self, base_dir=".clinerules"):
        self.base_dir = Path(base_dir)
        
        # 确保基础目录存在
        if not self.base_dir.exists():
            raise FileNotFoundError(f"目录不存在: {self.base_dir}")
        
        # 读取配置
        self.config = self._load_config()
        
        # 核心文件路径
        self.error_doc = self.base_dir / "error-documentation.mdc"
        self.lessons_doc = self.base_dir / "lessons-learned.mdc"
        self.rules_doc = self.base_dir / "rules.mdc"
        self.memory_doc = self.base_dir / "memory.mdc"
        
        # 验证核心文件
        self._validate_files()
    
    def _load_config(self):
        """加载配置文件"""
        config_file = self.base_dir / "scripts" / "config.yaml"
        
        if HAS_YAML and config_file.exists():
            try:
                with open(config_file, encoding='utf-8') as f:
                    return yaml.safe_load(f)
            except Exception as e:
                print(f"⚠️  配置文件读取失败: {e}")
                return self._default_config()
        else:
            return self._default_config()
    
    def _default_config(self):
        """默认配置"""
        return {
            "analysis": {
                "min_frequency": 3,
                "min_confidence": 0.7
            },
            "auto_append": {
                "enabled": True,
                "add_timestamp": True
            },
            "advanced": {
                "backup_before_append": False,
                "max_suggestions": 5
            }
        }
    
    def _validate_files(self):
        """验证核心文件存在"""
        required_files = {
            "error-documentation.mdc": self.error_doc,
            "lessons-learned.mdc": self.lessons_doc,
            "rules.mdc": self.rules_doc,
            "memory.mdc": self.memory_doc
        }
        
        missing_files = []
        for name, path in required_files.items():
            if not path.exists():
                missing_files.append(name)
        
        if missing_files:
            print(f"⚠️  警告：以下文件不存在: {', '.join(missing_files)}")
            print("   某些功能可能无法正常工作")
    
    def analyze_errors(self):
        """分析 error-documentation.mdc 中的模式"""
        if not self.error_doc.exists():
            print("⚠️  error-documentation.mdc 不存在，跳过错误分析")
            return []
        
        try:
            content = self.error_doc.read_text(encoding='utf-8')
        except Exception as e:
            print(f"❌ 读取错误文档失败: {e}")
            return []
        
        # 提取所有错误记录（基于 ### 标题）
        errors = []
        pattern = r'### \[(.*?)\] (.*?) - (\d{4}-\d{2}-\d{2})'
        
        for match in re.finditer(pattern, content):
            category = match.group(1)
            error_pattern = match.group(2)
            date = match.group(3)
            errors.append({
                'category': category,
                'pattern': error_pattern,
                'date': date
            })
        
        if not errors:
            return []
        
        # 统计频率
        pattern_counter = Counter()
        pattern_details = defaultdict(list)
        
        for error in errors:
            key = f"{error['category']}::{error['pattern']}"
            pattern_counter[key] += 1
            pattern_details[key].append(error)
        
        # 过滤高频模式
        min_freq = self.config['analysis']['min_frequency']
        frequent = []
        
        for pattern, count in pattern_counter.items():
            if count >= min_freq:
                details = pattern_details[pattern]
                frequent.append({
                    'pattern': pattern,
                    'frequency': count,
                    'first_seen': min(d['date'] for d in details),
                    'last_seen': max(d['date'] for d in details),
                    'confidence': self._calculate_confidence(count)
                })
        
        return sorted(frequent, key=lambda x: x['frequency'], reverse=True)
    
    def _calculate_confidence(self, frequency):
        """简单的置信度计算"""
        # 频率越高，置信度越高（0.5-0.95）
        return min(0.5 + (frequency / 20) * 0.45, 0.95)
    
    def generate_suggestions(self, patterns):
        """生成改进建议"""
        if not patterns:
            return None
        
        min_conf = self.config['analysis']['min_confidence']
        high_conf = [p for p in patterns if p['confidence'] >= min_conf]
        
        if not high_conf:
            return None
        
        # 生成建议文本
        suggestions = []
        suggestions.append(f"\n## 自动分析建议 - {datetime.now().strftime('%Y-%m-%d')}\n")
        suggestions.append("\n根据错误日志分析，发现以下高频模式：\n\n")
        
        max_suggestions = self.config['advanced']['max_suggestions']
        for i, p in enumerate(high_conf[:max_suggestions], 1):
            suggestions.append(f"{i}. **{p['pattern']}**\n")
            suggestions.append(f"   - 出现频率：{p['frequency']} 次\n")
            suggestions.append(f"   - 置信度：{p['confidence']:.2f}\n")
            suggestions.append(f"   - 首次出现：{p['first_seen']}\n")
            suggestions.append(f"   - 最后出现：{p['last_seen']}\n")
            suggestions.append(f"   - **建议：** 创建预防规则，避免重复出现\n\n")
        
        suggestions.append("---\n\n")
        
        return ''.join(suggestions)
    
    def append_to_lessons(self, suggestions):
        """追加建议到 lessons-learned.mdc"""
        if not suggestions:
            return False
        
        if not self.lessons_doc.exists():
            print("⚠️  lessons-learned.mdc 不存在，跳过")
            return False
        
        try:
            # 检查是否已存在相同日期的建议
            content = self.lessons_doc.read_text(encoding='utf-8')
            today = datetime.now().strftime('%Y-%m-%d')
            
            if f"自动分析建议 - {today}" in content:
                print(f"ℹ️  今日建议已存在，跳过")
                return False
            
            # 追加到文件末尾
            with open(self.lessons_doc, 'a', encoding='utf-8') as f:
                f.write(suggestions)
            
            print(f"✅ 已追加分析建议到 lessons-learned.mdc")
            return True
            
        except Exception as e:
            print(f"❌ 追加建议失败: {e}")
            return False
    
    def generate_rule_template(self, pattern_info):
        """生成规则模板（追加到 rules.mdc）"""
        parts = pattern_info['pattern'].split('::')
        category = parts[0] if len(parts) > 0 else "未分类"
        pattern = parts[1] if len(parts) > 1 else pattern_info['pattern']
        
        template = f"\n### 🤖 自动生成规则建议 - {datetime.now().strftime('%Y-%m-%d')}\n\n"
        template += f"**类别：** {category}\n"
        template += f"**问题：** {pattern}\n"
        template += f"**频率：** {pattern_info['frequency']} 次\n"
        template += f"**置信度：** {pattern_info['confidence']:.2f}\n\n"
        
        template += "**建议规则：**\n\n"
        template += f"1. 在相关操作前，检查 {pattern} 的前置条件\n"
        template += f"2. 添加错误处理和回退机制\n"
        template += f"3. 在文档中记录该问题的解决方案\n"
        template += f"4. 考虑添加自动化测试防止回归\n\n"
        
        template += "**检查清单：**\n"
        template += "- [ ] 分析根本原因\n"
        template += "- [ ] 实施预防措施\n"
        template += "- [ ] 更新相关文档\n"
        template += "- [ ] 验证修复有效\n\n"
        
        template += "---\n\n"
        
        return template
    
    def append_rule_suggestions(self, patterns):
        """追加规则建议到 rules.mdc"""
        if not patterns:
            return 0
        
        if not self.rules_doc.exists():
            print("⚠️  rules.mdc 不存在，跳过规则建议")
            return 0
        
        try:
            content = self.rules_doc.read_text(encoding='utf-8')
            today = datetime.now().strftime('%Y-%m-%d')
            
            # 检查今日是否已生成
            if f"自动生成规则建议 - {today}" in content:
                print("ℹ️  今日规则建议已存在")
                return 0
            
            # 只为最高置信度的模式生成规则
            top_pattern = max(patterns, key=lambda x: x['confidence'])
            if top_pattern['confidence'] < self.config['analysis']['min_confidence']:
                print("ℹ️  置信度不足，跳过规则生成")
                return 0
            
            template = self.generate_rule_template(top_pattern)
            
            with open(self.rules_doc, 'a', encoding='utf-8') as f:
                f.write(template)
            
            print(f"✅ 已追加规则建议到 rules.mdc")
            return 1
            
        except Exception as e:
            print(f"❌ 追加规则建议失败: {e}")
            return 0
    
    def update_memory(self):
        """更新 memory.mdc 的统计信息"""
        if not self.memory_doc.exists():
            print("⚠️  memory.mdc 不存在，跳过统计更新")
            return
        
        try:
            patterns = self.analyze_errors()
            
            if not patterns:
                print("ℹ️  没有错误模式，跳过统计")
                return
            
            # 生成统计摘要
            summary = f"\n## 系统健康度 - {datetime.now().strftime('%Y-%m-%d')}\n\n"
            summary += f"- **总错误类型：** {len(patterns)}\n"
            summary += f"- **高频问题：** {len([p for p in patterns if p['frequency'] >= 5])}\n"
            summary += f"- **需关注：** {len([p for p in patterns if p['confidence'] >= 0.7])}\n"
            summary += f"- **状态：** {'⚠️ 需要关注' if len(patterns) > 10 else '✅ 良好'}\n\n"
            summary += "---\n\n"
            
            # 检查是否已有今日统计
            content = self.memory_doc.read_text(encoding='utf-8')
            today = datetime.now().strftime('%Y-%m-%d')
            
            if f"系统健康度 - {today}" in content:
                print("ℹ️  今日统计已存在")
                return
            
            with open(self.memory_doc, 'a', encoding='utf-8') as f:
                f.write(summary)
            
            print(f"✅ 已更新 memory.mdc 统计信息")
            
        except Exception as e:
            print(f"❌ 更新统计信息失败: {e}")
    
    def detect_environment_issues(self):
        """检测环境配置问题"""
        issues = []
        
        # 只在 Windows 上检测 PowerShell
        if platform.system() != 'Windows':
            return issues
        
        try:
            # 检测 PowerShell 版本
            ps_check = self._check_powershell_version()
            if ps_check:
                issues.append(ps_check)
            
            # 检测编码设置
            encoding_check = self._detect_encoding_issues()
            if encoding_check:
                issues.append(encoding_check)
                
        except Exception as e:
            print(f"⚠️  环境检测失败: {e}")
        
        return issues
    
    def _check_powershell_version(self):
        """检测 PowerShell 版本"""
        try:
            # 尝试检测 PowerShell 版本
            result = subprocess.run(
                ['powershell', '-Command', '$PSVersionTable.PSVersion.Major'],
                capture_output=True,
                text=True,
                timeout=3
            )
            
            if result.returncode == 0 and result.stdout.strip():
                version = int(result.stdout.strip())
                
                if version < 7:
                    return {
                        'type': '环境配置',
                        'description': f'检测到 PowerShell {version}.x',
                        'suggestion': 'PowerShell 7+ 原生支持 UTF-8',
                        'severity': 'low'
                    }
        except Exception:
            pass
        
        return None
    
    def _detect_encoding_issues(self):
        """检测编码问题 - 只在 PowerShell 5.x 时才报告"""
        try:
            # 检查 PowerShell 版本
            ps_result = subprocess.run(
                ['powershell', '-Command', '$PSVersionTable.PSVersion.Major'],
                capture_output=True,
                text=True,
                timeout=3
            )
            
            # 如果是 PowerShell 7+，不需要检查编码（已原生支持 UTF-8）
            if ps_result.returncode == 0 and ps_result.stdout.strip():
                version = int(ps_result.stdout.strip())
                if version >= 7:
                    return None
            
            # 只有在 PowerShell 5.x 时才检查系统编码
            system_encoding = locale.getpreferredencoding()
            if system_encoding.lower() not in ['utf-8', 'utf8', 'cp65001']:
                return {
                    'type': '环境配置',
                    'description': f'系统编码为 {system_encoding}',
                    'suggestion': '运行 fix-encoding.ps1 或升级到 PowerShell 7',
                    'severity': 'medium'
                }
        except Exception:
            pass
        
        return None
    
    def enhance(self):
        """执行完整的增强流程"""
        print("🔍 开始分析 .clinerules 系统...\n")
        
        try:
            # 0. 环境检测（新增）
            print("🔧 环境检测...")
            env_issues = self.detect_environment_issues()
            if env_issues:
                print("⚠️  发现环境建议：")
                for issue in env_issues:
                    print(f"   - {issue['description']}")
                    if 'suggestion' in issue:
                        print(f"     建议: {issue['suggestion']}")
                print()
            else:
                print("✓ 环境配置正常\n")
            
            # 1. 分析错误模式
            patterns = self.analyze_errors()
            print(f"📊 识别出 {len(patterns)} 个错误模式")
            
            if not patterns:
                print("✅ 没有需要处理的模式")
                return
            
            # 显示Top 5
            print("\n📋 Top 5 高频模式：")
            for i, p in enumerate(patterns[:5], 1):
                print(f"   {i}. {p['pattern']} (频率: {p['frequency']}, 置信度: {p['confidence']:.2f})")
            
            # 2. 生成并追加建议
            print("\n🤖 生成改进建议...")
            suggestions = self.generate_suggestions(patterns)
            
            if suggestions:
                self.append_to_lessons(suggestions)
            else:
                print("ℹ️  没有高置信度的建议")
            
            # 3. 生成规则建议
            print("\n📝 生成规则建议...")
            self.append_rule_suggestions(patterns)
            
            print("\n✅ 增强完成！")
            print("\n📚 请检查以下文件的更新：")
            print("   - lessons-learned.mdc")
            print("   - rules.mdc")
            print("   - memory.mdc")
            
        except Exception as e:
            print(f"\n❌ 增强过程出错: {e}")
            traceback.print_exc()
            sys.exit(1)


def main():
    """主函数"""
    try:
        # 确定基础目录
        script_dir = Path(__file__).parent
        base_dir = script_dir.parent  # .clinerules 目录
        
        print("=" * 60)
        print("  Cline 规则系统增强工具 v2.0")
        print("=" * 60)
        print()
        
        # 创建增强器实例
        enhancer = ClinerRulesEnhancer(base_dir)
        
        # 执行增强
        enhancer.enhance()
        
        # 更新记忆
        enhancer.update_memory()
        
        print()
        print("=" * 60)
        print("  完成！")
        print("=" * 60)
        
    except FileNotFoundError as e:
        print(f"❌ 文件不存在: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 发生错误: {e}")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
