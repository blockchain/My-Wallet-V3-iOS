//
//  StellarAccountService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift
import RxCocoa

class StellarAccountService: StellarAccountAPI {
    
    fileprivate let configuration: StellarConfiguration
    fileprivate let repository: WalletXlmAccountRepository
    fileprivate lazy var service: AccountService = {
       configuration.sdk.accounts
    }()

    init(configuration: StellarConfiguration = .production,
         repository: WalletXlmAccountRepository
        ) {
        self.configuration = configuration
        self.repository = repository
    }
    
    var currentAccount: StellarAccount? {
        return privateAccount.value
    }
    fileprivate var privateAccount = BehaviorRelay<StellarAccount?>(value: nil)
    
    // MARK: Private Functions
    
    fileprivate func defaultXLMAccount() -> WalletXlmAccount? {
        return repository.defaultAccount
    }
    
    // MARK: Public Functions
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        if let cached = privateAccount.value, fromCache == true {
            return Maybe.just(cached)
        }
        guard let XLMAccount = defaultXLMAccount() else {
            return Maybe.error(StellarServiceError.noXLMAccount)
        }
        let accountID = XLMAccount.publicKey
        return accountDetails(for: accountID).do(onNext: { [weak self] account in
            self?.privateAccount.accept(account)
        })
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return Single<AccountResponse>.create { [weak self] event -> Disposable in
            self?.service.getAccountDetails(accountId: accountID, response: { response -> (Void) in
                switch response {
                case .success(details: let details):
                    event(.success(details))
                case .failure(error: let error):
                    event(.error(error.toStellarServiceError()))
                }
            })
            return Disposables.create()
        }
    }
    
    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return accountResponse(for: accountID).map { details -> StellarAccount in
            return details.toStellarAccount()
        }.asMaybe()
    }
    
    func fundAccount(
        with accountID: StellarAccountAPI.AccountID,
        amount: Decimal,
        completion: @escaping StellarAccountAPI.CompletionHandler) {
        // TODO: Create and fund account
    }
}

// MARK: - Extension

extension AccountResponse {
    func toStellarAccount() -> StellarAccount {
        let totalBalance = balances.reduce(Decimal(0)) { $0 + (Decimal(string: $1.balance) ?? 0) }
        let assetAddress = AssetAddressFactory.create(
            fromAddressString: accountId,
            assetType: .stellar
        )
        let assetAccount = AssetAccount(
            index: 0,
            address: assetAddress,
            balance: totalBalance,
            name: LocalizationConstants.Stellar.defaultLabelName
        )
        return StellarAccount(
            identifier: accountId,
            assetAccount: assetAccount,
            sequence: Int(sequenceNumber),
            subentryCount: Int(subentryCount)
        )
    }
}

extension HorizonRequestError {
    func toStellarServiceError() -> StellarServiceError {
        switch self {
        case .notFound:
            return .noDefaultAccount
        case .rateLimitExceeded:
            return .rateLimitExceeded
        case .internalServerError:
            return .internalError
        case .parsingResponseFailed:
            return .parsingError
        case .forbidden:
            return .forbidden
        default:
            return .unknown
        }
    }
}
