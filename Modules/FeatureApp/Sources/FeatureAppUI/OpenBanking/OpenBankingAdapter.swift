// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureOpenBankingDomain
import FeatureOpenBankingUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit

public protocol AppCoordinating: AnyObject {
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool)
}

struct FiatCurrencyFormatter: FeatureOpenBankingUI.FiatCurrencyFormatter {

    func displayString(amountMinor: String, currency: String) -> String? {
        guard
            let currency = fiat(code: currency),
            let fiat = FiatValue.create(minor: amountMinor, currency: currency)
        else { return nil }
        return fiat.displayString
    }

    func displayImage(currency: String) -> ImageResource? {
        fiat(code: currency)?.logoResource
    }

    private func fiat(code currency: String) -> FiatCurrency? {
        FiatCurrency(code: currency)
    }
}

struct CryptoCurrencyFormatter: FeatureOpenBankingUI.CryptoCurrencyFormatter {

    func displayString(amountMinor: String, currency: String) -> String? {
        guard
            let currency = crypto(code: currency),
            let crypto = CryptoValue.create(minor: amountMinor, currency: currency)
        else { return nil }
        return crypto.displayString
    }

    func displayImage(currency: String) -> ImageResource? {
        crypto(code: currency)?.logoResource
    }

    private func crypto(code currency: String) -> CryptoCurrency? {
        CryptoCurrency(code: currency)
    }
}

final class LaunchOpenBankingFlow: StartOpenBanking {

    let linkedBanksService: LinkedBanksServiceAPI

    init(linkedBanksService: LinkedBanksServiceAPI = resolve()) {
        self.linkedBanksService = linkedBanksService
    }

    func link(
        account data: BankLinkageData,
        currency: FiatCurrency,
        listener: LinkBankListener
    ) -> UIViewController {

        let viewController = OpenBankingViewController(
            account: .init(data),
            currency: currency,
            listener: listener
        )

        let navigationController = UINavigationController(rootViewController: viewController)

        viewController.eventPublisher.sink { [weak navigationController, weak listener, linkedBanksService] event in
            switch event {
            case .failure:
                break
            case .success:
                linkedBanksService.invalidate()
                listener?.updateBankLinked()
                navigationController?.dismiss(animated: true)
            }
        }
        .store(in: &viewController.bag)

        return navigationController
    }
}

extension FeatureOpenBankingUI.OpenBankingViewController {

    convenience init(
        account: OpenBanking.BankAccount,
        currency: FiatCurrency,
        listener: LinkBankListener,
        coordinator: AppCoordinating = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.init(
            account: account,
            environment: OpenBankingEnvironment(
                app: app,
                showTransferDetails: {
                    coordinator.showFundTrasferDetails(fiatCurrency: currency, isOriginDeposit: true)
                },
                dismiss: { [weak listener] in
                    listener?.closeFlow(isInteractive: false)
                },
                cancel: { [weak listener] in
                    listener?.closeFlow(isInteractive: false)
                },
                currency: currency.code
            )
        )
    }
}
