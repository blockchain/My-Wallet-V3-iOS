// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import ToolKit

/// Types adopting the `TargetDestinationsStrategyAPI` should provide a way to output an array of `TargetSelectionPageSectionModel` items
protocol TargetDestinationsStrategyAPI {
    func sections(
        interactors: [TargetSelectionPageCellItem.Interactor],
        action: AssetAction
    ) -> [TargetSelectionPageSectionModel]
}

// MARK: - Main Concrete Class

/// A container class adopting the `TargetDestinationsStrategyAPI`
/// which holds a concrete class of type `TargetDestinationsStrategyAPI` which provides a set of sections.
struct TargetDestinationSections: TargetDestinationsStrategyAPI {

    private let strategy: TargetDestinationsStrategyAPI

    init(strategy: TargetDestinationsStrategyAPI) {
        self.strategy = strategy
    }

    func sections(
        interactors: [TargetSelectionPageCellItem.Interactor],
        action: AssetAction
    ) -> [TargetSelectionPageSectionModel] {
        strategy.sections(interactors: interactors, action: action)
    }
}

// MARK: - Target Destination Section Enum

private enum TargetDestinationTitle {
    case to
    case orSelect
    case receive

    var text: String {
        switch self {
        case .to:
            return LocalizationConstants.Transaction.to
        case .orSelect:
            return LocalizationConstants.Transaction.orSelectAWallet
        case .receive:
            return LocalizationConstants.Transaction.receive
        }
    }

    var showSeparator: Bool {
        switch self {
        case .to,
             .receive,
             .orSelect:
            return true
        }
    }

    var color: UIColor {
        switch self {
        case .orSelect:
            return UIColor(Color.semantic.text)
        case .receive:
            return UIColor(Color.semantic.title)
        case .to:
            return UIColor(Color.semantic.title)
        }
    }
}

// MARK: - Any Source DestinationStrategy

struct AnySourceDestinationStrategy: TargetDestinationsStrategyAPI {

    private let sourceAccount: SingleAccount

    init(sourceAccount: SingleAccount) {
        self.sourceAccount = sourceAccount
    }

    func sections(
        interactors: [TargetSelectionPageCellItem.Interactor],
        action: AssetAction
    ) -> [TargetSelectionPageSectionModel] {
        // Known wallets the user can send to (eg Trading/DeFi Wallet/Exchange)
        let items: [TargetSelectionPageCellItem] = interactors
            .compactMap { interactor -> TargetSelectionPageCellItem? in
                guard !interactor.isWalletInputField else {
                    return nil
                }
                return TargetSelectionPageCellItem(
                    interactor: interactor,
                    assetAction: action
                )
            }
        guard !items.isEmpty else {
            return []
        }
        return [
            .destination(
                header: provideSectionHeader(action: action, title: .orSelect),
                items: items
            )
        ]
    }
}

// MARK: - Section Header Provider method

private func provideSectionHeader(action: AssetAction, title: TargetDestinationTitle) -> TargetSelectionHeaderBuilder {
    switch action {
    case .swap:
        return TargetSelectionHeaderBuilder(
            headerType: .section(
                .init(
                    sectionTitle: title.text
                )
            )
        )
    case .send:
        return TargetSelectionHeaderBuilder(
            headerType: .section(
                .init(
                    sectionTitle: title.text,
                    titleDisplayStyle: title.showSeparator ? .medium : .small,
                    titleColor: title.color,
                    showSeparator: title.showSeparator
                )
            )
        )
    case .deposit,
         .interestTransfer,
         .withdraw,
         .interestWithdraw,
         .stakingDeposit,
         .receive,
         .buy,
         .sign,
         .sell,
         .viewActivity,
         .activeRewardsDeposit,
         .stakingWithdraw,
         .activeRewardsWithdraw:
        unimplemented()
    }
}
