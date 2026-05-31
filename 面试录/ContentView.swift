//
//  ContentView.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import SwiftUI
import SwiftData

/// 首页 - 求职记录列表
struct ContentView: View {
    // MARK: - 属性

    /// 数据库查询：按创建时间倒序排列
    @Query(sort: \JobApplication.createdAt, order: .reverse)
    private var applications: [JobApplication]

    /// 数据模型上下文
    @Environment(\.modelContext) private var modelContext

    /// 控制添加页面显示
    @State private var showAddView = false

    // MARK: - 视图主体

    var body: some View {
        NavigationStack {
            Group {
                if applications.isEmpty {
                    // 空状态视图
                    emptyStateView
                } else {
                    // 求职记录列表
                    applicationList
                }
            }
            .navigationTitle("求职记录")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddView) {
                AddApplicationView()
            }
        }
    }

    // MARK: - 子视图

    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("还没有求职记录")
                .font(.title2)
                .fontWeight(.medium)

            Text("点击右上角的 + 号添加你的第一条求职记录")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { showAddView = true }) {
                Label("添加求职记录", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
    }

    /// 求职记录列表
    private var applicationList: some View {
        List {
            ForEach(applications) { application in
                NavigationLink(destination: DetailView(application: application)) {
                    ApplicationRow(application: application)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // 左滑显示"未通过"按钮
                    Button(action: { markAsFailed(application) }) {
                        Label("未通过", systemImage: "xmark.circle.fill")
                    }
                    .tint(.red)

                    // 左滑显示"删除"按钮
                    Button(role: .destructive, action: { deleteApplication(application) }) {
                        Label("删除", systemImage: "trash.fill")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - 方法

    /// 标记为未通过
    private func markAsFailed(_ application: JobApplication) {
        application.status = .failed
        application.updatedAt = Date()
        try? modelContext.save()
    }

    /// 删除求职记录
    private func deleteApplication(_ application: JobApplication) {
        modelContext.delete(application)
        try? modelContext.save()
    }
}

// MARK: - 求职记录行视图

/// 列表中的单条求职记录
struct ApplicationRow: View {
    /// 求职申请数据
    let application: JobApplication

    /// 数据模型上下文
    @Environment(\.modelContext) private var modelContext

    /// 计算当前状态（根据面试轮次结果动态判断）
    private var currentStatus: (text: String, color: Color) {
        let interviewRounds = application.interviewRounds ?? []

        // 检查是否有 Offer 且已通过
        let hasOfferPassed = interviewRounds.contains { round in
            round.roundName.lowercased().contains("offer") && round.result == .passed
        }

        // 检查是否有未通过或已取消的面试
        let hasFailed = interviewRounds.contains { round in
            round.result == .failed || round.result == .cancelled
        }

        // 检查求职申请本身是否被标记为未通过
        let isApplicationFailed = application.status == .failed

        // 判断状态
        if hasOfferPassed {
            return ("已通过", .green)
        } else if hasFailed || isApplicationFailed {
            return ("已拒绝", .red)
        } else {
            return ("流程中", .orange)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 第一行：公司名、岗位、日期、状态
            HStack(alignment: .center) {
                // 左侧：公司名·岗位·日期
                HStack(spacing: 4) {
                    Text(application.companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text("·")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(application.positionName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text("·")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(application.appliedDate.formatted(.dateTime.month().day()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 右侧：状态标签
                Text(currentStatus.text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(currentStatus.color.opacity(0.15))
                    .foregroundColor(currentStatus.color)
                    .clipShape(Capsule())
            }

            // 第二行：流程进度条
            ProcessFlowView(
                status: application.status,
                interviewRounds: application.interviewRounds ?? []
            )
        }
        .padding(.vertical, 6)
    }
}

// MARK: - 状态标签

/// 显示求职状态的彩色标签
struct StatusBadge: View {
    /// 求职状态
    let status: ApplicationStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.15))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }

    /// 状态对应的背景颜色
    private var backgroundColor: Color {
        switch status {
        case .applied:
            return .blue
        case .writtenTest:
            return .purple
        case .interviewing:
            return .orange
        case .offer:
            return .green
        case .rejected:
            return .gray
        case .failed:
            return .red
        }
    }
}

// MARK: - 流程进度条

/// 显示求职流程进度的组件
struct ProcessFlowView: View {
    /// 当前状态
    let status: ApplicationStatus

    /// 面试轮次列表
    let interviewRounds: [InterviewRound]

    /// 检查是否有 Offer 且已通过
    private var hasOfferPassed: Bool {
        interviewRounds.contains { round in
            round.roundName.lowercased().contains("offer") && round.result == .passed
        }
    }

    /// 检查是否有未通过或已取消的面试
    private var hasFailed: Bool {
        interviewRounds.contains { round in
            round.result == .failed || round.result == .cancelled
        }
    }

    /// 动态计算流程步骤
    private var processSteps: [ProcessStep] {
        var steps: [ProcessStep] = []

        // 第一步：已投递（总是显示）
        steps.append(ProcessStep(name: "已投递", icon: "paperplane.fill"))

        // 如果状态是笔试，添加笔试步骤
        if status == .writtenTest {
            steps.append(ProcessStep(name: "笔试", icon: "pencil.and.list.clipboard"))
        }

        // 根据面试轮次添加步骤
        let sortedRounds = interviewRounds.sorted(by: { $0.interviewDate < $1.interviewDate })

        for (index, round) in sortedRounds.enumerated() {
            // 使用轮次名称，如果没有则使用默认名称
            let roundName = round.roundName.isEmpty ? "第\(index + 1)面" : round.roundName
            let icon = index == 0 ? "person.fill" : "person.2.fill"
            steps.append(ProcessStep(name: roundName, icon: icon))
        }

        return steps
    }

    /// 当前进行的步骤索引（最后一步）
    private var currentStepIndex: Int {
        return processSteps.count - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 进度条
            HStack(spacing: 0) {
                ForEach(Array(processSteps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 0) {
                        // 步骤圆点
                        ProcessStepCircle(
                            step: step,
                            index: index,
                            currentIndex: currentStepIndex,
                            isFailed: hasFailed,
                            isLastStep: index == processSteps.count - 1,
                            isOffer: hasOfferPassed && index == processSteps.count - 1
                        )

                        // 连接线（最后一个不显示）
                        if index < processSteps.count - 1 {
                            ProcessStepLine(
                                isCurrent: index == currentStepIndex - 1,
                                isFailed: hasFailed,
                                isCompleted: index < currentStepIndex - 1
                            )
                        }
                    }
                }
            }
        }
    }
}

/// 流程步骤定义
struct ProcessStep {
    let name: String
    let icon: String
}

/// 流程步骤圆点
struct ProcessStepCircle: View {
    let step: ProcessStep
    let index: Int
    let currentIndex: Int
    let isFailed: Bool
    let isLastStep: Bool
    let isOffer: Bool

    var body: some View {
        VStack(spacing: 2) {
            // 圆点
            ZStack {
                // 背景圆
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 20, height: 20)

                // 图标或emoji
                if isOffer && isLastStep {
                    // Offer且已通过：显示信封✉️
                    Text("✉️")
                        .font(.system(size: 10))
                } else if isFailed && isLastStep {
                    // 面试失败：显示红色叉叉❌
                    Text("❌")
                        .font(.system(size: 10))
                } else {
                    // 其他状态显示图标
                    Image(systemName: step.icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(iconColor)
                }
            }
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: 1.5)
            )

            // 步骤名称
            Text(step.name)
                .font(.system(size: 8))
                .foregroundColor(textColor)
                .lineLimit(1)
        }
        .frame(minWidth: 30)
    }

    /// 背景颜色
    private var backgroundColor: Color {
        if isOffer && isLastStep {
            // Offer且已通过：绿色
            return .green.opacity(0.3)
        } else if isFailed && isLastStep {
            // 面试失败：红色
            return .red.opacity(0.2)
        } else if isLastStep {
            // 当前进行的步骤：橙色
            return .orange.opacity(0.2)
        } else {
            // 已完成的步骤：灰色
            return .gray.opacity(0.15)
        }
    }

    /// 图标颜色
    private var iconColor: Color {
        if isOffer && isLastStep {
            return .green
        } else if isFailed && isLastStep {
            return .red
        } else if isLastStep {
            return .orange
        } else {
            return .gray
        }
    }

    /// 边框颜色
    private var borderColor: Color {
        if isOffer && isLastStep {
            return .green
        } else if isFailed && isLastStep {
            return .red
        } else if isLastStep {
            return .orange
        } else {
            return .gray.opacity(0.5)
        }
    }

    /// 文字颜色
    private var textColor: Color {
        if isOffer && isLastStep {
            return .green
        } else if isFailed && isLastStep {
            return .red
        } else if isLastStep {
            return .orange
        } else {
            return .gray
        }
    }
}

/// 流程步骤连接线
struct ProcessStepLine: View {
    let isCurrent: Bool
    let isFailed: Bool
    let isCompleted: Bool

    var body: some View {
        Rectangle()
            .fill(lineColor)
            .frame(width: 20, height: 2)
            .padding(.bottom, 16) // 为文字留出空间
    }

    /// 线条颜色
    private var lineColor: Color {
        if isFailed {
            return .red
        } else if isCurrent {
            return .orange
        } else if isCompleted {
            return .gray.opacity(0.5)
        } else {
            return .gray.opacity(0.3)
        }
    }
}

// MARK: - 预览

#Preview {
    ContentView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
