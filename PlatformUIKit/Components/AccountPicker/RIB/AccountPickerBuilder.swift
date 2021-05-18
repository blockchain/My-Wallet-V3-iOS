//
//  AccountPickerBuilder.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs

public typealias AccountPickerDidSelect = (BlockchainAccount) -> Void

public enum AccountPickerListenerBridge {
    case simple(AccountPickerDidSelect)
    case listener(AccountPickerListener)
}

public protocol AccountPickerBuildable: Buildable {
    func build(listener: AccountPickerListenerBridge,
               navigationModel: ScreenNavigationModel,
               headerModel: AccountPickerHeaderType) -> AccountPickerRouting
}

public protocol AccountPickerListener: AnyObject {
    func didSelect(blockchainAccount: BlockchainAccount)
    func didTapBack()
    func didTapClose()
}

public final class AccountPickerBuilder: AccountPickerBuildable {

    // MARK: - Private Properties

    private let accountProvider: AccountPickerAccountProviding
    private let action: AssetAction

    // MARK: - Init

    public convenience init(singleAccountsOnly: Bool,
                            action: AssetAction) {
        let provider = AccountPickerDefaultAccountProvider(
            singleAccountsOnly: singleAccountsOnly,
            action: action
        )
        self.init(accountProvider: provider, action: action)
    }

    public init(accountProvider: AccountPickerAccountProviding,
                action: AssetAction) {
        self.accountProvider = accountProvider
        self.action = action
    }
    
    // MARK: - Public Methods
    
    public func build(listener: AccountPickerListenerBridge,
                      navigationModel: ScreenNavigationModel,
                      headerModel: AccountPickerHeaderType) -> AccountPickerRouting {
        let shouldOverrideNavigationEffects: Bool
        switch listener {
        case .listener:
            shouldOverrideNavigationEffects = true
        case .simple:
            shouldOverrideNavigationEffects = false
        }
        let viewController = AccountPickerViewController(
            shouldOverrideNavigationEffects: shouldOverrideNavigationEffects
        )
        let presenter = AccountPickerPresenter(
            viewController: viewController,
            action: action,
            navigationModel: navigationModel,
            headerModel: headerModel
        )
        let interactor = AccountPickerInteractor(
            presenter: presenter,
            accountProvider: accountProvider,
            listener: listener
        )
        return AccountPickerRouter(interactor: interactor, viewController: viewController)
    }
}
