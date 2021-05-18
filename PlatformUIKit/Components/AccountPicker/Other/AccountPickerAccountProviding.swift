//
//  AccountPickerAccountProviding.swift
//  PlatformUIKit
//
//  Created by Paulo on 06/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol AccountPickerAccountProviding: AnyObject {
    var accounts: Single<[BlockchainAccount]> { get }
}

public final class AccountPickerDefaultAccountProvider: AccountPickerAccountProviding {

    // MARK: - Types

    private enum Error: LocalizedError {
        case failedLoadingWallet(action: AssetAction, asset: String, name: String)

        var errorDescription: String? {
            switch self {
            case let .failedLoadingWallet(action, asset, name):
                return "Failed to load wallet asset '\(asset)' name '\(name)' action '\(action)'"
            }
        }
    }

    // MARK: - Private Properties

    private let action: AssetAction
    private let coincore: Coincore
    private let singleAccountsOnly: Bool
    private let failSequence: Bool
    private let errorRecorder: ErrorRecording

    // MARK: - Properties

    public var accounts: Single<[BlockchainAccount]> {
        coincore.allAccounts
            .map { [singleAccountsOnly] allAccountsGroup -> [BlockchainAccount] in
                if singleAccountsOnly {
                    return allAccountsGroup.accounts
                }
                return [allAccountsGroup] + allAccountsGroup.accounts
            }
            .flatMapFilter(
                action: action,
                failSequence: failSequence,
                onError: { [weak self] account in
                    guard let self = self else { return }
                    let asset: String
                    if let account = account as? SingleAccount {
                        asset = account.currencyType.displaySymbol
                    } else {
                        asset = "unknown"
                    }
                    let error: Error = .failedLoadingWallet(action: self.action, asset: asset, name: account.label)
                    self.errorRecorder.error(error)
                }
            )
    }

    // MARK: - Init

    /// Default initializer.
    /// - Parameters:
    ///   - singleAccountsOnly: If the return should be filtered to included only `SingleAccount`s. (opposed to `AccountGroup`s)
    ///   - coincore: A `Coincore` instance.
    ///   - errorRecorder: An `ErrorRecording` instance.
    ///   - action: The desired action. This account provider will only return accounts/account groups that can execute this action.
    ///   - failSequence: A flag indicating if, in the event of a wallet erring out, the whole `accounts: Single<[BlockchainAccount]>` sequence should err or if the offending element should be filtered out. Check `flatMapFilter`.
    public init(singleAccountsOnly: Bool,
                coincore: Coincore = resolve(),
                errorRecorder: ErrorRecording = resolve(),
                action: AssetAction,
                failSequence: Bool = true) {
        self.action = action
        self.coincore = coincore
        self.singleAccountsOnly = singleAccountsOnly
        self.failSequence = failSequence
        self.errorRecorder = errorRecorder
    }
}
