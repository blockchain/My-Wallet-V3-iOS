//
//  PairPageCellItem.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RxDataSources
import ToolKit

struct TargetSelectionPageCellItem: Equatable, IdentifiableType {

    // MARK: - Properties

    enum Presenter: Equatable {
        case radioSelection(RadioSelectionCellPresenter)
        case cardView(CardViewViewModel)
        case singleAccount(AccountCurrentBalanceCellPresenter)
        case walletInputField(TextFieldViewModel)
    }

    enum Interactor: Equatable {
        case singleAccountAvailableTarget(SingleAccount)
        case singleAccountSelection(SingleAccount)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
        case walletInputField(SingleAccount, TextFieldViewModel)
        
        var account: SingleAccount {
            switch self {
            case .singleAccountAvailableTarget(let account):
                return account
            case .singleAccountSelection(let account):
                return account
            case .singleAccount(let account, _):
                return account
            case .walletInputField(let account, _):
                return account
            }
        }

        var isWalletInputField: Bool {
            switch self {
            case .walletInputField:
                return true
            case .singleAccount,
                 .singleAccountAvailableTarget,
                 .singleAccountSelection:
                return false
            }
        }

        public static func == (lhs: Interactor, rhs: Interactor) -> Bool {
            lhs.account.id == rhs.account.id
        }
    }

    var isSelectable: Bool {
        switch presenter {
        case .radioSelection,
             .walletInputField:
            return true
        case .singleAccount,
             .cardView:
            return false
        }
    }

    var identity: AnyHashable {
        switch presenter {
        case .cardView(let viewModel):
            return viewModel.identifier
        case .radioSelection,
             .singleAccount,
             .walletInputField:
            guard let account = account else {
                fatalError("Expected an account")
            }
            return account.id
        }
    }

    let account: BlockchainAccount?
    let presenter: Presenter
    
    init(cardView: CardViewViewModel) {
        account = nil
        presenter = .cardView(cardView)
    }

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .singleAccountAvailableTarget(let account):
            self.account = account
            presenter = .radioSelection(
                RadioSelectionCellPresenter(
                    account: account
                )
            )
        case .singleAccountSelection(let account):
            self.account = account
            presenter = .radioSelection(
                RadioSelectionCellPresenter(
                    account: account,
                    selected: true
                )
            )
        case .singleAccount(let account, let interactor):
            self.account = account
            presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: assetAction,
                    interactor: interactor,
                    separatorVisibility: .hidden
                )
            )
        case .walletInputField(let account, let viewModel):
            self.account = account
            presenter = .walletInputField(viewModel)
        }
    }

    static func == (lhs: TargetSelectionPageCellItem, rhs: TargetSelectionPageCellItem) -> Bool {
        lhs.identity == rhs.identity
    }
}
