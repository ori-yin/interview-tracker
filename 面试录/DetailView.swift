//
//  DetailView.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import SwiftUI
import SwiftData

/// 求职记录详情页
struct DetailView: View {
    // MARK: - 属性

    /// 求职申请数据
    let application: JobApplication

    /// 数据模型上下文
    @Environment(\.modelContext) private var modelContext

    /// 控制添加面试轮次页面显示
    @State private var showAddRound = false

    /// 控制编辑页面显示
    @State private var showEditView = false

    /// 控制删除确认对话框
    @State private var showDeleteAlert = false

    // MARK: - 视图主体

    var body: some View {
        List {
            // 基本信息卡片
            basicInfoSection

            // 面试轮次列表
            interviewRoundsSection

            // 添加面试轮次按钮
            addRoundButtonSection
        }
        .navigationTitle(application.companyName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("编辑", systemImage: "pencil") {
                        showEditView = true
                    }

                    Divider()

                    Button("删除", systemImage: "trash", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showAddRound) {
            AddInterviewRoundView(application: application)
        }
        .sheet(isPresented: $showEditView) {
            EditApplicationView(application: application)
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                deleteApplication()
            }
        } message: {
            Text("确定要删除这条求职记录吗？删除后无法恢复。")
        }
    }

    // MARK: - 子视图

    /// 基本信息卡片
    private var basicInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // 公司名和状态
                HStack {
                    Text(application.companyName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    StatusBadge(status: application.status)
                }

                // 岗位名
                Text(application.positionName)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Divider()

                // 详细信息
                VStack(alignment: .leading, spacing: 8) {
                    // 投递日期
                    DetailRow(
                        icon: "calendar",
                        title: "投递日期",
                        value: application.appliedDate.formatted(.dateTime.year().month().day())
                    )

                    // 工作地点
                    if let location = application.location, !location.isEmpty {
                        DetailRow(
                            icon: "mappin.circle.fill",
                            title: "工作地点",
                            value: location
                        )
                    }

                    // 薪资范围
                    if let salary = application.salaryRange, !salary.isEmpty {
                        DetailRow(
                            icon: "yensign.circle.fill",
                            title: "薪资范围",
                            value: salary
                        )
                    }

                    // 备注
                    if let notes = application.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("备注", systemImage: "note.text")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(notes)
                                .font(.body)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("基本信息")
        }
    }

    /// 面试轮次列表
    private var interviewRoundsSection: some View {
        Section {
            if let rounds = application.interviewRounds, !rounds.isEmpty {
                ForEach(rounds.sorted(by: { $0.interviewDate > $1.interviewDate })) { round in
                    InterviewRoundRow(round: round)
                }
                .onDelete(perform: deleteRounds)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("暂无面试记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        } header: {
            HStack {
                Text("面试轮次")

                Spacer()

                if let rounds = application.interviewRounds, !rounds.isEmpty {
                    Text("\(rounds.count) 轮")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    /// 添加面试轮次按钮
    private var addRoundButtonSection: some View {
        Section {
            Button(action: { showAddRound = true }) {
                Label("添加面试记录", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    // MARK: - 方法

    /// 删除求职记录
    private func deleteApplication() {
        modelContext.delete(application)
        try? modelContext.save()
    }

    /// 删除面试轮次
    private func deleteRounds(at offsets: IndexSet) {
        guard let rounds = application.interviewRounds else { return }

        let sortedRounds = rounds.sorted(by: { $0.interviewDate > $1.interviewDate })

        for index in offsets {
            let round = sortedRounds[index]
            modelContext.delete(round)
        }

        try? modelContext.save()
    }
}

// MARK: - 面试轮次行视图

/// 单条面试轮次记录
struct InterviewRoundRow: View {
    /// 面试轮次数据
    let round: InterviewRound

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 第一行：轮次名称和结果
            HStack {
                Text(round.roundName)
                    .font(.headline)

                Spacer()

                InterviewResultBadge(result: round.result)
            }

            // 第二行：日期
            Label(
                round.interviewDate.formatted(.dateTime.month().day().hour().minute()),
                systemImage: "calendar"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)

            // 第三行：面试官（如果有）
            if let interviewer = round.interviewer, !interviewer.isEmpty {
                Label(interviewer, systemImage: "person.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 第四行：反馈（如果有）
            if let feedback = round.feedback, !feedback.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("面试反馈")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(feedback)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 面试结果标签

/// 显示面试结果的彩色标签
struct InterviewResultBadge: View {
    /// 面试结果
    let result: InterviewResult

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: result.iconName)
                .font(.caption2)

            Text(result.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .clipShape(Capsule())
    }

    /// 结果对应的背景颜色
    private var backgroundColor: Color {
        switch result {
        case .pending:
            return .orange
        case .passed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .gray
        }
    }
}

// MARK: - 详情行视图

/// 显示单条详情信息
struct DetailRow: View {
    /// 图标名称
    let icon: String

    /// 标题
    let title: String

    /// 值
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - 编辑求职记录页面

/// 编辑求职记录页面
struct EditApplicationView: View {
    // MARK: - 属性

    /// 求职申请数据
    let application: JobApplication

    /// 关闭页面
    @Environment(\.dismiss) private var dismiss

    // MARK: - 表单数据

    @State private var companyName: String = ""
    @State private var positionName: String = ""
    @State private var status: ApplicationStatus = .applied
    @State private var appliedDate: Date = Date()
    @State private var location: String = ""
    @State private var salaryRange: String = ""
    @State private var notes: String = ""

    // MARK: - 视图主体

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("公司名称", text: $companyName)
                    TextField("岗位名称", text: $positionName)

                    Picker("当前状态", selection: $status) {
                        ForEach(ApplicationStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }

                    DatePicker("投递日期", selection: $appliedDate, displayedComponents: .date)
                }

                Section("可选信息") {
                    TextField("工作地点", text: $location)
                    TextField("薪资范围", text: $salaryRange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("备注")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextEditor(text: $notes)
                            .frame(minHeight: 60)
                    }
                }
            }
            .navigationTitle("编辑求职记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    // MARK: - 方法

    /// 加载现有数据
    private func loadData() {
        companyName = application.companyName
        positionName = application.positionName
        status = application.status
        appliedDate = application.appliedDate
        location = application.location ?? ""
        salaryRange = application.salaryRange ?? ""
        notes = application.notes ?? ""
    }

    /// 保存更改
    private func saveChanges() {
        application.companyName = companyName.trimmingCharacters(in: .whitespaces)
        application.positionName = positionName.trimmingCharacters(in: .whitespaces)
        application.status = status
        application.appliedDate = appliedDate
        application.location = location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location.trimmingCharacters(in: .whitespaces)
        application.salaryRange = salaryRange.trimmingCharacters(in: .whitespaces).isEmpty ? nil : salaryRange.trimmingCharacters(in: .whitespaces)
        application.notes = notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
        application.updatedAt = Date()

        try? application.modelContext?.save()

        dismiss()
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        DetailView(application: JobApplication.preview)
    }
    .modelContainer(for: JobApplication.self, inMemory: true)
}
