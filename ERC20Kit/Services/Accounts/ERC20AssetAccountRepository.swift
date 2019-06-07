//
//  ERC20AssetAccountRepository.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxCocoa

open class ERC20AssetAccountRepository<Token: ERC20Token>: AssetAccountRepositoryAPI {
    public typealias Details = ERC20AssetAccountDetails
    
    public var assetAccountDetails: Maybe<Details> {
        return currentAssetAccountDetails(fromCache: true)
    }
    
    private var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
    
    private let service: ERC20AssetAccountDetailsService<Token>
    
    public init(service: ERC20AssetAccountDetailsService<Token>) {
        self.service = service
    }
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Maybe<Details> {
        let accountId = "0"
        return fetchAssetAccountDetails(for: accountId)
    }
    
    // MARK: Private Functions
    
    private func fetchAssetAccountDetails(for accountID: String) -> Maybe<Details> {
        return service.accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccountDetails.accept(account)
        })
    }
}
