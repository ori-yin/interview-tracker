# 面试录 - 项目指引

## 项目概述

**项目名称**：面试录（Job Interview Tracker）

**项目目标**：开发一个简洁、实用的 iOS 求职记录管理应用，帮助求职者追踪和管理面试进度。

**技术栈**：
- UI 框架：SwiftUI
- 数据持久化：SwiftData (iOS 17+)
- 最低支持版本：iOS 17.0
- 开发语言：Swift 5.9+

---

## 核心红线（必须严格遵守）

### ✅ 必须遵守
1. **纯本地运行**：所有数据必须存储在用户手机本地
2. **禁止云端数据库**：严禁使用 Firebase、CloudKit 等
3. **禁止用户系统**：严禁添加登录/注册功能
4. **禁止网络请求**：严禁引入 Alamofire 等网络库
5. **原生 UI**：仅使用 SwiftUI，不使用 UIKit
6. **无第三方库**：不使用第三方 UI 库

### ❌ 严禁事项
- 添加任何形式的网络请求
- 使用云端数据库同步
- 引入第三方依赖
- 使用 UIKit 组件

---

## 项目结构

```
面试录/
├── 面试录/                    # 源代码目录
│   ├── 面试录App.swift        # App 入口
│   ├── ContentView.swift      # 首页
│   ├── Models.swift           # 数据模型
│   └── Assets.xcassets        # 资源文件
├── 面试录.xcodeproj           # Xcode 项目文件
├── dev-log/                   # 开发日志目录
│   └── YYYY-MM-DD.md         # 每日开发日志
├── docs/                      # 项目文档目录
│   ├── requirements.md        # 需求文档
│   ├── development-plan.md    # 开发步骤规划
│   └── coding-standards.md    # 开发规范
└── CLAUDE.md                  # 项目指引（本文件）
```

---

## 文档索引

### 📋 项目文档
- **[需求文档](docs/requirements.md)**：项目需求、功能定义、技术约束
- **[开发步骤规划](docs/development-plan.md)**：分阶段开发计划、任务清单、验收标准
- **[开发规范](docs/coding-standards.md)**：代码风格、命名规范、Git 提交规范

### 📝 开发日志
- **[2026-05-31](dev-log/2026-05-31.md)**：项目初始化、数据模型设计

---

## 开发原则

### 稳定推进
- **小步快跑**：每次只开发一个功能模块
- **及时验证**：每个步骤完成后进行测试
- **保持整洁**：随时重构，保持代码质量

### 安全开发
- **版本控制**：每个功能完成前提交 Git
- **备份数据**：重要修改前备份模型
- **渐进式开发**：先实现核心功能，再优化体验

### 有效迭代
- **用户反馈**：每完成一个功能后确认
- **问题优先**：发现问题立即修复
- **文档同步**：代码和文档同步更新

---

## 开发流程

### 每个步骤的标准流程

1. **阅读需求**
   - 查看 `docs/development-plan.md` 了解当前任务
   - 查看 `docs/requirements.md` 了解详细需求

2. **编写代码**
   - 遵循 `docs/coding-standards.md` 的代码规范
   - 使用 SwiftUI 和 SwiftData
   - 保持代码简洁可读

3. **测试验证**
   - 确保编译通过
   - 测试功能正常
   - 检查边界情况

4. **提交代码**
   - 使用规范的 Git 提交信息
   - 提交前检查代码质量

5. **更新日志**
   - 在 `dev-log/YYYY-MM-DD.md` 记录完成事项
   - 更新待办事项

6. **汇报用户**
   - 向用户汇报完成情况
   - 等待用户确认后再继续

---

## 当前进度

### ✅ 已完成
- [x] 项目初始化
- [x] 数据模型设计（`Models.swift`）
- [x] 开发日志建立（`dev-log/`）
- [x] 项目文档建立（`docs/`）
- [x] 首页开发（`ContentView.swift`）
- [x] 添加求职记录页面（`AddApplicationView.swift`）
- [x] 详情页开发（`DetailView.swift`）
- [x] 添加面试轮次页面（`AddInterviewRoundView.swift`）
- [x] App 入口配置（`___App.swift`）

### 🔄 进行中
- [ ] 测试和验证所有功能

### 📌 下一步
- [ ] 测试基础功能是否正常
- [ ] 优化 UI 细节和动画效果
- [ ] 添加深色模式支持
- [ ] 性能优化和测试

---

## 技能使用指南

### 可用技能
本项目安装了 4 个 SwiftUI 开发技能，用于提高代码质量和设计水平：

#### 1. `xcode` - Xcode 项目管理
- **用途**：项目配置、构建、调试、签名
- **使用场景**：遇到构建问题、需要配置项目时
- **文档**：`~/.agents/skills/xcode/skill.md`

#### 2. `swiftui-view-refactor` - 视图重构专家
- **用途**：提取组件、优化视图结构、改善可读性
- **使用场景**：视图文件过大、需要重构时
- **文档**：`~/.agents/skills/swiftui-view-refactor/skill.md`

#### 3. `swiftui-ui-patterns` - UI 设计模式库
- **用途**：常用界面模式、架构模式、最佳实践
- **使用场景**：设计新页面、选择架构模式时
- **文档**：`~/.agents/skills/swiftui-ui-patterns/skill.md`

#### 4. `swiftui-liquid-glass` - Liquid Glass 特效
- **用途**：玻璃态、模糊效果、动态光影、高级动画
- **使用场景**：需要视觉特效、动画效果时
- **文档**：`~/.agents/skills/swiftui-liquid-glass/skill.md`

### 技能使用原则
- **按需使用**：根据任务类型选择合适的技能
- **参考最佳实践**：遵循技能中的设计模式和规范
- **保持一致性**：整个项目使用统一的设计风格

---

## 工作说明

### 每次对话开始时
1. 阅读本文件（`CLAUDE.md`）了解项目状态
2. 查看 `dev-log/` 目录了解最新进度
3. 查看 `docs/development-plan.md` 了解当前任务

### 开发过程中
1. 遵循开发原则和流程
2. 遵循代码规范和设计规范
3. 及时更新文档和日志
4. 遇到问题及时沟通

### 每个步骤完成后
1. 测试验证功能正常
2. 提交代码到 Git
3. 更新开发日志
4. 向用户汇报并等待确认

### 重要决策前
1. 查阅相关文档
2. 评估技术方案
3. 征求用户意见
4. 记录决策过程

---

## 常见问题

### Q: 如何开始新的开发任务？
A: 
1. 查看 `docs/development-plan.md` 找到下一个任务
2. 阅读任务说明和验收标准
3. 按照开发流程执行
4. 完成后更新日志并汇报

### Q: 遇到技术问题怎么办？
A:
1. 查阅相关技能文档（`~/.agents/skills/`）
2. 搜索 Apple 官方文档
3. 尝试简化问题
4. 记录问题和解决方案

### Q: 如何保证代码质量？
A:
1. 遵循 `docs/coding-standards.md` 的规范
2. 使用技能中的最佳实践
3. 及时重构和优化
4. 测试验证功能

### Q: 如何处理需求变更？
A:
1. 评估变更影响
2. 更新需求文档
3. 调整开发计划
4. 与用户确认后再执行

---

## 联系与支持

### 项目负责人
- **开发者**：Ori
- **开始日期**：2026-05-31

### 文档更新
- 本文件最后更新：2026-05-31
- 保持文档与代码同步更新

---

## 附录

### 快速参考

#### 常用命令
```bash
# 查看项目状态
git status

# 提交代码
git add .
git commit -m "feat(scope): description"

# 查看开发日志
cat dev-log/2026-05-31.md

# 查看需求文档
cat docs/requirements.md
```

#### 常用路径
- 源代码：`面试录/`
- 开发日志：`dev-log/`
- 项目文档：`docs/`
- 技能文档：`~/.agents/skills/`

#### 相关资源
- [SwiftUI 官方文档](https://developer.apple.com/xcode/swiftui/)
- [SwiftData 官方文档](https://developer.apple.com/xcode/swiftdata/)
- [iOS 设计规范](https://developer.apple.com/design/human-interface-guidelines/)
