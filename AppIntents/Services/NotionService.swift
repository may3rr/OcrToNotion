import Foundation

enum NotionServiceError: Error {
    case invalidResponse
}

struct NotionService {
    struct Configuration {
        let tokenProvider: () throws -> String
        let dataSourceIdProvider: () throws -> String
        let endpointProvider: () throws -> URL
        let apiVersionProvider: () throws -> String
    }

    struct PageResponse: Decodable {
        let id: String
        let url: URL
    }

    let configuration: Configuration
    let urlSession: URLSession = .shared

    func createPages(from todos: [TodoItem]) async throws -> [PageResponse] {
        try await withThrowingTaskGroup(of: PageResponse.self) { group in
            for todo in todos {
                group.addTask {
                    try await createPage(from: todo)
                }
            }

            var results: [PageResponse] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }

    private func createPage(from todo: TodoItem) async throws -> PageResponse {
        var request = URLRequest(url: try configuration.endpointProvider())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try configuration.apiVersionProvider(), forHTTPHeaderField: "Notion-Version")
        request.setValue("Bearer \(try configuration.tokenProvider())", forHTTPHeaderField: "Authorization")

        let payload = try makePayload(from: todo)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NotionServiceError.invalidResponse
        }

        return try JSONDecoder().decode(PageResponse.self, from: data)
    }

    private func makePayload(from todo: TodoItem) throws -> Payload {
        Payload(
            parent: .init(type: "data_source_id", data_source_id: try configuration.dataSourceIdProvider()),
            properties: .init(todo: todo)
        )
    }
}

private struct Payload: Encodable {
    struct Parent: Encodable {
        let type: String
        let data_source_id: String
    }

    struct Properties: Encodable {
        struct TextBlock: Encodable {
            struct TextContent: Encodable {
                let content: String
            }
            let text: TextContent
        }

        struct MultiSelectOption: Encodable {
            let name: String
        }

        struct StatusValue: Encodable {
            let name: String
        }

        struct SelectValue: Encodable {
            let name: String
        }

        struct DateValue: Encodable {
            let start: String
        }

        let taskName: Title
        let dueDate: DateProperty?
        let priority: SelectProperty
        let workload: SelectProperty
        let categories: MultiSelectProperty
        let status: StatusProperty
        let notes: RichTextProperty
        let checkbox: CheckboxProperty

        enum CodingKeys: String, CodingKey {
            case taskName = "任务名称"
            case dueDate = "截止日期"
            case priority = "优先级"
            case workload = "工作量等级"
            case categories = "任务类型"
            case status = "状态"
            case notes = "描述"
            case checkbox = "复选框"
        }

        init(todo: TodoItem) {
            self.taskName = Title(value: todo.taskName)
            if let dueDate = todo.dueDate {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate]
                self.dueDate = DateProperty(value: formatter.string(from: dueDate))
            } else {
                self.dueDate = nil
            }
            self.priority = SelectProperty(name: todo.priority)
            self.workload = SelectProperty(name: todo.workload)
            self.categories = MultiSelectProperty(names: todo.categories)
            self.status = StatusProperty(name: todo.status)
            self.notes = RichTextProperty(value: todo.notes)
            self.checkbox = CheckboxProperty(value: todo.isCompleted)
        }

        struct Title: Encodable {
            let title: [TextBlock]

            init(value: String) {
                self.title = [.init(text: .init(content: value))]
            }
        }

        struct DateProperty: Encodable {
            let date: DateValue

            init(value: String) {
                self.date = DateValue(start: value)
            }
        }

        struct SelectProperty: Encodable {
            let select: SelectValue

            init(name: String) {
                self.select = SelectValue(name: name)
            }
        }

        struct MultiSelectProperty: Encodable {
            let multi_select: [MultiSelectOption]

            init(names: [String]) {
                self.multi_select = names.map { MultiSelectOption(name: $0) }
            }
        }

        struct StatusProperty: Encodable {
            let status: StatusValue

            init(name: String) {
                self.status = StatusValue(name: name)
            }
        }

        struct RichTextProperty: Encodable {
            let rich_text: [TextBlock]

            init(value: String) {
                guard value.isEmpty == false else {
                    self.rich_text = []
                    return
                }
                self.rich_text = [.init(text: .init(content: value))]
            }
        }

        struct CheckboxProperty: Encodable {
            let checkbox: Bool

            init(value: Bool) {
                self.checkbox = value
            }
        }
    }

    let parent: Parent
    let properties: Properties
}
