// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

public struct SourceTargetSectionHeaderModel: Equatable {

    public enum TitleDisplayStyle {
        case medium
        case small
    }

    static let defaultHeight: CGFloat = 24

    private let sectionTitle: String

    var sectionTitleLabel: LabelContent {
        LabelContent(
            text: sectionTitle,
            font: .main(.medium, titleDisplayStyle == .medium ? 14 : 12),
            color: titleDisplayStyle == .medium ? .titleText : .textFieldPlaceholder
        )
    }

    public let showSeparator: Bool

    public let titleDisplayStyle: TitleDisplayStyle

    public init(
        sectionTitle: String,
        titleDisplayStyle: TitleDisplayStyle = .medium,
        showSeparator: Bool = true
    ) {
        self.sectionTitle = sectionTitle
        self.titleDisplayStyle = titleDisplayStyle
        self.showSeparator = showSeparator
    }
}
