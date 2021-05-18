//
//  ExchangeLinkStatusService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/9/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountStatusServiceAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    var hasEnabled2FA: Single<Bool> { get }
}

public final class ExchangeAccountStatusService: ExchangeAccountStatusServiceAPI {
    
    // MARK: - ExchangeLinkStatusServiceAPI
    
    public var hasLinkedExchangeAccount: Single<Bool> {
        nabuUserService
            .fetchUser()
            .map(\.hasLinkedExchangeAccount)
    }
    
    public var hasEnabled2FA: Single<Bool> {
        /// It does not matter what asset we fetch.
        client.exchangeAddress(with: .bitcoin)
            /// If the user has accounts returned,
            /// then they have 2FA enabled.
            .map { _ in true }
            /// If an error is thrown when fetching accounts
            /// parse the error to determine if it is because 2FA is
            /// not enabled.
            .catchError { error in
                guard let networkError = error as? NetworkCommunicatorError else {
                    throw error
                }
                if case let .serverError(serverError) = networkError,
                   let nabuError = serverError.nabuError,
                   nabuError.code == .bad2fa {
                    return .just(false)
                } else {
                    throw networkError
                }
            }
    }
    
    // MARK: - Private Properties
    
    private let nabuUserService: NabuUserServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    
    // MARK: - Init
    
    init(nabuUserService: NabuUserServiceAPI = resolve(),
         client: ExchangeAccountsClientAPI = resolve()) {
        self.nabuUserService = nabuUserService
        self.client = client
    }
}
