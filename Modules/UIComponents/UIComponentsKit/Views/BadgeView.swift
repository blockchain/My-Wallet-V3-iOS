// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension LayoutConstants {

    fileprivate struct Badge {
        static let contentInsets = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        static let cornerRadious = CGFloat(8)

        private init() {
            // to avoid initializing the struct by accident
        }
    }
}

public struct BadgeView: View {

    public enum Style {
        case info
        case error
        case warning
        case success
    }

    public let title: String
    public let style: Style

    public init(title: String, style: Style) {
        self.title = title
        self.style = style
    }

    public var body: some View {
        ZStack {
            Text(title)
                .foregroundColor(style.textColor)
                .textStyle(.body)
        }
        .padding(LayoutConstants.Badge.contentInsets)
        .background(style.backgroundColor)
        .cornerRadius(LayoutConstants.Badge.cornerRadious)
    }
}

extension BadgeView.Style {

    var backgroundColor: Color {
        let color: Color = switch self {
        case .info:
            .badgeBackgroundInfo
        case .error:
            .badgeBackgroundError
        case .warning:
            .badgeBackgroundWarning
        case .success:
            .badgeBackgroundSuccess
        }
        return color
    }

    var textColor: Color {
        let color: Color = switch self {
        case .info:
            .badgeTextInfo
        case .error:
            .badgeTextError
        case .warning:
            .badgeTextWarning
        case .success:
            .badgeTextSuccess
        }
        return color
    }
}

#if DEBUG
struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            BadgeView(title: "Lorem Ipsum", style: .info)
            BadgeView(title: "Lorem Ipsum", style: .error)
            BadgeView(title: "Lorem Ipsum", style: .warning)
            BadgeView(title: "Lorem Ipsum", style: .success)
        }
    }
}
#endif
