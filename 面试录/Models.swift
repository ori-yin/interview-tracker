//
//  Models.swift
//  面试录
//
//  Created by ori_mac on 2026/5/31.
//

import Foundation
import SwiftData

// MARK: - 求职申请状态枚举

/// 求职申请的整体状态
enum ApplicationStatus: String, Codable, CaseIterable {
    case applied = "已投递"      // 刚投递简历
    case writtenTest = "笔试"    // 参加笔试
    case interviewing = "面试中"  // 正在面试流程
    case offer = "Offer"        // 已收到 offer
    case rejected = "已拒绝"     // 主动拒绝
    case failed = "未通过"       // 未通过筛选

    /// 状态对应的颜色名称（用于 UI）
    var colorName: String {
        switch self {
        case .applied:
            return "blue"
        case .writtenTest:
            return "purple"
        case .interviewing:
            return "orange"
        case .offer:
            return "green"
        case .rejected:
            return "gray"
        case .failed:
            return "red"
        }
    }

    /// 状态对应的 SF Symbols 图标
    var iconName: String {
        switch self {
        case .applied:
            return "paperplane.fill"
        case .writtenTest:
            return "pencil.and.list.clipboard"
        case .interviewing:
            return "person.2.fill"
        case .offer:
            return "checkmark.seal.fill"
        case .rejected:
            return "xmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }

    /// 是否为进行中的状态
    var isActive: Bool {
        switch self {
        case .applied, .writtenTest, .interviewing:
            return true
        case .offer, .rejected, .failed:
            return false
        }
    }
}

// MARK: - 面试结果枚举

/// 单轮面试的结果
enum InterviewResult: String, Codable, CaseIterable {
    case pending = "待定"
    case passed = "通过"
    case failed = "未通过"
    case cancelled = "已取消"

    var iconName: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .passed:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .cancelled:
            return "minus.circle.fill"
        }
    }
}

// MARK: - 求职申请模型（主表）

/// 求职申请记录
@Model
final class JobApplication {
    /// 唯一标识符
    var id: UUID

    /// 公司名称
    var companyName: String

    /// 岗位名称
    var positionName: String

    /// 整体状态
    var status: ApplicationStatus

    /// 投递日期
    var appliedDate: Date

    /// 工作地点（可选）
    var location: String?

    /// 薪资范围（可选）
    var salaryRange: String?

    /// 备注
    var notes: String?

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    /// 关联的面试轮次（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \InterviewRound.application)
    var interviewRounds: [InterviewRound]?

    /// 初始化方法
    init(
        companyName: String,
        positionName: String,
        status: ApplicationStatus = .applied,
        appliedDate: Date = Date(),
        location: String? = nil,
        salaryRange: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.companyName = companyName
        self.positionName = positionName
        self.status = status
        self.appliedDate = appliedDate
        self.location = location
        self.salaryRange = salaryRange
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// 计算属性：面试轮次总数
    var totalRounds: Int {
        interviewRounds?.count ?? 0
    }

    /// 计算属性：最新一轮面试
    var latestRound: InterviewRound? {
        interviewRounds?.sorted(by: { $0.interviewDate > $1.interviewDate }).first
    }

    /// 计算属性：是否还有进行中的面试
    var hasActiveInterview: Bool {
        interviewRounds?.contains(where: { $0.result == .pending }) ?? false
    }
}

// MARK: - 面试轮次模型（子表）

/// 单轮面试记录
@Model
final class InterviewRound {
    /// 唯一标识符
    var id: UUID

    /// 轮次名称（支持自定义：一面、二面、交叉面、HR面等）
    var roundName: String

    /// 面试日期
    var interviewDate: Date

    /// 面试官姓名（可选）
    var interviewer: String?

    /// 本轮结果
    var result: InterviewResult

    /// 面试反馈/笔记（可选）
    var feedback: String?

    /// 创建时间
    var createdAt: Date

    /// 关联的求职申请（多对一关系）
    var application: JobApplication?

    /// 初始化方法
    init(
        roundName: String,
        interviewDate: Date = Date(),
        interviewer: String? = nil,
        result: InterviewResult = .pending,
        feedback: String? = nil
    ) {
        self.id = UUID()
        self.roundName = roundName
        self.interviewDate = interviewDate
        self.interviewer = interviewer
        self.result = result
        self.feedback = feedback
        self.createdAt = Date()
    }

    /// 计算属性：是否已结束
    var isCompleted: Bool {
        result != .pending
    }
}

// MARK: - 预览数据

/// 创建预览用的示例数据
extension JobApplication {
    static var preview: JobApplication {
        let application = JobApplication(
            companyName: "字节跳动",
            positionName: "iOS 开发工程师",
            status: .interviewing,
            appliedDate: Date().addingTimeInterval(-7 * 24 * 3600),
            location: "北京",
            salaryRange: "25K-40K",
            notes: "一面表现不错，等待二面通知"
        )

        let round1 = InterviewRound(
            roundName: "一面（技术面）",
            interviewDate: Date().addingTimeInterval(-2 * 24 * 3600),
            interviewer: "张工",
            result: .passed,
            feedback: "主要考察 Swift 基础和项目经验，表现良好"
        )

        let round2 = InterviewRound(
            roundName: "二面（部门主管）",
            interviewDate: Date().addingTimeInterval(2 * 24 * 3600),
            result: .pending
        )

        application.interviewRounds = [round1, round2]
        round1.application = application
        round2.application = application

        return application
    }

    static var previewList: [JobApplication] {
        [
            preview,
            JobApplication(
                companyName: "阿里巴巴",
                positionName: "高级前端工程师",
                status: .offer,
                appliedDate: Date().addingTimeInterval(-14 * 24 * 3600),
                location: "杭州",
                salaryRange: "30K-50K"
            ),
            JobApplication(
                companyName: "腾讯",
                positionName: "全栈开发",
                status: .applied,
                appliedDate: Date().addingTimeInterval(-1 * 24 * 3600),
                location: "深圳"
            ),
            JobApplication(
                companyName: "美团",
                positionName: "移动端开发",
                status: .failed,
                appliedDate: Date().addingTimeInterval(-21 * 24 * 3600),
                location: "北京"
            )
        ]
    }
}
