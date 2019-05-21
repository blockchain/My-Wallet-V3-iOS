//
//  PaxService.swift
//  Blockchain
//
//  Created by Jack on 11/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit
import ERC20Kit

public final class AnyERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {
    public func fetchWalletAccount(ethereumAddress: String) -> Single<ERC20AccountResponse<Token>> {
        guard let baseURL = URL(string: apiUrl) else {
            return .error(NetworkRequest.NetworkError.generic)
        }
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: [ "v2", "eth", "data", "account", ethereumAddress, "token", Token.contractAddress.rawValue, "wallet" ],
            queryParameters: nil
        ) else {
            return .error(TradeExecutionAPIError.generic)
        }
        return NetworkRequest.GET(url: endpoint, type: ERC20AccountResponse<Token>.self)
            .do(onError: { error in
                Logger.shared.error(error)
            })
    }
    
    private let apiUrl: String
    
    init(apiUrl: String = BlockchainAPI.shared.apiUrl) {
        self.apiUrl = apiUrl
    }
}
