//
//  ExchangeListService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PartnerExchangeServiceDelegate {
    func partnerExchangeDidFailToGetTrades(_ service: PartnerExchangeService, errorDescription: String)
    func partnerExchange(_ service: PartnerExchangeService, didGet exchangeRate: ExchangeRate)
    func partnerExchange(_ service: PartnerExchangeService, didGetBTC availableBalance: NSDictionary)
    func partnerExchange(_ service: PartnerExchangeService, didGetETH availableBalance: NSDictionary)
    func partnerExchange(_ service: PartnerExchangeService, didBuild tradeInfo: NSDictionary)
}

enum PartnerExchangeServiceError: Error {
    case generic
}

class PartnerExchangeService: PartnerExchangeAPI {

    // MARK: Lazy Properties

    lazy var wallet: Wallet = {
        let wallet = WalletManager.shared.wallet
        WalletManager.shared.exchangeDelegate = self
        return wallet
    }()

    // MARK: Public Properties

    var delegate: PartnerExchangeServiceDelegate?

    // MARK: Private Properties

    fileprivate var completionBlock: ExchangeCompletion?

    // MARK: ExchangeListAPI

    func fetchTransactions(with completion: @escaping ExchangeCompletion) {
        completionBlock = completion
        guard wallet.isFetchingExchangeTrades == false else { return }
        wallet.getExchangeTrades()
    }
}

extension PartnerExchangeService: WalletExchangeDelegate {
    func didFailToGetExchangeTrades(errorDescription: String) {
        // Add this alert whenever the delegate is wired up.
        // TODO: AlertViewPresenter.shared.standardError(message: errorDescription)
        delegate?.partnerExchangeDidFailToGetTrades(self, errorDescription: errorDescription)
    }
    
    func didGetExchangeTrades(trades: NSArray) {
        if let block = completionBlock, trades.count == 0 {
            block(.error(nil))
            return
        }
        guard let input = trades as? [ExchangeTrade] else { return }
        let models: [ExchangeTradeModel] = input.map({
            let partnerTrade = PartnerTrade(with: $0)
            let value: ExchangeTradeModel = .partner(partnerTrade)
            return value
        })
        if let block = completionBlock {
            block(.success(models))
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
