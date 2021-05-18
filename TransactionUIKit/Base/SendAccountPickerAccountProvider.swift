//
//  SendAccountPickerAccountProvider.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/18/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

/// An AccountPickerAccountProvider for the Send Screen.
/// This only supports `.send` action.
final class SendAccountPickerAccountProvider: AccountPickerAccountProviding {

    private enum Error: LocalizedError {
        case failedLoadingWallet(asset: String, name: String)

        var errorDescription: String? {
            switch self {
            case let .failedLoadingWallet(asset, name):
                return "Failed to load wallet asset '\(asset)' name '\(name)'"
            }
        }
    }

    // MARK: - Private Properties

    private let coincore: Coincore
    private let errorRecorder: ErrorRecording

    // MARK: - Properties

    public var accounts: Single<[BlockchainAccount]> {
        coincore.allAccounts
            .map(\.accounts)
            .map { accounts in
                accounts.filter { $0 is NonCustodialAccount }
            }
            .flatMapFilter(
                action: .send,
                failSequence: false,
                onError: { [weak self] account in
                    guard let self = self else { return }
                    let asset: String
                    if let account = account as? SingleAccount {
                        asset = account.currencyType.displaySymbol
                    } else {
                        asset = "unknown"
                    }
                    let error: Error = .failedLoadingWallet(asset: asset, name: account.label)
                    self.errorRecorder.error(error)
                }
            )
    }

    // MARK: - Init

    public init(coincore: Coincore = resolve(),
                errorRecorder: ErrorRecording = resolve()) {
        self.coincore = coincore
        self.errorRecorder = errorRecorder
    }
}
