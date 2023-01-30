// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AccountPickerSimpleHeaderModel: Equatable {

    var height: CGFloat {
        searchable || switchable ? 104 : 64
    }

    public let subtitle: String?
    public let searchable: Bool
    public let switchable: Bool
    public let switchTitle: String?

    var subtitleLabel: LabelContent {
        LabelContent(
            text: subtitle ?? "",
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(
        subtitle: String? = nil,
        searchable: Bool = false,
        switchable: Bool = false,
        switchTitle: String? = nil
    ) {
        self.subtitle = subtitle
        self.searchable = searchable
        self.switchable = switchable
        self.switchTitle = switchTitle
    }
}
