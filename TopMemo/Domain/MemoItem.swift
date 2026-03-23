import Foundation

struct MemoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var color: MemoColor
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        color: MemoColor = .black,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var previewText: String {
        let normalized = trimmedContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if normalized.isEmpty {
            return "빈 메모"
        }

        return String(normalized.prefix(120))
    }
}
