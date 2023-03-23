// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public enum KYCStatus {

    /// User has not yet been verified
    case unverified

    /// User has started but not yet finished the verification process
    case verifying

    /// User has been verified
    case verified

    /// Status checking failed
    case failed
}

public protocol KYCStatusChecking {
    func checkStatus() -> Single<KYCStatus>
    func checkStatus(whileLoading: (() -> Void)?) -> Single<KYCStatus>
}

final class KYCStatusChecker: KYCStatusChecking {

    private let kycSettings: KYCSettingsAPI
    private let kycTiersService: KYCTiersServiceAPI

    init(
        kycSettings: KYCSettingsAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.kycSettings = kycSettings
        self.kycTiersService = kycTiersService
    }

    func checkStatus() -> Single<KYCStatus> {
        checkStatus(whileLoading: nil)
    }

    func checkStatus(whileLoading: (() -> Void)?) -> Single<KYCStatus> {
        let isCompletingKyc: Single<Bool> = kycSettings.isCompletingKyc
        let hasAnyApprovedKYCTier: Single<Bool> = kycTiersService
            .fetchTiers()
            .asSingle()
            .map { $0.latestApprovedTier > .unverified }

        return Single.zip(hasAnyApprovedKYCTier, isCompletingKyc)
            .observe(on: MainScheduler.asyncInstance)
            .do(onSubscribe: whileLoading)
            .flatMap(weak: self) { _, payload -> Single<KYCStatus> in
                let (hasAnyApprovedKYCTier, isCompletingKyc) = payload
                switch (hasAnyApprovedKYCTier, isCompletingKyc) {
                case (false, false):
                    return .just(.unverified)
                case (false, true):
                    return .just(.verifying)
                case (true, _):
                    return .just(.verified)
                }
            }
            .catchAndReturn(.failed)
    }
}
