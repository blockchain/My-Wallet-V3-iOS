// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

/// An AccountPickerAccountProviding for Receive that replaces missing ERC20 assets with BlockchainAccount placeholders.
final class ReceiveAccountProvider: AccountPickerAccountProviding {

    // MARK: - Types

    private enum Error: LocalizedError {
        case loadingFailed(account: BlockchainAccount, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let account, let action, let error):
                let type = String(reflecting: account)
                let asset = account.currencyType.code
                let label = account.label
                return "Failed to load: '\(type)' asset '\(asset)' label '\(label)' action '\(action)'  error '\(error)'."
            }
        }
    }

    // MARK: - Private Properties

    private let coincore: CoincoreAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let errorRecorder: ErrorRecording
    private let app: AppProtocol

    // MARK: - Properties

    var accounts: Observable<[BlockchainAccount]> {
        let allERC20 = Set(enabledCurrenciesService.allEnabledCryptoCurrencies.filter(\.isERC20))
        return app.modePublisher()
            .flatMap { [coincore] appMode in
                coincore.allAccounts(filter: appMode.filter)
            }
            .map(\.accounts)
            .eraseError()
            .flatMapFilter(
                action: .receive,
                failSequence: false,
                onFailure: { [errorRecorder] account, error in
                    let error: Error = .loadingFailed(
                        account: account,
                        action: .receive,
                        error: error.localizedDescription
                    )
                    errorRecorder.error(error)
                }
            )
            .map { accounts -> [BlockchainAccount] in
                let present: Set<CryptoCurrency> = Set(accounts.map(\.currencyType).compactMap(\.cryptoCurrency))
                let missingERC20: Set<CryptoCurrency> = allERC20.subtracting(present)
                let newAccounts = missingERC20.map { cryptoCurrency in
                    ReceivePlaceholderCryptoAccount(asset: cryptoCurrency)
                }
                return accounts + newAccounts
            }
            .asObservable()
    }

    // MARK: - Init

    init(
        coincore: CoincoreAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
        self.errorRecorder = errorRecorder
        self.app = app
    }
}
