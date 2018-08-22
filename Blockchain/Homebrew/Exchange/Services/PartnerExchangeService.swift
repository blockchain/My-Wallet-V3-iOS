//
//  ExchangeListService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PartnerExchangeServiceDelegate {
    func partnerExchange(_ service: PartnerExchangeService, didGet exchangeRate: ExchangeRate)
    func partnerExchange(_ service: PartnerExchangeService, didGetBTC availableBalance: NSDictionary)
    func partnerExchange(_ service: PartnerExchangeService, didGetETH availableBalance: NSDictionary)
    func partnerExchange(_ service: PartnerExchangeService, didBuild tradeInfo: NSDictionary)
}

class PartnerExchangeService: PartnerExchangeAPI {

    // MARK: Lazy Properties

    lazy var wallet: Wallet = {
        let wallet = WalletManager.shared.wallet
        return wallet
    }()

    // MARK: Public Properties

    var delegate: PartnerExchangeServiceDelegate?

    // MARK: Private Properties

    fileprivate var completionBlock: ExchangeCompletion?

    // MARK: Lifecycle

    init() {
        WalletManager.shared.exchangeDelegate = self
    }

    // MARK: ExchangeListAPI

    func fetchTransactions(with completion: @escaping ExchangeCompletion) {
        completionBlock = completion
        guard wallet.isFetchingExchangeTrades == false else { return }
        wallet.getExchangeTrades()
    }
}

extension PartnerExchangeService: WalletExchangeDelegate {
    func didGetExchangeTrades(trades: NSArray) {
        if let block = completionBlock, trades.count == 0 {
            block(nil, nil)
            return
        }
        guard let input = trades as? [ExchangeTrade] else { return }
        let models: [ExchangeTradeCellModel] = input.map({ return ExchangeTradeCellModel(with: $0) })
        if let block = completionBlock {
            block(models, nil)
        }
    }

    func didGetExchangeRate(rate: ExchangeRate) {
        delegate?.partnerExchange(self, didGet: rate)
    }

    func didGetAvailableBtcBalance(result: NSDictionary?) {
        guard let value = result else { return }
        delegate?.partnerExchange(self, didGetBTC: value)
    }

    func didGetAvailableEthBalance(result: NSDictionary) {
        delegate?.partnerExchange(self, didGetETH: result)
    }

    func didBuildExchangeTrade(tradeInfo: NSDictionary) {
        delegate?.partnerExchange(self, didBuild: tradeInfo)
    }

    func didShiftPayment() {
        // TODO:
    }

}
