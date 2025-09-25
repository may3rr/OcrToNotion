import Foundation

struct TodoItem: Codable, Hashable {
    let taskName: String
    let dueDate: Date?
    let priority: String
    let workload: String
    let categories: [String]
    let status: String
    let notes: String
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case taskName = "任务名称"
        case dueDate = "截止日期"
        case priority = "优先级"
        case workload = "工作量等级"
        case categories = "任务类型"
        case status = "状态"
        case notes = "描述"
        case isCompleted = "复选框"
    }
}
