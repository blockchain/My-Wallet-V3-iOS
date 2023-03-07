// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

public struct TitledSectionHeaderModel: Equatable {
    static let defaultHeight: CGFloat = 90

    private let title: String
    private let sectionTitle: String

    var titleLabel: LabelContent {
        LabelContent(
            text: title,
            font: .main(.semibold, 12),
            color: .descriptionText
        )
    }

    var sectionTitleLabel: LabelContent {
        LabelContent(
            text: sectionTitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(title: String, sectionTitle: String) {
        self.title = title
        self.sectionTitle = sectionTitle
    }
}
