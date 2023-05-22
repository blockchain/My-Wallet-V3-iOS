// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureAddressSearchDomain
import FeatureKYCDomain
import FeatureKYCUI
import FeatureOnboardingUI
import FeatureProveDomain
import FeatureProveUI
import FeatureSettingsUI
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public final class KYCAdapter {

    // MARK: - Properties

    private let router: FeatureKYCUI.Routing

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(router: FeatureKYCUI.Routing = resolve()) {
        self.router = router
    }

    // MARK: - Public Interface

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationAndKYCIfNeeded(
                from: presenter,
                requireEmailVerification: requireEmailVerification,
                requiredTier: requiredTier
            )
            .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentEmailVerificationIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<FeatureKYCUI.FlowResult, FeatureKYCUI.RouterError> {
        router
            .presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .eraseToAnyPublisher()
    }
}

extension KYCAdapter {

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requireEmailVerification: Bool,
        requiredTier: KYC.Tier,
        completion: @escaping (FeatureKYCUI.FlowResult) -> Void
    ) {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: requireEmailVerification,
            requiredTier: requiredTier
        )
        .sink(receiveValue: completion)
        .store(in: &cancellables)
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCRouterError {

    public init(_ error: FeatureKYCUI.RouterError) {
        switch error {
        case .emailVerificationFailed:
            self = .emailVerificationFailed
        case .kycVerificationFailed:
            self = .kycVerificationFailed
        case .kycStepFailed:
            self = .kycStepFailed
        }
    }
}

extension KYCRoutingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        case .skipped:
            self = .skipped
        }
    }
}

extension KYCAdapter: PlatformUIKit.KYCRouting {

    public func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationAndKYCIfNeeded(
            from: presenter,
            requireEmailVerification: false,
            requiredTier: requiredTier
        )
        .mapError(KYCRouterError.init)
        .map(KYCRoutingResult.init)
        .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlow(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, Never> {
        router.presentPromptToUnlockMoreTrading(from: presenter)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func presentKYCUpgradeFlowIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        router.presentPromptToUnlockMoreTradingIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - FeatureOnboardingUI.KYCRouterAPI

extension OnboardingResult {

    public init(_ result: FeatureKYCUI.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        case .skipped:
            self = .skipped
        }
    }
}

extension KYCAdapter: FeatureOnboardingUI.KYCRouterAPI {

    public func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.skipped)
            .eraseToAnyPublisher()
    }
}

final class FlowKYCInfoService: FeatureKYCDomain.FlowKYCInfoServiceAPI {

    private let flowKYCInfoService: FeatureProveDomain.FlowKYCInfoServiceAPI

    init(flowKYCInfoService: FeatureProveDomain.FlowKYCInfoServiceAPI = resolve()) {
        self.flowKYCInfoService = flowKYCInfoService
    }

    func isProveFlow() async throws -> Bool? {
        let flowKYCInfo = try await flowKYCInfoService.getFlowKYCInfo()
        return flowKYCInfo?.nextFlow == .prove
    }
}

extension KYCAdapter: FeatureSettingsUI.KYCRouterAPI {

    public func presentLimitsOverview(from presenter: UIViewController) {
        router.presentLimitsOverview(from: presenter)
    }
}

final class KYCProveFlowPresenter: FeatureKYCUI.KYCProveFlowPresenterAPI {

    private let router: FeatureProveDomain.ProveRouterAPI

    init(
        router: FeatureProveDomain.ProveRouterAPI
    ) {
        self.router = router
    }

    func presentFlow(
        country: String,
        state: String?
    ) -> AnyPublisher<KYCProveResult, Never> {
        router.presentFlow(
            proveConfig: .init(
                country: country,
                state: state
            )
        )
        .eraseToEffect()
        .map { KYCProveResult(result: $0) }
        .eraseToAnyPublisher()
    }
}

extension KYCProveResult {
    fileprivate init(result: VerificationResult) {
        switch result {
        case .success:
            self = .success
        case .abandoned:
            self = .abandoned
        case .failure(let errorCode):
            self = .failure(errorCode)
        }
    }
}

final class AddressKYCService: FeatureAddressSearchDomain.AddressServiceAPI {
    typealias Address = FeatureAddressSearchDomain.Address

    private let locationUpdateService: LocationUpdateService

    init(locationUpdateService: LocationUpdateService = LocationUpdateService()) {
        self.locationUpdateService = locationUpdateService
    }

    func fetchAddress() -> AnyPublisher<Address?, AddressServiceError> {
        .just(nil)
    }

    func save(address: Address) -> AnyPublisher<Address, AddressServiceError> {
        guard let userAddress = UserAddress(address: address, countryCode: address.country) else {
            return .failure(AddressServiceError.network(Nabu.Error.unknown))
        }
        return locationUpdateService
            .save(address: userAddress)
            .map { address }
            .mapError(AddressServiceError.network)
            .eraseToAnyPublisher()
    }
}

extension UserAddressSearchResult {
    fileprivate init(addressResult: AddressResult) {
        switch addressResult {
        case .saved:
            self = .saved
        case .abandoned:
            self = .abandoned
        }
    }
}

extension UserAddress {
    fileprivate init?(
        address: FeatureAddressSearchDomain.Address,
        countryCode: String?
    ) {
        guard let countryCode else { return nil }
        self.init(
            lineOne: address.line1,
            lineTwo: address.line2,
            postalCode: address.postCode,
            city: address.city,
            state: address.state,
            countryCode: countryCode
        )
    }
}

extension FeatureAddressSearchDomain.Address {
    fileprivate init(
        address: UserAddress
    ) {
        self.init(
            line1: address.lineOne,
            line2: address.lineTwo,
            city: address.city,
            postCode: address.postalCode,
            state: address.state,
            country: address.countryCode
        )
    }
}

final class AddressSearchFlowPresenter: FeatureKYCUI.AddressSearchFlowPresenterAPI {

    private let addressSearchRouterRouter: FeatureAddressSearchDomain.AddressSearchRouterAPI

    init(
        addressSearchRouterRouter: FeatureAddressSearchDomain.AddressSearchRouterAPI
    ) {
        self.addressSearchRouterRouter = addressSearchRouterRouter
    }

    func openSearchAddressFlow(
        country: String,
        state: String?
    ) -> AnyPublisher<UserAddressSearchResult, Never> {
        typealias Localization = LocalizationConstants.NewKYC.AddressVerification
        let title = Localization.title
        return addressSearchRouterRouter.presentSearchAddressFlow(
            prefill: Address(state: state, country: country),
            config: .init(
                addressSearchScreen: .init(title: title),
                addressEditScreen: .init(
                    title: title,
                    saveAddressButtonTitle: Localization.saveButtonTitle
                )
            )
        )
        .map { UserAddressSearchResult(addressResult: $0) }
        .eraseToAnyPublisher()
    }
}
