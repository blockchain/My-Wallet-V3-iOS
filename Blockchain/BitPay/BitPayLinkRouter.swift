// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit

/// Handles Bitcoin and Bitcoin Cash BitPay deep links.
class BitPayLinkRouter: DeepLinkRouting {

    // MARK: - Private Properties

    @LazyInject private var coincore: CoincoreAPI
    @LazyInject private var tab: TabSwapping

    private var cancellables: Set<AnyCancellable> = []
    private let service: BitpayServiceProtocol

    // MARK: - Init

    init(bitpayService: BitpayServiceProtocol = BitpayService.shared) {
        self.service = bitpayService
    }

    // MARK: - Static Functions

    static func isBitPayURL(_ url: URL) -> Bool {
        url.absoluteString.contains("https://bitpay.com/")
    }

    // MARK: - DeepLinkRouting

    func routeIfNeeded() -> Bool {
        guard let bitpayURL = service.content else {
            return false
        }

        service.content = nil

        let data = bitpayURL.absoluteString

        guard BitPayInvoiceTarget.isBitPay(data) else {
            return true
        }

        if BitPayInvoiceTarget.isBitcoin(data) {
            handle(data: data, cryptoCurrency: .bitcoin)
        } else if BitPayInvoiceTarget.isBitcoinCash(data) {
            handle(data: data, cryptoCurrency: .bitcoinCash)
        }

        return true
    }

    private func handle(data: String, cryptoCurrency: CryptoCurrency) {
        guard let asset = coincore[cryptoCurrency] else { return }

        let target = BitPayInvoiceTarget
            .make(from: data, asset: cryptoCurrency)
            .eraseError()

        let account = asset
            .defaultAccount
            .eraseError()

        account.zip(target)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] account, target in
                UIView.animate(
                    withDuration: 0.3,
                    animations: { [weak self] in
                        self?.tab.switchToSend()
                    },
                    completion: { [weak self] _ in
                        self?.tab.send(from: account, target: target)
                    }
                )
            }
            .store(in: &cancellables)
    }
}
