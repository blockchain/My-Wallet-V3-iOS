//
//  AccountPickerInteractor.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol AccountPickerRouting: ViewableRouting {
    // Declare methods the interactor can invoke to manage sub-tree via the router.
}

final class AccountPickerInteractor: PresentableInteractor<AccountPickerPresentable>, AccountPickerInteractable {

    // MARK: - Properties

    weak var router: AccountPickerRouting?

    // MARK: - Private Properties

    private let accountProvider: AccountPickerAccountProviding
    private let didSelect: AccountPickerDidSelect?
    private let disposeBag = DisposeBag()
    private weak var listener: AccountPickerListener?

    // MARK: - Init

    init(presenter: AccountPickerPresentable,
         accountProvider: AccountPickerAccountProviding,
         listener: AccountPickerListenerBridge) {
        self.accountProvider = accountProvider
        switch listener {
        case .simple(let didSelect):
            self.didSelect = didSelect
            self.listener = nil
        case .listener(let listener):
            self.didSelect = nil
            self.listener = listener
        }
        super.init(presenter: presenter)
    }

    // MARK: - Methods

    override func didBecomeActive() {
        super.didBecomeActive()

        let interactorState: Driver<State> = accountProvider.accounts
            .map { accounts -> [AccountPickerCellItem.Interactor] in
                accounts.map(\.accountPickerCellItemInteractor)
            }
            .map { (interactors) -> State in
                State(interactors: interactors)
            }
            .asDriver(onErrorJustReturn: .empty)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            didSelect?(account)
            listener?.didSelect(blockchainAccount: account)
        case .back:
            listener?.didTapBack()
        case .closed:
            listener?.didTapClose()
        case .none:
            break
        }
    }
}

extension AccountPickerInteractor {
    struct State {
        static let empty = State(interactors: [])
        let interactors: [AccountPickerCellItem.Interactor]
    }

    enum Effects {
        case select(BlockchainAccount)
        case back
        case closed
        case none
    }
}

fileprivate extension BlockchainAccount {
    var accountPickerCellItemInteractor: AccountPickerCellItem.Interactor {
        switch self {
        case is SingleAccount:
            let singleAccount = self as! SingleAccount
            return .singleAccount(singleAccount, AccountAssetBalanceViewInteractor(account: singleAccount))
        case is AccountGroup:
            let accountGroup = self as! AccountGroup
            return .accountGroup(
                accountGroup,
                AccountGroupBalanceCellInteractor(balanceViewInteractor: WalletBalanceViewInteractor(account: accountGroup))
            )
        default:
            impossible()
        }
    }
}
