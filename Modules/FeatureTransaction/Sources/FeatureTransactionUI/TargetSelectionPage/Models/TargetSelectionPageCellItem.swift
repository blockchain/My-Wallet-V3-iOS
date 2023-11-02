// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxDataSources
import ToolKit

struct TargetSelectionPageCellItem: Equatable, IdentifiableType {

    // MARK: - Properties

    enum Presenter: Equatable {
        case radioSelection(RadioAccountCellPresenter)
        case cardView(TargetSelectionCardModel)
        case singleAccount(AccountCurrentBalanceCellPresenter)
        case memo(TextFieldViewModel)
        case walletInputField(TextFieldViewModel)
    }

    enum Interactor: Equatable {
        case singleAccountAvailableTarget(RadioAccountCellInteractor)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
        case walletInputField(SingleAccount, TextFieldViewModel)
        case memo(SingleAccount, TextFieldViewModel)

        var account: SingleAccount {
            switch self {
            case .singleAccountAvailableTarget(let interactor):
                interactor.account
            case .singleAccount(let account, _):
                account
            case .memo(let account, _):
                account
            case .walletInputField(let account, _):
                account
            }
        }

        var isInputField: Bool {
            switch self {
            case .walletInputField, .memo:
                true
            case .singleAccount, .singleAccountAvailableTarget:
                false
            }
        }

        static func == (lhs: Interactor, rhs: Interactor) -> Bool {
            lhs.account.identifier == rhs.account.identifier
        }
    }

    var isSelectable: Bool {
        switch presenter {
        case .radioSelection:
            true
        case .singleAccount,
             .walletInputField,
             .cardView,
             .memo:
            false
        }
    }

    var identity: AnyHashable {
        switch presenter {
        case .cardView(let viewModel):
            return viewModel.identifier
        case .walletInputField:
            return "wallet-input-field"
        case .memo:
            return "memo-field"
        case .radioSelection(let presenter):
            return presenter.identity
        case .singleAccount:
            guard let account else {
                fatalError("Expected an account")
            }
            return account.identifier
        }
    }

    let account: BlockchainAccount?
    let presenter: Presenter

    init(cardView: TargetSelectionCardModel) {
        self.account = nil
        self.presenter = .cardView(cardView)
    }

    init(interactor: Interactor) {
        switch interactor {
        case .singleAccountAvailableTarget(let interactor):
            self.account = interactor.account
            self.presenter = .radioSelection(
                RadioAccountCellPresenter(
                    interactor: interactor,
                    accessibilityPrefix: AssetAction.send.accessibilityPrefix
                )
            )
        case .singleAccount(let account, let interactor):
            self.account = account
            self.presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: .send,
                    interactor: interactor,
                    separatorVisibility: .hidden
                )
            )
        case .walletInputField(let account, let viewModel):
            self.account = account
            self.presenter = .walletInputField(viewModel)
        case .memo(let account, let viewModel):
            self.account = account
            self.presenter = .memo(viewModel)
        }
    }

    static func == (lhs: TargetSelectionPageCellItem, rhs: TargetSelectionPageCellItem) -> Bool {
        lhs.identity == rhs.identity
    }
}
