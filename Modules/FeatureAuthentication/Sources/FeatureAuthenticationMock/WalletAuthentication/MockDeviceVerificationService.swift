// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import Foundation

final class MockDeviceVerificationService: DeviceVerificationServiceAPI {

    static let validDeeplink = URL(string: "https://login.blockchain.com/#/login/eyJndWlkIjoiNzRjNzZlOTMtZWUwZi00ZjllLWJmYTYtNzE2ZTg0N2EwMmQ5IiwiZW1haWwiOiJncmF5c29uQGJsb2NrY2hhaW4uY29tIiwiaXNfbW9iaWxlX3NldHVwIjpmYWxzZSwiaGFzX2Nsb3VkX2JhY2t1cCI6ZmFsc2UsImVtYWlsX2NvZGUiOiJCcmgxa252NFh6eEg3bmZITnRzZE5uWVpWbFZvQ1BTWlBJVUNBUWIvTDB6eG1xVFg0OVNDR0QxRURhQ3FWMFJ1R3VxQ2xacHYyUjBVTldHdGdnd08rV29aZTd3SzlPUTRNWE5uZEFxdTVDQkJsQUpXaFIrWUttbTRmbVlBN25KRklpMi9MQjlsMkFpSmZuWUpMMndmUnN4czNNc0RzbGFud1lmc1c4Yyt2NVJHb3dvVk91V1BoYUZnSXZyakg4MzUifQ")!

    static let invalidDeeplink = URL(string: "https://")!
    static let deeplinkWithValidGuid = URL(string: "https://login.blockchain.com/#/login/cd76e920-7a39-4458-829a-1bb752ef628d")!

    static let mockWalletInfo = WalletInfo(
        wallet: WalletInfo.Wallet(
            guid: "cd76e920-7a39-4458-829a-1bb752ef628d",
            email: "test@example.com",
            emailCode: "example email code",
            isMobileSetup: false,
            hasCloudBackup: false,
            nabu: nil
        )
    )

    static let mockWalletInfoWithTwoFA = WalletInfo(
        wallet: WalletInfo.Wallet(
            guid: "cd76e920-7a39-4458-829a-1bb752ef628d",
            email: "test@example.com",
            twoFaType: .sms,
            emailCode: "example email code",
            isMobileSetup: false,
            hasCloudBackup: false,
            sessionId: nil
        )
    )

    static let mockWalletInfoWithGuidOnly = WalletInfo(
        wallet: WalletInfo.Wallet(
            guid: "cd76e920-7a39-4458-829a-1bb752ef628d"
        )
    )

    var expectedSessionMismatch: Bool = false

    func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        // always succeed
        .just(())
    }

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        // always succeed
        .just(())
    }

    func handleLoginRequestDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        if expectedSessionMismatch {
            return .failure(
                .sessionTokenMismatch(originSession: "", base64Str: "")
            )
        }
        if deeplink == MockDeviceVerificationService.validDeeplink {
            return .just(MockDeviceVerificationService.mockWalletInfo)
        } else if deeplink == MockDeviceVerificationService.deeplinkWithValidGuid {
            return .just(MockDeviceVerificationService.mockWalletInfoWithGuidOnly)
        } else {
            return .failure(.failToDecodeBase64Component)
        }
    }

    func pollForWalletInfo() -> AnyPublisher<Result<WalletInfo, WalletInfoPollingError>, DeviceVerificationServiceError> {
        .just(.success(MockDeviceVerificationService.mockWalletInfo))
    }

    func authorizeVerifyDevice(from sessionToken: String, payload: String, confirmDevice: Bool?) -> AnyPublisher<Void, AuthorizeVerifyDeviceError> {
        guard let confirmDevice else {
            return .failure(
                .confirmationRequired(
                    requestTime: Date(timeIntervalSince1970: 1000),
                    details: DeviceVerificationDetails(originLocation: "", originIP: "", originBrowser: "")
                )
            )
        }
        if confirmDevice {
            return .just(())
        } else {
            return .failure(.requestDenied)
        }
    }
}
