//
//  WalletNabuSyncable.swift
//  Blockchain
//
//  Created by kevinwu on 12/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

// Protocol for syncing Nabu with the wallet state by sending a JWT token to Nabu.
// Conform to this protocol if your class needs to update Nabu with the wallet state (e.g. Settings/Wallet Account Info)
protocol WalletNabuSyncable {
    var disposable: Disposable? { get set }
    var authenticationService: NabuAuthenticationService { get }
    func syncNabuWithWallet(
        successHandler: WalletNabuSyncCompletion?,
        errorHandler: WalletNabuSyncError?
    ) -> Disposable
}

extension SettingsTableViewController: WalletNabuSyncable { }
extension ReminderPresenter: WalletNabuSyncable { }

extension WalletNabuSyncable {
    typealias WalletNabuSyncCompletion = (() -> ())
    typealias WalletNabuSyncError = ((Error) -> Void)

    func syncNabuWithWallet(
        successHandler: WalletNabuSyncCompletion?,
        errorHandler: WalletNabuSyncError?
        ) -> Disposable {
        return authenticationService.updateWalletInfo()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                successHandler?()
            }, onError: { error in
                Logger.shared.error("Error syncing nabu with wallet: \(error.localizedDescription)")
                errorHandler?(error)
            })
    }
}
