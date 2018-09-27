//
//  ExchangeAssetAccountListPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ExchangeAction {
    case exchanging
    case receiving

    var title: String {
        switch self {
        case .exchanging: return LocalizationConstants.Exchange.whatDoYouWantToExchange
        case .receiving: return LocalizationConstants.Exchange.whatDoYouWantToReceive
        }
    }
}

protocol ExchangeAssetAccountListView: class {
    func showPicker(for assetAccounts: [AssetAccount], action: ExchangeAction)
}

/// A presenter that presents a list of `AssetAccount` that the user can
/// select to exchange crypto into or out of
class ExchangeAssetAccountListPresenter {

    private weak var view: ExchangeAssetAccountListView?
    private let assetAccountRepository: AssetAccountRepository

    init(
        view: ExchangeAssetAccountListView,
        assetAccountRepository: AssetAccountRepository = AssetAccountRepository.shared
    ) {
        self.view = view
        self.assetAccountRepository = assetAccountRepository
    }

    func presentPicker(excludingAccount assetAccount: AssetAccount?, for action: ExchangeAction) {
        let accountsToPick = assetAccountRepository.allAccounts().filter { account -> Bool in
            guard let excluding = assetAccount else { return true }
            return account != excluding
        }
        view?.showPicker(for: accountsToPick, action: action)
    }
}
