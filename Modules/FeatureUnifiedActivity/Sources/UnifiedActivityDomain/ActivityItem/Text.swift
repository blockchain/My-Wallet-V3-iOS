// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation

extension ActivityItem {
    public struct Text: Equatable, Codable, Hashable, Identifiable {
        public struct Style: Equatable, Codable, Hashable {
            public let typography: ActivityTypography
            public let color: ActivityColor
            public init(typography: ActivityTypography, color: ActivityColor) {
                self.typography = typography
                self.color = color
            }
        }

        public var id: String {
            "\(hashValue)"
        }

        public let value: String
        public let style: Style
        public init(
            value: String,
            style: ActivityItem.Text.Style
        ) {
            self.value = value
            self.style = style
        }
    }
}

public enum ActivityTypography: String, Codable, Hashable {
    case display = "Display"
    case title1 = "Title 1"
    case title2 = "Title 2"
    case title3 = "Title 3"
    case subheading = "Subheading"
    case bodyMono = "Body Mono"
    case body1 = "Body 1"
    case body2 = "Body 2"
    case paragraphMono = "Paragraph Mono"
    case paragraph1 = "Paragraph 1"
    case paragraph2 = "Paragraph 2"
    case caption1 = "Caption 1"
    case caption2 = "Caption 2"
    case overline = "Overline"
    case micro = "Micro (TabBar Text)"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = ActivityTypography(rawValue: string) ?? .unknown
    }

    public func typography() -> Typography {
        switch self {
        case .display:
            return Typography.display
        case .title1:
            return Typography.title1
        case .title2:
            return Typography.title2
        case .title3:
            return Typography.title3
        case .subheading:
            return Typography.subheading
        case .bodyMono:
            return Typography.bodyMono
        case .body1:
            return Typography.body1
        case .body2:
            return Typography.body2
        case .paragraphMono:
            return Typography.paragraphMono
        case .paragraph1:
            return Typography.paragraph1
        case .paragraph2:
            return Typography.paragraph2
        case .caption1:
            return Typography.caption1
        case .caption2:
            return Typography.caption2
        case .overline:
            return Typography.overline
        case .micro:
            return Typography.micro
        case .unknown:
            return Typography.body1
        }
    }
}

public enum ActivityColor: String, Codable, Hashable {
    case title = "Title"
    case body = "Body"
    case text = "Text"
    case overlay = "Overlay"
    case muted = "Muted"
    case dark = "Dark"
    case medium = "Medium"
    case light = "Light"
    case background = "Background"
    case primary = "Primary"
    case primaryMuted = "Primary Muted"
    case success = "Success"
    case warning = "Warning"
    case error = "Error"
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = ActivityColor(rawValue: string) ?? .unknown
    }

    public func uiColor() -> Color {
        switch self {
        case .title:
            return Color.semantic.title
        case .body:
            return Color.semantic.body
        case .text:
            return Color.semantic.text
        case .overlay:
            return Color.semantic.overlay
        case .muted:
            return Color.semantic.muted
        case .dark:
            return Color.semantic.dark
        case .medium:
            return Color.semantic.medium
        case .light:
            return Color.semantic.light
        case .background:
            return Color.semantic.background
        case .primary:
            return Color.semantic.primary
        case .primaryMuted:
            return Color.semantic.primaryMuted
        case .success:
            return Color.semantic.success
        case .warning:
            return Color.semantic.warning
        case .error:
            return Color.semantic.error
        case .unknown:
            return .WalletSemantic.body
        }
    }
}
