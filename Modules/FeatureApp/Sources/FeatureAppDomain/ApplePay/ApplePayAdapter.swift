import BlockchainNamespace
import Combine
import FeatureCardPaymentDomain
import MoneyKit
import PassKit
import PlatformKit
import ToolKit

final class ApplePayAdapter: ApplePayEligibleServiceAPI {

    private let app: AppProtocol
    private let eligibleMethodsClient: PaymentEligibleMethodsClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let tiersService: KYCTiersServiceAPI

    init(
        app: AppProtocol,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        eligibleMethodsClient: PaymentEligibleMethodsClientAPI,
        tiersService: KYCTiersServiceAPI
    ) {
        self.app = app
        self.fiatCurrencyService = fiatCurrencyService
        self.tiersService = tiersService
        self.eligibleMethodsClient = eligibleMethodsClient
    }

    func isFrontendEnabled() -> AnyPublisher<Bool, Never> {
        guard PKPaymentAuthorizationController.canMakePayments() else {
            return .just(false)
        }

        return app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
