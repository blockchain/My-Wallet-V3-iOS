//
//  KYCVerifyIdentityInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

protocol KYCVerifyIdentityInput: class {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func createCredentials(
        onSuccess: @escaping ((VeriffCredentials) -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func supportedDocumentTypes(
        countryCode: String,
        onSuccess: @escaping (([KYCDocumentType]) -> Void),
        onError: @escaping ((Error) -> Void)
    )
}

class KYCVerifyIdentityInteractor {
    private let authentication: NabuAuthenticationService

    private var cache = [String: [KYCDocumentType]]()

    private let veriffService = VeriffService()

    private var veriffCredentials: VeriffCredentials?

    private var disposable: Disposable?

    init(authentication: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authentication = authentication
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    private func supportedDocumentTypes(_ countryCode: String) -> Single<[KYCDocumentType]> {
        // Check cache
        if let types = cache[countryCode] {
            return Single.just(types)
        }

        // If not available, request supported document types
        return authentication.getSessionToken().flatMap { tokenResponse -> Single<KYCSupportedDocumentsResponse> in
            let headers = [HttpHeaderField.authorization: tokenResponse.token]
            return KYCNetworkRequest.request(
                get: .supportedDocuments,
                pathComponents: ["kyc", "supported-documents", countryCode],
                headers: headers,
                type: KYCSupportedDocumentsResponse.self
            )
        }
        .map {
            return $0.documentTypes
        }
        .do(onSuccess: { [weak self] types in
            self?.cache[countryCode] = types
        })
    }
}

extension KYCVerifyIdentityInteractor: KYCVerifyIdentityInput {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    ) {
        guard let credentials = veriffCredentials else { return }
        disposable = veriffService.submitVerification(applicantId: credentials.applicantId)
            .do(onDispose: { LoadingViewPresenter.shared.hideBusyView() })
            .subscribe(
                onCompleted: onCompleted,
                onError: onError
            )
    }

    func createCredentials(onSuccess: @escaping ((VeriffCredentials) -> Void), onError: @escaping ((Error) -> Void)) {
        disposable = veriffService.createCredentials()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] credentials in
                guard let this = self else { return }
                this.veriffCredentials = credentials
                onSuccess(credentials)
            }, onError: onError)
    }

    func supportedDocumentTypes(countryCode: String, onSuccess: @escaping (([KYCDocumentType]) -> Void), onError: @escaping ((Error) -> Void)) {
        disposable = supportedDocumentTypes(countryCode)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: onSuccess, onError: onError)
    }
}
