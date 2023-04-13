// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift
import UIKit

enum BankAccountLinkingFlowResult {
    case abandoned
    case completed
}

/// Use this protocol to present the flow to link a bank account  to a user's account via Open Banking or ACH.
///
/// This stand-alone piece is wrapping the entire flow required to link a bank account to the user's account.
/// That account can then be used to buy crypto, deposit, and withdraw funds directly.
///
/// - IMPORTANT: Do NOT use this protocol directly. Use `PaymentMethodLinkingRouterAPI` instead!
protocol BankAccountLinkerAPI {

    /// Presents the bank account linking flow modally on top of the passed-in `presenter`.
    /// - Parameters:
    ///   - presenter: The `UIViewController` that needs to present the linking flow.
    ///   - completion: A closure called when the flow is completed or dismissed.
    func presentBankLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (BankAccountLinkingFlowResult) -> Void
    )
}

final class BankAccountLinker: BankAccountLinkerAPI {

    private var linkBankFlowRouter: LinkBankFlowStarter?
    private var disposeBag = DisposeBag()

    func presentBankLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (BankAccountLinkingFlowResult) -> Void
    ) {
        let builder = LinkBankFlowRootBuilder()
        // we need to pass the the navigation controller so we can present and dismiss from within the flow.
        let router = builder.build()
        linkBankFlowRouter = router
        router
            .startFlow()
            .subscribe(
                onNext: { [weak self] effect in
                    guard let self else { return }
                    linkBankFlowRouter = nil
                    switch effect {
                    case .closeFlow:
                        completion(.abandoned)
                    case .bankLinked:
                        completion(.completed)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
