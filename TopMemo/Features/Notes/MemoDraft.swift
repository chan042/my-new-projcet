import Foundation

struct MemoDraft: Equatable {
    var memoID: UUID?
    var content: String
    var color: MemoColor
    var createdAt: Date?

    static let empty = MemoDraft(
        memoID: nil,
        content: "",
        color: .black,
        createdAt: nil
    )

    static func from(_ memo: MemoItem) -> MemoDraft {
        MemoDraft(
            memoID: memo.id,
            content: memo.content,
            color: memo.color,
            createdAt: memo.createdAt
        )
    }

    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
