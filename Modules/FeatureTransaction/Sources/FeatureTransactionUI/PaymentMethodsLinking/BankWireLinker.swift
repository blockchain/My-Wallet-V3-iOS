// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIKit

/// This protocol provides an interface to present a screen with bank wiring instructions to link a bank account to a user's account
/// by having them send a bank transfer to Blockchain's custodial services. The bank account can then be used to deposit and withdraw funds.
///
/// This stand-alone piece is wrapping the entire flow required to provide the region-specific bank account details to the user for wiring funds into their
/// fiat account's balance.
///
/// - IMPORTANT: Do NOT use this protocol directly. Use `PaymentMethodLinkingRouterAPI` instead!
protocol BankWireLinkerAPI {

    /// Presents a view controller with bank transfer instructions so the user can send funds to Blockchain's custodial services and thus link their bank account
    /// with their wallet account. That account can then be used to deposit and withdraw funds.
    func presentBankWireInstructions(from presenter: UIViewController, completion: @escaping () -> Void)
}

final class BankWireLinker: BankWireLinkerAPI {

    private let app: AppProtocol
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let analytics: AnalyticsEventRecorderAPI
    private var disposeBag: DisposeBag!

    init(
        app: AppProtocol = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        analytics: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.app = app
        self.fiatCurrencyService = fiatCurrencyService
        self.analytics = analytics
    }

    func presentBankWireInstructions(from presenter: UIViewController, completion: @escaping () -> Void) {
        disposeBag = DisposeBag() // avoid memory leak when binding completion

        if
            let code = app.state.result(for: blockchain.user.currency.preferred.fiat.trading.currency).decode(String.self).value,
            app.remoteConfiguration.result(for: blockchain.app.configuration.wire.transfer[code].is.enabled).value as? Bool == true
        {
            Task {
                app.state.set(blockchain.api.nabu.gateway.payments.accounts.simple.buy.id, to: code)
                app.post(
                    action: blockchain.ux.payment.method.wire.transfer.entry.paragraph.row.tap.then.enter.into,
                    value: blockchain.ux.payment.method.wire.transfer
                )
            }
            return
        }

        fundsTransferDetailsViewController(completion: completion)
            .subscribe(on: MainScheduler.instance)
            .subscribe { viewController in
                presenter.present(viewController, animated: true)
            } onFailure: { error in
                Logger.shared.error(error)
            }
            .disposed(by: disposeBag)
    }

    /// Generates and returns the `DetailsScreenViewController` for funds transfer
    /// The screen matches the wallet's currency
    /// - Returns: `Single<UIViewController>`
    private func fundsTransferDetailsViewController(completion: @escaping () -> Void) -> Single<UIViewController> {
        fiatCurrencyService.tradingCurrency
            .asSingle()
            .map(weak: self) { (self, fiatCurrency) in
                self.fundsTransferDetailsViewController(
                    for: fiatCurrency,
                    isOriginDeposit: false,
                    completion: completion
                )
            }
    }

    /// Generates and returns the `DetailsScreenViewController` for funds transfer
    /// - Parameter fiatCurrency: The fiat currency for which the transfer details will be retrieved
    /// - Returns: A `DetailsScreenViewController` that shows the funds transfer details
    private func fundsTransferDetailsViewController(
        for fiatCurrency: FiatCurrency,
        isOriginDeposit: Bool,
        completion: @escaping () -> Void
    ) -> UIViewController {
        let interactor = InteractiveFundsTransferDetailsInteractor(
            fiatCurrency: fiatCurrency
        )

        let navigationController = UINavigationController()

        let webViewRouter = WebViewRouter(
            topMostViewControllerProvider: navigationController
        )

        let presenter = FundsTransferDetailScreenPresenter(
            webViewRouter: webViewRouter,
            analyticsRecorder: analytics,
            interactor: interactor,
            isOriginDeposit: isOriginDeposit
        )
        presenter.backRelay
            .bind(onNext: completion)
            .disposed(by: disposeBag)

        let viewController = DetailsScreenViewController(presenter: presenter)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
}
