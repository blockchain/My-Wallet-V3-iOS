//
//  ExchangeListService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListServiceDelegate {
    func exchangeService(_ service: ExchangeListService, didGet exchangeRate: ExchangeRate)
    func exchangeService(_ service: ExchangeListService, didGetBTC availableBalance: NSDictionary)
    func exchangeService(_ service: ExchangeListService, didGetETH availableBalance: NSDictionary)
    func exchangeService(_ service: ExchangeListService, didBuild tradeInfo: NSDictionary)
}

class ExchangeListService: ExchangeListAPI {

    // MARK: Lazy Properties

    lazy var wallet: Wallet = {
        let wallet = WalletManager.shared.wallet
        return wallet
    }()

    // MARK: Public Properties

    var delegate: ExchangeListServiceDelegate?

    // MARK: Private Properties

    fileprivate var completionBlock: ExchangeListCompletion?

    // MARK: Lifecycle

    init() {
        WalletManager.shared.exchangeDelegate = self
    }

    // MARK: ExchangeListAPI

    func fetchTransactions(with completion: @escaping ExchangeListCompletion) {
        completionBlock = completion
        guard wallet.isFetchingExchangeTrades == false else { return }
        wallet.getExchangeTrades()
    }
}

extension ExchangeListService: WalletExchangeDelegate {
    func didGetExchangeTrades(trades: NSArray) {
        guard let input = trades as? [ExchangeTrade] else { return }
        let models: [ExchangeTradeCellModel] = input.map({ return ExchangeTradeCellModel(with: $0) })
        if let block = completionBlock {
            block(models, nil)
        }
    }

    func didGetExchangeRate(rate: ExchangeRate) {
        delegate?.exchangeService(self, didGet: rate)
    }

    func didGetAvailableBtcBalance(result: NSDictionary?) {
        guard let value = result else { return }
        delegate?.exchangeService(self, didGetBTC: value)
    }

    func didGetAvailableEthBalance(result: NSDictionary) {
        delegate?.exchangeService(self, didGetETH: result)
    }

    func didBuildExchangeTrade(tradeInfo: NSDictionary) {
        delegate?.exchangeService(self, didBuild: tradeInfo)
    }

    func didShiftPayment() {
        // TODO:
    }

}
