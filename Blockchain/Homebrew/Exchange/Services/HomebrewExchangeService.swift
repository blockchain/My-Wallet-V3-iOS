//
//  HomebrewExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol HomebrewExchangeAPI {
    func nextPage(fromTimestamp: Date, completion: @escaping ExchangeCompletion)
}

enum HomebrewExchangeServiceError: Error {
    case generic
}

class HomebrewExchangeService: HomebrewExchangeAPI {
    
    fileprivate let authentication: NabuAuthenticationService
    fileprivate var disposable: Disposable?
    
    init(service: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authentication = service
    }
    
    deinit {
        disposable?.dispose()
    }

    func nextPage(fromTimestamp: Date, completion: @escaping ExchangeCompletion) {
        
        disposable = trades(before: fromTimestamp)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                let result: [ExchangeTradeModel] = payload.map({ return .homebrew($0) })
                completion(.success(result))
            }, onError: { error in
                completion(.error(error))
            })
    }
    
    fileprivate func trades(before timestamp: Date) -> Single<[ExchangeTradeCellModel]> {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return .error(HomebrewExchangeServiceError.generic)
        }
        
        let timestamp = DateFormatter.sessionDateFormat.string(from: timestamp)
        guard let endpoint = URL.endpoint(baseURL, pathComponents: ["trades"], queryParameters: ["before": timestamp]) else {
            return .error(HomebrewExchangeServiceError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.GET(url: endpoint, body: nil, token: token.token, type: [ExchangeTradeCellModel].self)
        }
    }
}
