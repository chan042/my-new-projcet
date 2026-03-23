import Foundation
import SwiftUI

enum NotesAlert: Identifiable, Equatable {
    case discardChanges
    case deleteMemo
    case error(message: String)

    var id: String {
        switch self {
        case .discardChanges:
            return "discardChanges"
        case .deleteMemo:
            return "deleteMemo"
        case .error(let message):
            return "error-\(message)"
        }
    }
}

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [MemoItem] = []
    @Published var route: TopMemoRoute = .emptyComposer
    @Published var draft: MemoDraft = .empty
    @Published var focusToken = UUID()
    @Published var activeAlert: NotesAlert?

    private let store: NotesStore
    private var originalDraft: MemoDraft = .empty

    init(store: NotesStore) {
        self.store = store
        loadNotes()
    }

    var canSave: Bool {
        !draft.trimmedContent.isEmpty
    }

    var isEditingExistingMemo: Bool {
        draft.memoID != nil
    }

    var isDirty: Bool {
        draft.content != originalDraft.content || draft.color != originalDraft.color
    }

    func handlePopoverOpened() {
        activeAlert = nil

        if notes.isEmpty {
            prepareEmptyComposer()
        } else {
            route = .memoList
        }
    }

    func startNewMemo() {
        draft = .empty
        originalDraft = draft
        route = .editor(memoID: nil)
        requestFocus()
    }

    func edit(_ memo: MemoItem) {
        draft = .from(memo)
        originalDraft = draft
        route = .editor(memoID: memo.id)
        requestFocus()
    }

    func requestBack(closePopover: () -> Void) {
        if isDirty {
            activeAlert = .discardChanges
            return
        }

        goBack(closePopover: closePopover)
    }

    func discardChangesAndGoBack(closePopover: () -> Void) {
        restoreDraftFromSource()
        goBack(closePopover: closePopover)
    }

    func requestDelete() {
        activeAlert = .deleteMemo
    }

    func deleteCurrent() {
        activeAlert = nil

        if let memoID = draft.memoID {
            notes.removeAll { $0.id == memoID }
            persistNotes()
        }

        if notes.isEmpty {
            prepareEmptyComposer()
        } else {
            route = .memoList
        }
    }

    func saveCurrent() {
        guard canSave else {
            return
        }

        let now = Date()

        if let memoID = draft.memoID, let index = notes.firstIndex(where: { $0.id == memoID }) {
            notes[index].content = draft.content
            notes[index].color = draft.color
            notes[index].updatedAt = now
        } else {
            notes.append(
                MemoItem(
                    id: UUID(),
                    content: draft.content,
                    color: draft.color,
                    createdAt: draft.createdAt ?? now,
                    updatedAt: now
                )
            )
        }

        persistNotes()
        draft = .empty
        originalDraft = draft
        route = .memoList
    }

    func selectColor(_ color: MemoColor) {
        draft.color = color
    }

    func clearAlert() {
        activeAlert = nil
    }

    private func loadNotes() {
        do {
            notes = Self.sorted(try store.load())
            route = notes.isEmpty ? .emptyComposer : .memoList
        } catch {
            notes = []
            route = .emptyComposer
            activeAlert = .error(message: error.localizedDescription)
        }
    }

    private func prepareEmptyComposer() {
        draft = .empty
        originalDraft = draft
        route = .emptyComposer
        requestFocus()
    }

    private func goBack(closePopover: () -> Void) {
        activeAlert = nil

        if notes.isEmpty {
            prepareEmptyComposer()
            closePopover()
        } else {
            route = .memoList
        }
    }

    private func restoreDraftFromSource() {
        if let memoID = draft.memoID, let memo = notes.first(where: { $0.id == memoID }) {
            draft = .from(memo)
            originalDraft = draft
        } else {
            draft = .empty
            originalDraft = draft
        }
    }

    private func requestFocus() {
        focusToken = UUID()
    }

    private func persistNotes() {
        notes = Self.sorted(notes)

        do {
            try store.save(notes)
        } catch {
            activeAlert = .error(message: error.localizedDescription)
        }
    }

    private static func sorted(_ notes: [MemoItem]) -> [MemoItem] {
        notes.sorted {
            if $0.updatedAt == $1.updatedAt {
                return $0.createdAt > $1.createdAt
            }

            return $0.updatedAt > $1.updatedAt
        }
    }
}
