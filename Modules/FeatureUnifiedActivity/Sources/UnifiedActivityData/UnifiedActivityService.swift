// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import MoneyKit
import NetworkKit
import ToolKit
import UnifiedActivityDomain

protocol UnifiedActivityServiceAPI {
    var connect: AnyPublisher<WebSocketConnection.Event, Never> { get }
    var subscribeToActivity: AnyPublisher<Void, Never> { get }
}

final class UnifiedActivityService: UnifiedActivityServiceAPI {
    private let webSocketService: WebSocketService
    private let requestBuilder: RequestBuilder
    private let authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI
    private let fiatCurrencyServiceAPI: FiatCurrencyServiceAPI
    private let localeIdentifierService: LocaleIdentifierServiceAPI

    init(
        webSocketService: WebSocketService,
        requestBuilder: RequestBuilder,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        fiatCurrencyServiceAPI: FiatCurrencyServiceAPI,
        localeIdentifierService: LocaleIdentifierServiceAPI
    ) {
        self.webSocketService = webSocketService
        self.requestBuilder = requestBuilder
        self.authenticationDataRepository = authenticationDataRepository
        self.fiatCurrencyServiceAPI = fiatCurrencyServiceAPI
        self.localeIdentifierService = localeIdentifierService
    }

    var connect: AnyPublisher<WebSocketConnection.Event, Never> {
        Deferred { [webSocketService, url] in
            let subject = PassthroughSubject<WebSocketConnection.Event, Never>()
            webSocketService.connect(
                url: url,
                handler: { event in
                    subject.send(event)
                }
            )
            return subject
        }
        .eraseToAnyPublisher()
    }

    var subscribeToActivity: AnyPublisher<Void, Never> {
        authenticationDataRepository.authenticationData.eraseError()
            .zip(fiatCurrencyServiceAPI.displayCurrency.first().eraseError())
            .map { [localeIdentifierService] authenticationData, displayCurrency -> ActivityRequest in
                ActivityRequest(
                    auth: AuthDataPayload(
                        guidHash: authenticationData.guidHash,
                        sharedKeyHash: authenticationData.sharedKeyHash
                    ),
                    params: ActivityRequest.Parameters(
                        timeZone: localeIdentifierService.timezoneIana,
                        fiatCurrency: displayCurrency.code,
                        locales: localeIdentifierService.acceptLanguage
                    )
                )
            }
            .tryMap { payload in
                try payload.encodeToString(encoding: .utf8)
            }
            .handleEvents(receiveOutput: { [webSocketService, url] string in
                webSocketService.send(url: url, message: .string(string))
            })
            .mapToVoid()
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private var url: URL {
        requestBuilder.get(
            path: "/wallet-pubkey"
        )!.urlRequest.url!
    }
}
