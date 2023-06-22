// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
@testable import ComposableNavigation
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import Localization
import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

final class VerifyDeviceReducerTests: XCTestCase {

    private var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    >!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.immediate
        testStore = TestStore(
            initialState: .init(emailAddress: ""),
            reducer: verifyDeviceReducer,
            environment: .init(
                app: App.test,
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: MockDeviceVerificationService(),
                errorRecorder: NoOpErrorRecorder(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock(),
                walletFetcherService: WalletFetcherServiceMock().mock(),
                accountRecoveryService: MockAccountRecoveryService(),
                recaptchaService: MockRecaptchaService()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = VerifyDeviceState(emailAddress: "")
        XCTAssertNil(state.credentialsState)
        XCTAssertNil(state.route)
        XCTAssertEqual(state.credentialsContext, .none)
    }

    func test_on_appear_should_poll_wallet_info() {
        testStore.send(.onAppear)

        testStore.receive(.pollWalletInfo)
        testStore.receive(.didPolledWalletInfo(.success(MockDeviceVerificationService.mockWalletInfo)))
        testStore.receive(.didExtractWalletInfo(MockDeviceVerificationService.mockWalletInfo)) { state in
            state.credentialsContext = .walletInfo(MockDeviceVerificationService.mockWalletInfo)
        }
        testStore.receive(.navigate(to: .credentials)) { state in
            state.credentialsState = CredentialsState(
                walletPairingState: WalletPairingState(
                    emailAddress: MockDeviceVerificationService.mockWalletInfo.wallet!.email!,
                    emailCode: MockDeviceVerificationService.mockWalletInfo.wallet!.emailCode,
                    walletGuid: MockDeviceVerificationService.mockWalletInfo.wallet!.guid
                )
            )
            state.route = RouteIntent(route: .credentials, action: .navigateTo)
        }
    }

    func test_receive_valid_wallet_deeplink_should_update_wallet_info() {
        testStore.send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.validDeeplink))
        testStore.receive(.didExtractWalletInfo(MockDeviceVerificationService.mockWalletInfo)) { state in
            state.credentialsContext = .walletInfo(MockDeviceVerificationService.mockWalletInfo)
        }
        testStore.receive(.navigate(to: .credentials)) { state in
            state.credentialsState = CredentialsState(
                walletPairingState: WalletPairingState(
                    emailAddress: MockDeviceVerificationService.mockWalletInfo.wallet!.email!,
                    emailCode: MockDeviceVerificationService.mockWalletInfo.wallet!.emailCode,
                    walletGuid: MockDeviceVerificationService.mockWalletInfo.wallet!.guid
                )
            )
            state.route = RouteIntent(route: .credentials, action: .navigateTo)
        }

        testStore.send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.deeplinkWithValidGuid))
        testStore.receive(.didExtractWalletInfo(MockDeviceVerificationService.mockWalletInfoWithGuidOnly)) { state in
            state.credentialsContext = .walletIdentifier(
                guid: MockDeviceVerificationService.mockWalletInfoWithGuidOnly.wallet!.guid
            )
        }
        testStore.receive(.navigate(to: .credentials)) { state in
            state.credentialsState = CredentialsState(
                walletPairingState: WalletPairingState(
                    emailAddress: "",
                    walletGuid: MockDeviceVerificationService.mockWalletInfo.wallet!.guid
                )
            )
        }
    }

    func test_deeplink_parsing_failure_should_fallback_to_wallet_identifier() {
        testStore.send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.invalidDeeplink))
        testStore.receive(.fallbackToWalletIdentifier) { state in
            state.credentialsContext = .walletIdentifier(guid: "")
        }
        testStore.receive(.navigate(to: .credentials)) { state in
            state.credentialsState = .init()
            state.route = RouteIntent(route: .credentials, action: .navigateTo)
        }
    }

    // MARK: - Magic Link Decoding

    func test_base64_decode_simple() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoicGF2ZWxAYmxvY2tjaGFpbi5jb20ifX0"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "pavel@blockchain.com"
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_plus_symbol() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoicGF2ZWwrdGVzdEBibG9ja2NoYWluLmNvbSJ9fQ"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "pavel+test@blockchain.com"
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_cyrillic_symbol() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoi0L_QsNCy0LXQu0DQsdC70L7QutGH0LXQudC9LtGA0YQifX0"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "павел@блокчейн.рф"
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_korean_symbol() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoi7YyM67KoQOu4lOuhneyytOyduC5rciJ9fQ"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "파벨@블록체인.kr"
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_basic_wallet_data() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoicGF2ZWxAYmxvY2tjaGFpbi5jb20iLCJpc19tb2JpbGVfc2V0dXAiOnRydWUsImhhc19jbG91ZF9iYWNrdXAiOnRydWV9fQ"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "pavel@blockchain.com",
                isMobileSetup: true,
                hasCloudBackup: true
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_wallet_data_with_cyrillic_symbol() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoi0L_QsNCy0LXQu0DQsdC70L7QutGH0LXQudC9LtGA0YQiLCJpc19tb2JpbGVfc2V0dXAiOnRydWUsImhhc19jbG91ZF9iYWNrdXAiOnRydWV9fQ"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "павел@блокчейн.рф",
                isMobileSetup: true,
                hasCloudBackup: true
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_wallet_data_with_authorization_code() {
        let base64 = "eyJ3YWxsZXQiOnsiZ3VpZCI6Ijc3OTg4Y2E4LWVlNjQtNDA0NC1hMjc5LWU4MTNlZTM4NjhmOSIsImVtYWlsIjoicGF2ZWxAYmxvY2tjaGFpbi5jb20iLCJpc19tb2JpbGVfc2V0dXAiOnRydWUsImhhc19jbG91ZF9iYWNrdXAiOnRydWUsImVtYWlsX2NvZGUiOiJrQW5FNXpRWWdMUWVOOS81b0t3eVQvWDcySjAzcm94TmpEdkY4MnhIUURDZTNRcU9IWklCOG5seTNWRjZKdlVCZy8vdVZGU3FudGdhWk9BbDR2Q0ovMVNGakhTSFNPMzJtaStKdkNhd0EydHJOVkVXbXEwMHU0V0RrUkhoMko2UDlvRFYwTklqcmVyd1VKYVpzRG01TmlVUnY4eHU4eVF6WG5uc1ZDZ0hra0VWc1czdktkN3FBNmlGSjd1bVRaVEgifX0"
        let walletInfo = WalletInfo(
            wallet: WalletInfo.Wallet(
                guid: "77988ca8-ee64-4044-a279-e813ee3868f9",
                email: "pavel@blockchain.com",
                emailCode: "kAnE5zQYgLQeN9/5oKwyT/X72J03roxNjDvF82xHQDCe3QqOHZIB8nly3VF6JvUBg//uVFSqntgaZOAl4vCJ/1SFjHSHSO32mi+JvCawA2trNVEWmq00u4WDkRHh2J6P9oDV0NIjrerwUJaZsDm5NiURv8xu8yQzXnnsVCgHkkEVsW3vKd7qA6iFJ7umTZTH",
                isMobileSetup: true,
                hasCloudBackup: true
            )
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_wallet_data_exchange_only() {
        let base64 = "eyJzZXNzaW9uX2lkIjoiN2Q3MjY3OTItYThiNS00NDc2LWEzYWEtYjJlMjBjZTZlNTU2IiwiZXhjaGFuZ2UiOnsidHdvX2ZhX21vZGUiOmZhbHNlLCJlbWFpbCI6Imxlb3JhKzc0MUBibG9ja2NoYWluLmNvbSJ9LCJ1c2VyX3R5cGUiOiJFWENIQU5HRSIsIm1lcmdlYWJsZSI6ZmFsc2UsInVwZ3JhZGVhYmxlIjp0cnVlLCJleGNoYW5nZV9hdXRoX3VybCI6Imh0dHBzOi8vZXhjaGFuZ2UuZGV2LmJsb2NrY2hhaW4uaW5mby8jL2F1dGg_and0PSJ9"
        let walletInfo = WalletInfo(
            sessionId: "7d726792-a8b5-4476-a3aa-b2e20ce6e556",
            exchangeAuthUrl: "https://exchange.dev.blockchain.info/#/auth?jwt=",
            exchange: WalletInfo.Exchange(
                twoFaMode: false,
                email: "leora+741@blockchain.com"
            ),
            userType: WalletInfo.UserType.exchange,
            mergeable: false,
            upgradeable: true
        )
        verifyDecoding(base64, walletInfo)
    }

    func test_base64_decode_wallet_data_with_full_feature() {
        let base64 = "eyJzZXNzaW9uX2lkIjoiNTFiOWI4YWYtNTQzMC00NzU5LWE5OTctY2E1OThmYmNlMjM0IiwicHJvZHVjdCI6IkVYQ0hBTkdFIiwiZXhjaGFuZ2VfYXV0aF91cmwiOiJodHRwczovL2V4Y2hhbmdlLmRldi5ibG9ja2NoYWluLmluZm8vdHJhZGUvYXV0aD9qd3Q9IiwiZXhjaGFuZ2UiOnsidHdvX2ZhX21vZGUiOmZhbHNlLCJlbWFpbCI6InBhdmVsK2RldjAyQGJsb2NrY2hhaW4uY29tIn0sInVzZXJfdHlwZSI6IldBTExFVF9FWENIQU5HRV9OT1RfTElOS0VEIiwidW5pZmllZCI6ZmFsc2UsIm1lcmdlYWJsZSI6dHJ1ZSwidXBncmFkZWFibGUiOmZhbHNlLCJ3YWxsZXQiOnsiZ3VpZCI6IjQzYzU1Y2VhLTk1MTQtNDA0YS05YzMwLTZkNzViM2I2NGQ3NSIsImVtYWlsIjoicGF2ZWwrZGV2MDJAYmxvY2tjaGFpbi5jb20iLCJ0d29fZmFfdHlwZSI6MCwiZW1haWxfY29kZSI6ImJGb3dGaGh1MDZEa0V6RTNTMURDNHdPZTZvL3FRU2Rrd1FDejF0cmpSdzJhS21aV1lsSFRuQW5oNkszdnUwUTdDbVQ1ZWJyN2twdlJTcUw4aHAzRk9XdkNBRGNaMldPaDdYdHNiSjFjaW1FTXIrdGFLa05VT3VRWVI3dGhibkZsR1NkRmdWdFFqbWhXRUVwREVwMzZMRmlQaVZ5RmR1dlp5Ynhjbm00aDZ2N0doNkNJdG5nNlZ0V05jVEpMTGxpUyIsImlzX21vYmlsZV9zZXR1cCI6ZmFsc2UsImhhc19jbG91ZF9iYWNrdXAiOmZhbHNlLCJzZXNzaW9uX2lkIjoiNTFiOWI4YWYtNTQzMC00NzU5LWE5OTctY2E1OThmYmNlMjM0IiwibmFidSI6eyJ1c2VyX2lkIjoiY2U2OGNhOTgtMDk5Ni00OTkzLTgxZWItZjJmNTk5ZDlhM2I5IiwicmVjb3ZlcnlfdG9rZW4iOiI2YTIwMzQ2Zi1lNjJiLTQwNTctYjkzZC02OTNmYzY2OGU5MTUiLCJyZWNvdmVyYWJsZSI6dHJ1ZX19fQ"
        let walletInfo = WalletInfo(
            sessionId: "51b9b8af-5430-4759-a997-ca598fbce234",
            product: "EXCHANGE",
            exchangeAuthUrl: "https://exchange.dev.blockchain.info/trade/auth?jwt=",
            exchange: WalletInfo.Exchange(
                twoFaMode: false,
                email: "pavel+dev02@blockchain.com"
            ),
            userType: WalletInfo.UserType.notLinked,
            unified: false,
            mergeable: true,
            upgradeable: false,
            wallet: WalletInfo.Wallet(
                guid: "43c55cea-9514-404a-9c30-6d75b3b64d75",
                email: "pavel+dev02@blockchain.com",
                twoFaType: .standard,
                emailCode: "bFowFhhu06DkEzE3S1DC4wOe6o/qQSdkwQCz1trjRw2aKmZWYlHTnAnh6K3vu0Q7CmT5ebr7kpvRSqL8hp3FOWvCADcZ2WOh7XtsbJ1cimEMr+taKkNUOuQYR7thbnFlGSdFgVtQjmhWEEpDEp36LFiPiVyFduvZybxcnm4h6v7Gh6CItng6VtWNcTJLLliS",
                isMobileSetup: false,
                hasCloudBackup: false,
                sessionId: "51b9b8af-5430-4759-a997-ca598fbce234",
                nabu: WalletInfo.Nabu(
                    userId: "ce68ca98-0996-4993-81eb-f2f599d9a3b9",
                    recoveryToken: "6a20346f-e62b-4057-b93d-693fc668e915",
                    recoverable: true
                )
            )
        )
        verifyDecoding(base64, walletInfo)
    }
}

// MARK: - Helpers

private func verifyDecoding(_ base64: String, _ walletInfo: WalletInfo) {
    guard let decodedData = Data(
        base64Encoded: base64.base64URLUnescaped,
        options: .ignoreUnknownCharacters
    ) else {
        XCTFail("Decoding Failed!")
        return
    }
    do {
        let decoded = try JSONDecoder().decode(WalletInfo.self, from: decodedData)
        print(decoded)
        XCTAssertEqual(decoded, walletInfo)
    } catch {
        XCTFail("Decoding Failed!")
    }
}
