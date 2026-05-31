//
//  AddApplicationView.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import SwiftUI
import SwiftData

/// 添加求职记录页面
struct AddApplicationView: View {
    // MARK: - 属性

    /// 数据模型上下文
    @Environment(\.modelContext) private var modelContext

    /// 关闭页面
    @Environment(\.dismiss) private var dismiss

    // MARK: - 表单数据

    /// 公司名称
    @State private var companyName = ""

    /// 岗位名称
    @State private var positionName = ""

    /// 投递日期
    @State private var appliedDate = Date()

    /// 工作地点
    @State private var location = ""

    /// 薪资范围
    @State private var salaryRange = ""

    /// 备注
    @State private var notes = ""

    // MARK: - 验证状态

    /// 是否显示验证错误
    @State private var showValidation = false

    // MARK: - 计算属性

    /// 表单是否有效
    private var isFormValid: Bool {
        !companyName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !positionName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - 视图主体

    var body: some View {
        NavigationStack {
            Form {
                // 必填信息
                Section {
                    // 公司名称
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("公司名称 *", text: $companyName)
                            .font(.body)

                        if showValidation && companyName.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("请输入公司名称")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 岗位名称
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("岗位名称 *", text: $positionName)
                            .font(.body)

                        if showValidation && positionName.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("请输入岗位名称")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // 投递日期
                    DatePicker(
                        "投递日期",
                        selection: $appliedDate,
                        displayedComponents: .date
                    )
                } header: {
                    Text("必填信息")
                } footer: {
                    Text("* 表示必填项")
                }

                // 可选信息
                Section("可选信息") {
                    // 工作地点
                    TextField("工作地点", text: $location)
                        .font(.body)

                    // 薪资范围
                    TextField("薪资范围（如 25K-40K）", text: $salaryRange)
                        .font(.body)

                    // 备注
                    VStack(alignment: .leading, spacing: 4) {
                        Text("备注")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("添加求职记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveApplication()
                    }
                    .disabled(!isFormValid && showValidation)
                }
            }
        }
    }

    // MARK: - 方法

    /// 保存求职记录
    private func saveApplication() {
        // 显示验证错误
        showValidation = true

        // 验证表单
        guard isFormValid else {
            return
        }

        // 创建求职记录
        let application = JobApplication(
            companyName: companyName.trimmingCharacters(in: .whitespaces),
            positionName: positionName.trimmingCharacters(in: .whitespaces),
            status: .applied,
            appliedDate: appliedDate,
            location: location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location.trimmingCharacters(in: .whitespaces),
            salaryRange: salaryRange.trimmingCharacters(in: .whitespaces).isEmpty ? nil : salaryRange.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces)
        )

        // 插入到数据库
        modelContext.insert(application)

        // 保存更改
        try? modelContext.save()

        // 关闭页面
        dismiss()
    }
}

// MARK: - 预览

#Preview {
    AddApplicationView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
