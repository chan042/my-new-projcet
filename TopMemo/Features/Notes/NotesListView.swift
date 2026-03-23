import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel

    var body: some View {
        VStack(spacing: 12) {
            header

            if viewModel.notes.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.notes) { memo in
                            Button {
                                viewModel.edit(memo)
                            } label: {
                                MemoCardView(memo: memo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .scrollIndicators(.never)
            }

            addButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TopMemo")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                Text("\(viewModel.notes.count)개의 메모")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var emptyState: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(AppTheme.elevatedBackground)
            .overlay {
                Text("첫 메모를 작성해보세요.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.subtleBorder, lineWidth: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button {
            viewModel.startNewMemo()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))

                Text("새 메모")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.plusBackground)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: [.command])
    }
}

private struct MemoCardView: View {
    let memo: MemoItem

    private var previewColor: Color {
        memo.color == .black ? .primary : memo.color.color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(memo.color.color)
                    .frame(width: 8, height: 8)

                Text(DateFormatting.noteTimestamp(memo.updatedAt))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.subduedText)

                Spacer()
            }

            Text(memo.previewText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(previewColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.elevatedBackground)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.subtleBorder, lineWidth: 1)
        }
    }
}
