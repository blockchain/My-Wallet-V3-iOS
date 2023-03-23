// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import PlatformUIKit

protocol SellFlowListening: AnyObject {
    func sellFlowDidComplete(with result: TransactionFlowResult)
    func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
}

final class SellFlowListener: SellFlowListening {

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()
    private let kycRouter: PlatformUIKit.KYCRouting
    private let alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI

    private var cancellables = Set<AnyCancellable>()

    init(
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI = resolve()
    ) {
        self.kycRouter = kycRouter
        self.alertViewPresenter = alertViewPresenter
    }

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    deinit {
        subject.send(completion: .finished)
    }

    func sellFlowDidComplete(with result: TransactionFlowResult) {
        subject.send(result)
    }

    func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        kycRouter.presentKYCUpgradeFlowIfNeeded(from: viewController, requiredTier: .verified)
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
            } receiveValue: { result in
                completion(result == .completed || result == .skipped)
            }
            .store(in: &cancellables)
    }
}
