// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct AccountPickerHeaderModel: Equatable {

    // MARK: Types

    public typealias LocalizedString = LocalizationConstants.WalletPicker

    // MARK: Public Properties

    public let imageContent: ImageViewContent
    public let subtitle: String?
    public let tableTitle: String?
    public let title: String
    public let searchable: Bool
    public let switchable: Bool
    public let switchTitle: String?

    // MARK: Properties

    var height: CGFloat {
        searchable || switchable ? 184 : 144
    }

    var titleLabel: LabelContent {
        .init(
            text: title,
            font: .main(.semibold, 20),
            color: .titleText
        )
    }

    var subtitleLabel: LabelContent {
        .init(
            text: subtitle ?? "",
            font: .main(.medium, 14),
            color: .descriptionText,
            lineBreakMode: .byWordWrapping
        )
    }

    var tableTitleLabel: LabelContent? {
        tableTitle
            .flatMap { tableTitle in
                LabelContent(
                    text: tableTitle,
                    font: .main(.semibold, 12),
                    color: .titleText
                )
            }
    }

    // MARK: Init

    public init(
        imageContent: ImageViewContent,
        searchable: Bool = false,
        switchable: Bool = false,
        switchTitle: String? = nil,
        subtitle: String? = nil,
        tableTitle: String? = LocalizedString.selectAWallet,
        title: String
    ) {
        self.imageContent = imageContent
        self.searchable = searchable
        self.subtitle = subtitle
        self.tableTitle = tableTitle
        self.title = title
        self.switchable = switchable
        self.switchTitle = switchTitle
    }
}
