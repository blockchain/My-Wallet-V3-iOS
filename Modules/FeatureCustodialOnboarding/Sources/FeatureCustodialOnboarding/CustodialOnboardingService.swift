import Blockchain
import SwiftUI

@MainActor
public class CustodialOnboardingService: ObservableObject {

    enum OnboardingTask {
        case verifyEmail, verifyIdentity, purchaseCrypto
    }

    @Dependency(\.app) var app

    public private(set) var isSynchronized: Bool = false
    public var isFinished: Bool { isEnabled == false || purchasedCrypto || earningCrypto }

    lazy var bindings = app.binding(self, .async, managing: CustodialOnboardingService.on(update:))
        .subscribe(\.currency, to: blockchain.user.currency.preferred.fiat.display.currency)
        .subscribe(\.verifiedEmail, to: blockchain.user.email.is.verified)
        .subscribe(\.purchasedCrypto, to: blockchain.user.trading.currencies, as: \[String].isNotEmpty)
        .subscribe(\.earningCrypto, to: blockchain.user.earn.has.balance)
        .subscribe(\.isEnabled, to: blockchain.ux.user.custodial.onboarding.is.enabled)
        .subscribe(\.state, to: blockchain.user.account.kyc[blockchain.user.account.tier.gold].state)

    @Published var currency: FiatCurrency = .USD
    @Published var verifiedEmail: Bool = false
    @Published var purchasedCrypto: Bool = false
    @Published var earningCrypto: Bool = false
    @Published var isEnabled: Bool = true
    @Published var state: Tag = blockchain.user.account.kyc.state.none[]

    var isVerified: Bool { state == blockchain.user.account.kyc.state.verified[] }
    var isPending: Bool { state == blockchain.user.account.kyc.state.pending[] || state == blockchain.user.account.kyc.state.under_review[] }
    var isRejected: Bool { state == blockchain.user.account.kyc.state.rejected[] }

    var progress: Double {
        [
            verifiedEmail,
            isVerified || isPending,
            purchasedCrypto || earningCrypto
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
            if isVerified { return .done }
            guard verifiedEmail else { return .todo }
            return isPending ? .pending : .highlighted
        case .purchaseCrypto:
            return verifiedEmail && isVerified ? .highlighted : .todo
        }
    }
}
