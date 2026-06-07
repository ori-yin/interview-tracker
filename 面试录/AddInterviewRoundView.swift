//
//  AddInterviewRoundView.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import SwiftUI
import SwiftData

/// 添加面试轮次页面
struct AddInterviewRoundView: View {
    // MARK: - 属性

    /// 关联的求职申请
    let application: JobApplication

    /// 数据模型上下文
    @Environment(\.modelContext) private var modelContext

    /// 关闭页面
    @Environment(\.dismiss) private var dismiss

    // MARK: - 表单数据

    /// 轮次名称
    @State private var roundName = ""

    /// 面试日期
    @State private var interviewDate = Date()

    /// 面试官
    @State private var interviewer = ""

    /// 本轮结果
    @State private var result: InterviewResult = .pending

    /// 面试反馈
    @State private var feedback = ""

    // MARK: - 验证状态

    /// 是否显示验证错误
    @State private var showValidation = false

    // MARK: - 预设轮次名称

    /// 常用轮次名称
    private let presetRoundNames = [
        "一面",
        "二面",
        "三面",
        "交叉面",
        "HR面",
        "笔试",
        "Offer"
    ]

    // MARK: - 计算属性

    /// 表单是否有效
    private var isFormValid: Bool {
        !roundName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - 视图主体

    var body: some View {
        NavigationStack {
            Form {
                // 轮次名称
                Section {
                    // 预设名称选择
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(presetRoundNames, id: \.self) { name in
                                Button(action: { roundName = name }) {
                                    Text(name)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            roundName == name
                                                ? Color.accentColor
                                                : Color.secondary.opacity(0.15)
                                        )
                                        .foregroundColor(
                                            roundName == name
                                                ? .white
                                                : .primary
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // 自定义输入
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("或输入自定义轮次名称 *", text: $roundName)
                            .font(.body)

                        if showValidation && roundName.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("请输入轮次名称")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("轮次名称")
                } footer: {
                    Text("可以选择预设名称，也可以输入自定义名称（如：交叉面、HR面等）")
                }

                // 面试信息
                Section("面试信息") {
                    // 面试日期
                    DatePicker(
                        "面试日期",
                        selection: $interviewDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    // 面试官
                    TextField("面试官（可选）", text: $interviewer)
                        .font(.body)

                    // 本轮结果
                    Picker("本轮结果", selection: $result) {
                        ForEach(InterviewResult.allCases, id: \.self) { result in
                            HStack {
                                Image(systemName: result.iconName)
                                Text(result.rawValue)
                            }
                            .tag(result)
                        }
                    }
                }

                // 面试反馈
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("面试反馈（可选）")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextEditor(text: $feedback)
                            .frame(minHeight: 100)
                            .font(.body)
                    }
                } header: {
                    Text("反馈记录")
                } footer: {
                    Text("记录面试中的问题、你的表现、面试官的反馈等")
                }
            }
            .navigationTitle("添加面试记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveInterviewRound()
                    }
                    .disabled(!isFormValid && showValidation)
                }
            }
        }
    }

    // MARK: - 方法

    /// 保存面试轮次
    private func saveInterviewRound() {
        // 显示验证错误
        showValidation = true

        // 验证表单
        guard isFormValid else {
            return
        }

        // 创建面试轮次
        let round = InterviewRound(
            roundName: roundName.trimmingCharacters(in: .whitespaces),
            interviewDate: interviewDate,
            interviewer: interviewer.trimmingCharacters(in: .whitespaces).isEmpty ? nil : interviewer.trimmingCharacters(in: .whitespaces),
            result: result,
            feedback: feedback.trimmingCharacters(in: .whitespaces).isEmpty ? nil : feedback.trimmingCharacters(in: .whitespaces)
        )

        // 关联到求职申请
        round.application = application

        // 插入到数据库
        modelContext.insert(round)

        // 更新求职申请的更新时间
        application.updatedAt = Date()

        // 保存更改
        try? modelContext.save()

        // 关闭页面
        dismiss()
    }
}

// MARK: - 预览

#Preview {
    AddInterviewRoundView(application: JobApplication.preview)
        .modelContainer(for: JobApplication.self, inMemory: true)
}
