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
            Typography.display
        case .title1:
            Typography.title1
        case .title2:
            Typography.title2
        case .title3:
            Typography.title3
        case .subheading:
            Typography.subheading
        case .bodyMono:
            Typography.bodyMono
        case .body1:
            Typography.body1
        case .body2:
            Typography.body2
        case .paragraphMono:
            Typography.paragraphMono
        case .paragraph1:
            Typography.paragraph1
        case .paragraph2:
            Typography.paragraph2
        case .caption1:
            Typography.caption1
        case .caption2:
            Typography.caption2
        case .overline:
            Typography.overline
        case .micro:
            Typography.micro
        case .unknown:
            Typography.body1
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
            Color.semantic.title
        case .body:
            Color.semantic.body
        case .text:
            Color.semantic.text
        case .overlay:
            Color.semantic.overlay
        case .muted:
            Color.semantic.muted
        case .dark:
            Color.semantic.dark
        case .medium:
            Color.semantic.medium
        case .light:
            Color.semantic.light
        case .background:
            Color.semantic.background
        case .primary:
            Color.semantic.primary
        case .primaryMuted:
            Color.semantic.primaryMuted
        case .success:
            Color.semantic.success
        case .warning:
            Color.semantic.warning
        case .error:
            Color.semantic.error
        case .unknown:
            .WalletSemantic.body
        }
    }
}
