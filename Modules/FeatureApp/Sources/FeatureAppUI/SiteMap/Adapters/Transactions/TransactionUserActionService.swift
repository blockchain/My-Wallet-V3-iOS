// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureAppDomain
import FeatureFormDomain
import FeatureKYCDomain
import FeatureProductsDomain
import FeatureTransactionDomain
import FeatureTransactionUI
import PlatformKit

final class TransactionUserActionService: UserActionServiceAPI {

    private let app: AppProtocol
    private let userService: UserAdapterAPI
    private let accountUsageService: KYCAccountUsageServiceAPI
    private(set) var latestUserState: UserState?
    private var cancellables = Set<AnyCancellable>()

    init(
        userService: UserAdapterAPI,
        app: AppProtocol = resolve(),
        accountUsageService: KYCAccountUsageServiceAPI = resolve()
    ) {
        self.userService = userService
        self.app = app
        self.accountUsageService = accountUsageService
        registerForUserStateUpdates()
    }

    func canPresentTransactionFlow(
        toPerform action: TransactionFlowAction
    ) -> AnyPublisher<UserActionServiceResult, Never> {
        userService.userState
            .first()
            .map { [app] userStateResult -> UserActionServiceResult in
                do {
                    guard try app.state.get(blockchain.ux.kyc.extra.questions.form.is.empty) else {
                        return .questions
                    }
                } catch { /* ignore */ }

                let productId = action.productId
                if case .success(let userState) = userStateResult {
                    guard userState.canStartTransactionFlow(for: productId) else {
                        let upgradeTier: KYC.Tier?
                        if let requiredTier = userState.requiredTierToUse(productId) {
                            upgradeTier = KYC.Tier(rawValue: requiredTier)
                        } else {
                            upgradeTier = nil
                        }
                        return .cannotPerform(upgradeTier: upgradeTier)
                    }
                }
                return .canPerform
            }
            .eraseToAnyPublisher()
    }

    private func registerForUserStateUpdates() {
        userService.userState
            .sink { [weak self] userStateResult in
                guard case .success(let userState) = userStateResult else {
                    return
                }
                self?.latestUserState = userState
            }
            .store(in: &cancellables)
    }
}

extension TransactionUserActionService: TransactionRestrictionsProviderAPI {

    func maximumNumbersOfTransactions(for action: AssetAction) -> Int? {
        // Ignore Tier 0 users
        guard latestUserState?.kycStatus != .unverified else {
            return nil
        }

        guard let product = latestUserState?.product(id: action.productId) else {
            return nil
        }

        return product.maxOrdersCap ?? product.maxOrdersLeft
    }
}

extension AssetAction {

    var productId: ProductIdentifier? {
        let productId: ProductIdentifier? = switch self {
        case .buy:
            .buy
        case .sell:
            .sell
        case .swap:
            .swap
        case .deposit:
            .depositFiat
        case .withdraw:
            .withdrawFiat
        case .receive:
            .depositCrypto
        case .send:
            .withdrawCrypto
        default:
            nil
        }
        return productId
    }
}

extension TransactionFlowAction {

    var productId: ProductIdentifier? {
        let productId: ProductIdentifier? = switch self {
        case .buy:
            .buy
        case .sell:
            .sell
        case .swap:
            .swap
        case .deposit:
            .depositFiat
        case .withdraw:
            .withdrawFiat
        case .receive:
            .depositCrypto
        case .send:
            .withdrawCrypto
        default:
            nil
        }
        return productId
    }
}

extension UserState {

    fileprivate func canStartTransactionFlow(for productId: ProductIdentifier?) -> Bool {
        // For first-time users, let them go through the buy flow.
        if productId == .buy, kycStatus == .unverified {
            return true
        }
        // For everyone else, check the actual product.
        guard let product = product(id: productId) else {
            // Let users use products we don't have information for
            return true
        }
        return product.enabled
    }
}
