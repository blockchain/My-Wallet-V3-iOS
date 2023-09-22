// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxRelay
import RxSwift

public typealias CompleteSettingsServiceAPI =
    EmailSettingsServiceAPI &
    FiatCurrencySettingsServiceAPI &
    LastTransactionSettingsUpdateServiceAPI &
    SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI &
    UpdateMobileSettingsServiceAPI &
    VerifyMobileSettingsServiceAPI

public typealias MobileSettingsServiceAPI =
    SettingsServiceAPI & UpdateMobileSettingsServiceAPI &
    VerifyMobileSettingsServiceAPI

public enum SettingsServiceError: Error {
    case timedOut
    case fetchFailed(Error)
}

public protocol SettingsServiceCombineAPI: AnyObject {

    var singleValuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> { get }
    var valuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> { get }

    func fetchPublisher(force: Bool) -> AnyPublisher<WalletSettings, SettingsServiceError>
}

public protocol SettingsServiceAPI: SettingsServiceCombineAPI {
    var valueSingle: Single<WalletSettings> { get }
    var valueObservable: Observable<WalletSettings> { get }

    func fetch(force: Bool) -> Single<WalletSettings>
}

public protocol LastTransactionSettingsUpdateServiceAPI: AnyObject {
    func updateLastTransaction() -> Completable
}

public protocol UpdateMobileSettingsServiceAPI {
    func update(mobileNumber: String) -> Completable
}

public protocol VerifyMobileSettingsServiceAPI {
    func verify(with code: String) -> Completable
}

public protocol SMSTwoFactorSettingsServiceAPI: SettingsServiceAPI {
    func smsTwoFactorAuthentication(enabled: Bool) -> Completable
}
