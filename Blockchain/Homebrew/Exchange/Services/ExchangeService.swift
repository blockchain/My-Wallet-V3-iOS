//
//  ExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ListPresentationUpdate<T: Equatable> {
    typealias Deleted = IndexPath
    typealias Inserted = IndexPath

    case insert(IndexPath, T)
    case delete(IndexPath)
    case move(Deleted, Inserted, T)
    case update(IndexPath, T)
}

protocol ExchangeServiceDelegate: class {
    func exchangeServiceDidBeginUpdates(_ service: ExchangeService)
    func exchangeServiceDidEndUpdates(_ service: ExchangeService)
    func exchangeService(_ service: ExchangeService, didUpdate: ListPresentationUpdate<[ExchangeTradeCellModel]>)
    func exchangeService(_ service: ExchangeService, didReturn error: Error)
}

// TODO: Note this is a WIP. 
class ExchangeService: NSObject {

    weak var delegate: ExchangeServiceDelegate?

    fileprivate var tradeModels: Set<ExchangeTradeCellModel> = []
    fileprivate let partnerAPI: PartnerExchangeAPI
    fileprivate let homebrewAPI: HomebrewExchangeAPI

    override init() {
        partnerAPI = PartnerExchangeService()
        homebrewAPI = HomebrewExchangeService()
        super.init()
    }

    fileprivate func differentiateAndAppend(_ models: [ExchangeTradeCellModel]) {
        models.forEach { [weak self] (model) in
            guard let this = self else { return }
            this.tradeModels.insert(model)
        }
        let sorted = tradeModels.sorted(by: { $0.transactionDate.compare($1.transactionDate) == .orderedDescending })
        
    }

}
