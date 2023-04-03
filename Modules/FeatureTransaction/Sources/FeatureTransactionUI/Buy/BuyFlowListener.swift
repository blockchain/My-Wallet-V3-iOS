// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformUIKit

public protocol BuyFlowListening: AnyObject {
    func buyFlowDidComplete(with result: TransactionFlowResult)
    func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
}

public final class BuyFlowListener: BuyFlowListening {

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let kycRouter: PlatformUIKit.KYCRouting
    private let alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI

    public init(
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI = resolve()
    ) {
        self.kycRouter = kycRouter
        self.alertViewPresenter = alertViewPresenter
    }

    deinit {
        subject.send(completion: .finished)
    }

    public func buyFlowDidComplete(with result: TransactionFlowResult) {
        subject.send(result)
    }

    public func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        // Buy requires Tier 2 for everyone else.
        kycRouter.presentEmailVerificationAndKYCIfNeeded(from: viewController, requiredTier: .verified)
            .receive(on: DispatchQueue.main)
            .sink { [alertViewPresenter] completionResult in
                guard case .failure(let error) = completionResult else {
                    return
                }
                alertViewPresenter.error(
                    in: viewController,
                    message: String(describing: error),
                    action: nil
                )
                completion(false)
            } receiveValue: { result in
                completion(result == .completed || result == .skipped)
            }
            .store(in: &cancellables)
    }
}
