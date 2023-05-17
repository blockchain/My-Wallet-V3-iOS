// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources

protocol LinkedBankViewModelAPI {
    var nameLabelContent: LabelContent { get }
    var limitLabelContent: LabelContent { get }
    var accountLabelContent: LabelContent { get }
    var badgeImageViewModel: BadgeImageViewModel { get }
    /// Determines if the view accepts taps from its custom button or not
    var isCustomButtonEnabled: Bool { get }
    /// PublishRelay for forwarding tap events from the view
    var tapRelay: PublishRelay<Void> { get }
}

final class BeneficiaryLinkedBankViewModel: LinkedBankViewModelAPI {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.LinkedBankView

    // MARK: - Properties

    let data: Beneficiary

    let nameLabelContent: LabelContent
    let limitLabelContent: LabelContent
    let accountLabelContent: LabelContent
    let badgeImageViewModel: BadgeImageViewModel

    let tapRelay = PublishRelay<Void>()
    let isCustomButtonEnabled: Bool = false

    // MARK: - Setup

    init(data: Beneficiary) {
        self.data = data

        if let icon = data.icon {
            self.badgeImageViewModel = .template(
                image: .remote(url: icon),
                templateColor: .semantic.primary,
                backgroundColor: .clear,
                cornerRadius: .round,
                accessibilityIdSuffix: data.identifier
            )
        } else {
            self.badgeImageViewModel = .template(
                image: .local(name: Icon.bank.name, bundle: .componentLibrary),
                templateColor: .semantic.primary,
                backgroundColor: .semantic.primaryUltraLight,
                cornerRadius: .round,
                accessibilityIdSuffix: data.identifier
            )
            badgeImageViewModel.marginOffsetRelay.accept(4)
        }

        self.nameLabelContent = LabelContent(
            text: data.name,
            font: .main(.semibold, 16),
            color: .semantic.title,
            accessibility: .id("\(AccessibilityId.name)\(data.identifier)")
        )

        var limitText = ""
        if let limit = data.limit {
            limitText = "\(limit.displayString) \(LocalizationConstants.Settings.Bank.dailyLimit)"
        }

        self.limitLabelContent = LabelContent(
            text: limitText,
            font: .main(.medium, 14),
            color: .semantic.text,
            accessibility: .id("\(AccessibilityId.limits)\(data.identifier)")
        )

        self.accountLabelContent = LabelContent(
            text: data.account,
            font: .main(.semibold, 16),
            color: .semantic.title,
            accessibility: .id("\(AccessibilityId.account)\(data.identifier)")
        )
    }
}

extension BeneficiaryLinkedBankViewModel: IdentifiableType {
    var identity: String {
        "\(data.identifier)-\(data.name)-\(data.account)"
    }
}

extension BeneficiaryLinkedBankViewModel: Equatable {
    static func == (lhs: BeneficiaryLinkedBankViewModel, rhs: BeneficiaryLinkedBankViewModel) -> Bool {
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
