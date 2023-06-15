import Blockchain
import SwiftUI

@MainActor
public class CustodialOnboardingService: ObservableObject {

    enum OnboardingTask {
        case verifyEmail, verifyIdentity, purchaseCrypto
    }

    @Dependency(\.app) var app

    public private(set) var isSynchronized: Bool = false
    public var isFinished: Bool { isEnabled == false || purchasedCrypto }

    lazy var bindings = app.binding(self, .async, managing: CustodialOnboardingService.on(update:))
        .subscribe(\.currency, to: blockchain.user.currency.preferred.fiat.display.currency)
        .subscribe(\.verifiedEmail, to: blockchain.user.email.is.verified)
        .subscribe(\.verifiedIdentity, to: blockchain.user.is.verified)
        .subscribe(\.purchasedCrypto, to: blockchain.coin.core.accounts.custodial.crypto.with.balance, as: \[String].isNotEmpty)
        .subscribe(\.isEnabled, to: blockchain.ux.user.custodial.onboarding.is.enabled)

    @Published var currency: FiatCurrency = .USD
    @Published var verifiedEmail: Bool = false
    @Published var verifiedIdentity: Bool = false
    @Published var purchasedCrypto: Bool = false
    @Published var isEnabled: Bool = true

    var progress: Double {
        [
            verifiedEmail,
            verifiedIdentity,
            purchasedCrypto
        ].count(where: \.isYes).d / 3.d
    }

    public init() { }

    @discardableResult
    public func request() -> Bindings {
        if BuildFlag.isInternal {
            bindings.subscribe(\.purchasedCrypto, to: blockchain.ux.user.custodial.onboarding.dashboard.test.has.purchased.crypto)
        }
        return bindings.request()
    }

    func on(update: Bindings.Update) {
        switch update {
        case .didSynchronize:
            isSynchronized = true
            if BuildFlag.isInternal {
                app.state.set(blockchain.ux.user.custodial.onboarding.dashboard.test.has.purchased.crypto, to: purchasedCrypto)
            }
        default:
            break
        }
    }

    func state(for task: OnboardingTask) -> CustodialOnboardingTaskRowView.ViewState {
        switch task {
        case .verifyEmail:
            return verifiedEmail ? .done : .highlighted
        case .verifyIdentity:
            if verifiedIdentity { return .done }
            return verifiedEmail ? .highlighted : .todo
        case .purchaseCrypto:
            return verifiedEmail && verifiedIdentity ? .highlighted : .todo
        }
    }
}
