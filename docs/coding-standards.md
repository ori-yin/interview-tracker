# 面试录 - 开发规范文档

## 代码规范

### 命名规范

#### 文件命名
- **视图文件**：`XXXView.swift`（如 `ContentView.swift`）
- **模型文件**：`Models.swift` 或 `XXXModel.swift`
- **工具文件**：`XXXHelper.swift` 或 `XXXManager.swift`

#### 类型命名
- **类/结构体**：大驼峰（`JobApplication`）
- **枚举**：大驼峰（`ApplicationStatus`）
- **协议**：大驼峰，可加 `Protocol` 后缀（`CellConfigurable`）

#### 变量/常量命名
- **变量**：小驼峰（`companyName`）
- **常量**：小驼峰（`maxRetryCount`）
- **布尔值**：以 `is` 开头（`isActive`）

#### 方法命名
- **方法**：小驼峰，动词开头（`fetchData()`）
- **闭包**：使用动名词（`completionHandler`）

---

### 代码风格

#### 缩进和空格
- 使用 4 个空格缩进
- 运算符前后加空格
- 逗号后加空格

```swift
// ✅ 正确
let x = 1 + 2
let array = [1, 2, 3]

// ❌ 错误
let x=1+2
let array = [1,2,3]
```

#### 行长度
- 每行不超过 120 个字符
- 长行在运算符后换行

```swift
// ✅ 正确
let result = someLongVariable +
    anotherLongVariable +
    thirdLongVariable

// ❌ 错误
let result = someLongVariable + anotherLongVariable + thirdLongVariable
```

#### 空行
- 方法之间加一个空行
- 逻辑块之间加一个空行
- 文件末尾加一个空行

---

### 注释规范

#### 文件头注释
```swift
//
//  FileName.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//
```

#### MARK 注释
```swift
// MARK: - 属性

// MARK: - 生命周期

// MARK: - 公开方法

// MARK: - 私有方法

// MARK: - 辅助方法
```

#### 文档注释
```swift
/// 求职申请记录
///
/// 用于存储单个求职申请的完整信息
@Model
final class JobApplication {
    /// 公司名称
    var companyName: String
    
    /// 岗位名称
    var positionName: String
}
```

---

## SwiftUI 视图规范

### 视图结构

#### 基本结构
```swift
struct SomeView: View {
    // MARK: - 属性
    
    @State private var someProperty = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 视图主体
    
    var body: some View {
        // 主要内容
    }
    
    // MARK: - 子视图
    
    private var headerView: some View {
        // 子视图内容
    }
    
    // MARK: - 方法
    
    private func someMethod() {
        // 方法实现
    }
}
```

#### 预览结构
```swift
#Preview {
    SomeView()
}
```

---

### 视图组织

#### 提取子视图
当闭包超过 10 行时，提取为子视图：

```swift
// ❌ 不好：过长的闭包
var body: some View {
    VStack {
        // 20 行代码...
    }
}

// ✅ 好：提取子视图
var body: some View {
    VStack {
        headerView
        contentView
        footerView
    }
}

private var headerView: some View {
    // 头部视图
}

private var contentView: some View {
    // 内容视图
}

private var footerView: some View {
    // 底部视图
}
```

#### 使用 ViewModifier
复用样式：

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// 使用
Text("Hello")
    .cardStyle()
```

---

## SwiftData 规范

### 模型定义

#### 使用 @Model 宏
```swift
@Model
final class JobApplication {
    var id: UUID
    var companyName: String
    // ...
}
```

#### 关系定义
```swift
// 一对多关系
@Relationship(deleteRule: .cascade, inverse: \InterviewRound.application)
var interviewRounds: [InterviewRound]?

// 多对一关系
var application: JobApplication?
```

#### 删除规则
- `.cascade`：级联删除（删除主表时删除子表）
- `.nullify`：置空（删除主表时子表外键置空）
- `.deny`：禁止删除（有子记录时禁止删除）

---

### 数据操作

#### 查询数据
```swift
@Query private var applications: [JobApplication]

// 带排序
@Query(sort: \.createdAt, order: .reverse) 
private var applications: [JobApplication]

// 带过滤
@Query(filter: #Predicate<JobApplication> { $0.status == .interviewing })
private var activeApplications: [JobApplication]
```

#### 插入数据
```swift
@Environment(\.modelContext) private var modelContext

func addApplication() {
    let app = JobApplication(companyName: "公司名", positionName: "岗位名")
    modelContext.insert(app)
    try? modelContext.save()
}
```

#### 删除数据
```swift
func deleteApplication(_ app: JobApplication) {
    modelContext.delete(app)
    try? modelContext.save()
}
```

#### 更新数据
```swift
func updateApplication(_ app: JobApplication) {
    app.updatedAt = Date()
    try? modelContext.save()
}
```

---

## 项目结构规范

### 文件组织
```
面试录/
├── 面试录App.swift          # App 入口
├── ContentView.swift         # 首页
├── Models.swift              # 数据模型
├── Views/
│   ├── ApplicationRow.swift  # 列表行视图
│   ├── DetailView.swift      # 详情页
│   ├── AddApplicationView.swift
│   └── AddInterviewRoundView.swift
├── Components/
│   ├── StatusBadge.swift     # 状态标签
│   └── EmptyStateView.swift  # 空状态视图
├── Extensions/
│   └── Date+Extension.swift  # 日期扩展
├── Assets.xcassets           # 资源文件
└── Preview Content/          # 预览资源
```

### 命名约定
- **视图文件**：以 `View` 结尾
- **组件文件**：描述性命名
- **扩展文件**：以 `+Extension` 结尾

---

## Git 提交规范

### 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型
- `feat`：新功能
- `fix`：修复 bug
- `docs`：文档更新
- `style`：代码格式调整
- `refactor`：重构
- `test`：测试相关
- `chore`：构建/工具相关

### 示例
```
feat(models): 添加求职申请数据模型

- 定义 JobApplication 模型
- 定义 InterviewRound 模型
- 定义 ApplicationStatus 枚举
- 定义 InterviewResult 枚举

Closes #1
```

---

## 测试规范

### 单元测试
- 测试文件以 `Tests.swift` 结尾
- 测试方法以 `test` 开头
- 使用 `XCTest` 框架

```swift
import XCTest
@testable import 面试录

final class JobApplicationTests: XCTestCase {
    func testInitialization() {
        let app = JobApplication(
            companyName: "测试公司",
            positionName: "测试岗位"
        )
        
        XCTAssertEqual(app.companyName, "测试公司")
        XCTAssertEqual(app.positionName, "测试岗位")
        XCTAssertEqual(app.status, .applied)
    }
}
```

### UI 测试
- 使用 XCUITest
- 测试关键用户流程
- 验证 UI 元素存在和可交互

---

## 性能规范

### 列表优化
- 使用 `LazyVStack` 或 `List`
- 避免在 `body` 中进行复杂计算
- 使用 `@State` 缓存计算结果

### 内存管理
- 避免循环引用
- 使用 `weak` 或 `unowned`
- 及时释放不需要的资源

### 数据加载
- 使用 `@Query` 自动更新
- 避免一次性加载大量数据
- 实现分页加载

---

## 设计规范

### 颜色系统
- 使用系统颜色（`Color.primary`、`Color.secondary`）
- 支持深色模式
- 使用语义化颜色（`Color.accentColor`）

### 字体系统
- 使用系统字体（`.body`、`.headline`）
- 支持 Dynamic Type
- 避免硬编码字体大小

### 间距系统
- 使用 8pt 网格系统
- 标准间距：8、16、24、32
- 组件内边距：8-16pt

### 圆角系统
- 小组件：8pt
- 卡片：12pt
- 按钮：8pt
- 全圆角：`.capsule`

---

## 文档规范

### 代码文档
- 公开 API 必须有文档注释
- 复杂逻辑必须有说明
- 参数和返回值必须描述

### 项目文档
- README.md：项目介绍
- CHANGELOG.md：版本更新记录
- CONTRIBUTING.md：贡献指南

### 开发日志
- 每天记录开发事项
- 记录问题和解决方案
- 记录待办事项

---

## 工具配置

### Xcode 配置
- 启用代码补全
- 启用语法检查
- 配置代码格式化

### 代码格式化
- 使用 SwiftFormat
- 统一代码风格
- 自动格式化提交

### 静态分析
- 使用 SwiftLint
- 检查代码质量
- 强制编码规范
