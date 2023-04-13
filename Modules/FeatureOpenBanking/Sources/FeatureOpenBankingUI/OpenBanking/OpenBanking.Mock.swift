// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG

import Blockchain
import FeatureOpenBankingData
#if canImport(WalletNetworkKit)
import WalletNetworkKit
#else
import NetworkKit
#endif

extension OpenBankingEnvironment {

    public static let mock = OpenBankingEnvironment(
        app: App.preview,
        openBanking: .mock,
        openURL: LogOpenURL(),
        fiatCurrencyFormatter: NoFormatCurrencyFormatter(),
        cryptoCurrencyFormatter: NoFormatCurrencyFormatter(),
        analytics: NoAnalyticsRecorder(),
        currency: "GBP"
    )
}

extension OpenBanking {

    static let mock = OpenBanking(
        app: App.preview,
        banking: OpenBankingClient.mock
    )
}

extension OpenBankingClient {

    static let mock = OpenBankingClient(
        app: App.preview,
        requestBuilder: RequestBuilder(
            config: Network.Config(
                scheme: "https",
                host: "api.blockchain.info",
                components: ["nabu-gateway"]
            ),
            headers: ["Authorization": "Bearer ..."]
        ),
        network: NetworkAdapter(
            communicator: EphemeralNetworkCommunicator(session: .shared)
        ).network
    )
}

extension OpenBanking.BankAccount {

    // swiftlint:disable:next force_try
    static var mock: Self = try! OpenBanking.BankAccount(
        json: [
            "id": "b0ae122f-e71e-4e6c-bc35-16ee64cdcc8f",
            "partner": "YAPILY",
            "attributes": [
                "institutions": Array<Any>(),
                "entity": "Safeconnect(UK)"
            ] as [String: Any],
            "details": [
                "bankName": "Monzo",
                "sortCode": "040040",
                "accountNumber": "94936804"
            ]
        ] as [String: Any]
    )
}

extension OpenBanking.Institution {

    // swiftlint:disable:next force_try
    static var mock: Self = try! OpenBanking.Institution(
        json: [
            "countries": [
                [
                    "countryCode2": "GB",
                    "displayName": "United Kingdom"
                ]
            ],
            "credentialsType": "OPEN_BANKING_UK_AUTO",
            "environmentType": "LIVE",
            "features": Array<Any>(),
            "fullName": "Monzo",
            "id": "monzo_ob",
            "media": [
                [
                    "source": "https://images.yapily.com/image/332bb781-3cc2-4f3e-ae79-1aba09fac991",
                    "type": "logo"
                ],
                [
                    "source": "https://images.yapily.com/image/f70dc041-c7a5-47d3-9c6b-846778eac01a",
                    "type": "icon"
                ]
            ],
            "name": "Monzo"
        ] as [String: Any]
    )
}
#endif

import AnalyticsKit

class NoAnalyticsRecorder: AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvent) {}
}
