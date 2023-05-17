// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformUIKit
import UIKit

public struct SourceTargetSectionHeaderModel: Equatable {

    public enum TitleDisplayStyle {
        case medium
        case small
    }

    static let defaultHeight: CGFloat = 45

    private let sectionTitle: String

    var sectionTitleLabel: LabelContent {
        LabelContent(
            text: sectionTitle,
            font: .main(.medium, 12),
            color: titleColor
        )
    }

    public let showSeparator: Bool
    public let titleColor: UIColor
    public let titleDisplayStyle: TitleDisplayStyle

    public init(
        sectionTitle: String,
        titleDisplayStyle: TitleDisplayStyle = .medium,
        titleColor: UIColor = .semantic.title,
        showSeparator: Bool = true
    ) {
        self.sectionTitle = sectionTitle
        self.titleDisplayStyle = titleDisplayStyle
        self.showSeparator = showSeparator
        self.titleColor = titleColor
    }
}
