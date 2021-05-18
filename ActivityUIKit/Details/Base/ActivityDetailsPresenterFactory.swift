//
//  ActivityDetailsPresenterFactory.swift
//  Blockchain
//
//  Created by Paulo on 04/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ERC20Kit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class ActivityDetailsPresenterFactory {

    static func presenter(
        for event: ActivityItemEvent, router: ActivityRouterAPI
    ) -> DetailsScreenPresenterAPI {
        switch event {
        case .fiat(let fiat):
            return FiatActivityDetailsPresenter(event: fiat)
        case .buySell(let buySell):
            return BuySellActivityDetailsPresenter(event: buySell)
        case .swap(let swap):
            return SwapActivityDetailsPresenter(event: swap)
        case .transactional(let transactional):
            switch transactional.currency {
            case .algorand, .polkadot:
                fatalError("Activity Details not implemented for \(transactional.currency.name).")
            case .bitcoin:
                return BitcoinActivityDetailsPresenter(event: transactional, router: router)
            case .bitcoinCash:
                return BitcoinCashActivityDetailsPresenter(event: transactional, router: router)
            case .aave, .pax, .tether, .wDGLD, .yearnFinance:
                let interactor = ERC20ActivityDetailsInteractor(cryptoCurrency: transactional.currency)
                return ERC20ActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
            case .stellar:
                return StellarActivityDetailsPresenter(event: transactional, router: router)
            case .ethereum:
                return EthereumActivityDetailsPresenter(event: transactional, router: router)
            }
        }
    }
}
