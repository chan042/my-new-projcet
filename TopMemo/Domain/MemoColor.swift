import AppKit
import SwiftUI

enum MemoColor: String, Codable, CaseIterable, Identifiable {
    case black
    case red
    case blue
    case green

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .black:
            return "검정"
        case .red:
            return "빨강"
        case .blue:
            return "파랑"
        case .green:
            return "초록"
        }
    }

    var nsColor: NSColor {
        switch self {
        case .black:
            return .labelColor
        case .red:
            return .systemRed
        case .blue:
            return .systemBlue
        case .green:
            return .systemGreen
        }
    }

    var color: Color {
        Color(nsColor: nsColor)
    }
}
