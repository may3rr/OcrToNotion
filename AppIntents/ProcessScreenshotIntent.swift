import AppIntents
import Foundation
import Security
import UniformTypeIdentifiers

struct ProcessScreenshotIntent: AppIntent {
    static var title: LocalizedStringResource = "OCR 截图并同步到 Notion"
    static var description = IntentDescription("识别截图中的待办事项，调用 LLM 解析，并在 Notion 中创建任务。")

    @Parameter(title: "截图文件", requestValueDialog: IntentDialog("请选择需要解析的截图"))
    var screenshot: IntentFile

    @Parameter(title: "当前日期")
    var currentDate: Date

    static var parameterSummary: some ParameterSummary {
        Summary("从 \(\.$screenshot) 创建任务，使用日期 \(\.$currentDate)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<[URL]> {
        let imageData = try Data(contentsOf: screenshot.fileURL)

        let ocrService = OCRService()
        let text = try await ocrService.recognizeText(from: imageData)

        let gptService = GPTService(configuration: .init(
            apiKeyProvider: Secrets.gptAPIKey,
            endpointProvider: Secrets.gptEndpoint,
            modelProvider: Secrets.gptModel
        ))
        let todos = try await gptService.generateTodos(from: text, currentDate: currentDate)

        let notionService = NotionService(configuration: .init(
            tokenProvider: Secrets.notionToken,
            dataSourceIdProvider: Secrets.notionDataSourceId,
            endpointProvider: Secrets.notionPagesEndpoint,
            apiVersionProvider: Secrets.notionAPIVersion
        ))

        let pages = try await notionService.createPages(from: todos)
        let urls = pages.map { $0.url }

        return .result(value: urls)
    }
}

struct Secrets {
    static func gptAPIKey() throws -> String {
        try string(forKey: "gpt_api_key")
    }

    static func gptEndpoint() throws -> URL {
        try url(forKey: "gpt_endpoint")
    }

    static func gptModel() throws -> String {
        try string(forKey: "gpt_model")
    }

    static func notionToken() throws -> String {
        try string(forKey: "notion_token")
    }

    static func notionDataSourceId() throws -> String {
        try string(forKey: "notion_data_source_id")
    }

    static func notionPagesEndpoint() throws -> URL {
        try url(forKey: "notion_pages_endpoint")
    }

    static func notionAPIVersion() throws -> String {
        try string(forKey: "notion_api_version")
    }

    private static func string(forKey key: String) throws -> String {
        guard let value = KeychainHelper.shared.token(forKey: key), value.isEmpty == false else {
            throw SecretsError.missingKey
        }
        return value
    }

    private static func url(forKey key: String) throws -> URL {
        let value = try string(forKey: key)
        guard let url = URL(string: value) else {
            throw SecretsError.invalidURL
        }
        return url
    }
}

enum SecretsError: Error {
    case missingKey
    case invalidURL
}

final class KeychainHelper {
    static let shared = KeychainHelper()

    func token(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
