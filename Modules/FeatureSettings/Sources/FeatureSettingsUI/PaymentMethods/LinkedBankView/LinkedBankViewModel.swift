// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources

final class LinkedBankViewModel: LinkedBankViewModelAPI {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.LinkedBankView

    // MARK: - Properties

    let data: LinkedBankData

    let nameLabelContent: LabelContent
    let limitLabelContent: LabelContent
    let accountLabelContent: LabelContent
    let badgeImageViewModel: BadgeImageViewModel

    let isCustomButtonEnabled: Bool = true

    let tapRelay = PublishRelay<Void>()
    var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    // MARK: - Setup

    init(data: LinkedBankData) {
        self.data = data

        self.badgeImageViewModel = .primary(
            image: data.icon.map(ImageLocation.remote(url:)) ?? .local(name: "icon-bank", bundle: .platformUIKit),
            cornerRadius: .round,
            accessibilityIdSuffix: data.identifier
        )
        badgeImageViewModel.marginOffsetRelay.accept(6)

        self.nameLabelContent = LabelContent(
            text: data.account?.bankName ?? "",
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.name)\(data.identifier)")
        )

        let bankName = data.account?.bankName ?? ""
        let accountType = data.account?.type.title ?? ""
        let accountNumber = data.account?.number ?? ""
        let detailsTitle = "\(bankName) \(accountType) \(accountNumber)"
        self.limitLabelContent = LabelContent(
            text: detailsTitle,
            font: .main(.medium, 14),
            color: .descriptionText,
            accessibility: .id("\(AccessibilityId.limits)\(data.identifier)")
        )

        self.accountLabelContent = LabelContent(
            text: "",
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.account)\(data.identifier)")
        )
    }
}

extension LinkedBankViewModel: IdentifiableType {
    var identity: String {
        data.identifier
    }
}

extension LinkedBankViewModel: Equatable {
    static func == (lhs: LinkedBankViewModel, rhs: LinkedBankViewModel) -> Bool {
        lhs.data == rhs.data
    }
}

extension Accessibility.Identifier {
    fileprivate enum LinkedBankView {
        private static let prefix = "LinkedBankView."
        static let image = "\(prefix)image"
        static let name = "\(prefix)name."
        static let limits = "\(prefix)limits."
        static let account = "\(prefix)account."
    }
}
