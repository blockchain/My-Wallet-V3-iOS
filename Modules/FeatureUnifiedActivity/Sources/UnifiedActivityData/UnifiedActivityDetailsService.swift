// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import MoneyKit
import NetworkKit
import ToolKit
import UnifiedActivityDomain

public final class UnifiedActivityDetailsService: UnifiedActivityDetailsServiceAPI {
    private let requestBuilder: RequestBuilder
    private let authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI
    private let fiatCurrencyServiceAPI: FiatCurrencyServiceAPI
    private let localeIdentifierService: LocaleIdentifierServiceAPI
    private let networkAdapter: NetworkAdapterAPI

    init(
        requestBuilder: RequestBuilder,
        networkAdapter: NetworkAdapterAPI,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        fiatCurrencyServiceAPI: FiatCurrencyServiceAPI,
        localeIdentifierService: LocaleIdentifierServiceAPI
    ) {
        self.requestBuilder = requestBuilder
        self.authenticationDataRepository = authenticationDataRepository
        self.fiatCurrencyServiceAPI = fiatCurrencyServiceAPI
        self.localeIdentifierService = localeIdentifierService
        self.networkAdapter = networkAdapter
    }

    public func getActivityDetails(activity: ActivityEntry) async throws -> ActivityDetail.GroupedItems {
        guard let displayCurrency = try? await fiatCurrencyServiceAPI.displayCurrency.first().await(),
              let authenticationData = try? await authenticationDataRepository.authenticationData.await()
        else {
            throw NetworkError.unknown
        }

        let activityRequest = ActivityDetailsRequest(
            auth: AuthDataPayload(
                guidHash: authenticationData.guidHash,
                sharedKeyHash: authenticationData.sharedKeyHash
            ),
            localisation: ActivityDetailsRequest.Parameters(
                timeZone: localeIdentifierService.timezoneIana,
                locales: localeIdentifierService.acceptLanguage,
                fiatCurrency: displayCurrency.code
            ),
            txId: activity.id,
            network: activity.network,
            pubKey: activity.pubKey
        )

        do {
            let data = try activityRequest.encode()
            let activityDetails = try await activiyDetails(for: data).await()
            return activityDetails
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    func activiyDetails(
        for data: Data
    ) -> AnyPublisher<ActivityDetail.GroupedItems, NetworkError> {
        let request = requestBuilder.post(
            path: "/wallet-pubkey/activityDetail",
            body: data
        )!
         return networkAdapter.perform(request: request)
    }
}
