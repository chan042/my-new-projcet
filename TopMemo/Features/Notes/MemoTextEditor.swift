import AppKit
import SwiftUI

struct MemoTextEditor: NSViewRepresentable {
    @Binding var text: String
    var textColor: NSColor
    var focusToken: UUID
    var onSave: () -> Void
    var onEscape: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let textView = CommandTextView()
        textView.delegate = context.coordinator
        textView.font = AppTheme.editorFont
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.textContainerInset = NSSize(width: 0, height: 12)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: 0,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.string = text
        textView.onSave = onSave
        textView.onEscape = onEscape

        applyAppearance(to: textView)
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? CommandTextView else {
            return
        }

        if textView.string != text {
            textView.string = text
        }

        textView.onSave = onSave
        textView.onEscape = onEscape
        applyAppearance(to: textView)

        if context.coordinator.lastFocusToken != focusToken {
            context.coordinator.lastFocusToken = focusToken
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }

    private func applyAppearance(to textView: NSTextView) {
        textView.textColor = textColor
        textView.insertionPointColor = textColor
        textView.typingAttributes = [
            .foregroundColor: textColor,
            .font: AppTheme.editorFont
        ]

        let range = NSRange(location: 0, length: textView.string.utf16.count)
        textView.setTextColor(textColor, range: range)
        textView.setFont(AppTheme.editorFont, range: range)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var lastFocusToken = UUID()

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            text.wrappedValue = textView.string
        }
    }
}

final class CommandTextView: NSTextView {
    var onSave: (() -> Void)?
    var onEscape: (() -> Void)?

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if flags == .command, event.charactersIgnoringModifiers?.lowercased() == "s" {
            onSave?()
            return true
        }

        if event.keyCode == 53 {
            onEscape?()
            return true
        }

        return super.performKeyEquivalent(with: event)
    }
}
