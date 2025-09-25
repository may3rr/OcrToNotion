import Foundation

enum GPTServiceError: Error {
    case invalidResponse
}

struct GPTService {
    struct Configuration {
        let apiKeyProvider: () throws -> String
        let endpointProvider: () throws -> URL
        let modelProvider: () throws -> String
    }

    let configuration: Configuration
    let urlSession: URLSession = .shared

    struct RequestPayload: Encodable {
        struct Message: Encodable {
            let role: String
            let content: String
        }

        let model: String
        let messages: [Message]
        let max_tokens: Int
        let temperature: Double
        let top_p: Double
        let stream: Bool
        let reasoning_effort: String
    }

    func generateTodos(from text: String, currentDate: Date) async throws -> [TodoItem] {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]

        let currentDateString = isoFormatter.string(from: currentDate)
        let prompt = """
        你是一个数据分析大师，你需要分析一下这个截图里面的待办事项，并输出 JSON。

        当前日期：\(currentDateString)

        要求：
        1. 输出为一个 JSON 数组。
        2. 字段包括：任务名称, 截止日期, 优先级, 工作量等级, 任务类型, 状态, 描述, 复选框。
        3. 截止日期需要解析自然语言，例如“明天” → YYYY-MM-DD。
        4. 输出必须是合法 JSON，不要包含额外解释。
        文本内容：\n\(text)
        """

        let payload = RequestPayload(
            model: try configuration.modelProvider(),
            messages: [.init(role: "user", content: prompt)],
            max_tokens: 1688,
            temperature: 0.2,
            top_p: 0.3,
            stream: false,
            reasoning_effort: "minimal"
        )

        var request = URLRequest(url: try configuration.endpointProvider())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(try configuration.apiKeyProvider())", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw GPTServiceError.invalidResponse
        }

        let content = try extractContent(from: data)
        return try JSONDecoder.yyyyMMddDecoder.decode([TodoItem].self, from: Data(content.utf8))
    }

    private func extractContent(from data: Data) throws -> String {
        struct APIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let role: String
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let response = try JSONDecoder().decode(APIResponse.self, from: data)
        guard let content = response.choices.first?.message.content else {
            throw GPTServiceError.invalidResponse
        }
        return content
    }
}
