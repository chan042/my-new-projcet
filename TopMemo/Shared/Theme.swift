import AppKit
import SwiftUI

enum AppTheme {
    static let popoverSize = NSSize(width: 360, height: 420)
    static let cornerRadius: CGFloat = 16
    static let editorFont = NSFont.systemFont(ofSize: 15)
    static let background = Color(nsColor: .windowBackgroundColor)
    static let elevatedBackground = Color(nsColor: .controlBackgroundColor)
    static let subtleBorder = Color(nsColor: .separatorColor).opacity(0.16)
    static let subduedText = Color(nsColor: .secondaryLabelColor)
    static let plusBackground = Color(nsColor: .controlAccentColor).opacity(0.12)
}
