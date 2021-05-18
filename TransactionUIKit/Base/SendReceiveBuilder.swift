//
//  SendReceiveBuilder.swift
//  TransactionUIKit
//
//  Created by Paulo on 15/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import UIKit

public final class SendReceiveBuilder {
    private typealias LocalizedSend = LocalizationConstants.Send
    private typealias LocalizedReceive = LocalizationConstants.Receive

    private let sendSelectionService: AccountSelectionServiceAPI
    private let receiveSelectionService: AccountSelectionServiceAPI

    init(sendSelectionService: AccountSelectionServiceAPI,
         receiveSelectionService: AccountSelectionServiceAPI) {
        self.sendSelectionService = sendSelectionService
        self.receiveSelectionService = receiveSelectionService
    }

    var receiveAccountPickerRouter: AccountPickerRouting!
    public func receive() -> UIViewController {
        let header = AccountPickerHeaderModel(
            title: LocalizedReceive.Header.receiveCryptoNow,
            subtitle: LocalizedReceive.Header.chooseAWalletToReceiveTo,
            imageContent: .init(
                imageName: ImageAsset.iconReceive.rawValue,
                accessibility: .none,
                renderingMode: .normal,
                bundle: .transactionUIKit
            )
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedReceive.Text.request),
            barStyle: .lightContent()
        )
        let accountProvider = AccountPickerDefaultAccountProvider(
            singleAccountsOnly: true,
            action: .receive,
            failSequence: false
        )
        let builder = AccountPickerBuilder(
            accountProvider: accountProvider,
            action: .receive
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.receiveSelectionService.record(selection: account)
        }
        receiveAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header)
        )
        receiveAccountPickerRouter.interactable.activate()
        receiveAccountPickerRouter.load()
        return receiveAccountPickerRouter.viewControllable.uiviewController
    }

    var sendAccountPickerRouter: AccountPickerRouting!
    public func send() -> UIViewController {
        let header = AccountPickerHeaderModel(
            title: LocalizedSend.Header.sendCryptoNow,
            subtitle: LocalizedSend.Header.chooseAWalletToSendFrom,
            imageContent: .init(
                imageName: ImageAsset.iconSend.rawValue,
                accessibility: .none,
                renderingMode: .normal,
                bundle: .transactionUIKit
            )
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedSend.Text.send),
            barStyle: .lightContent()
        )
        let builder = AccountPickerBuilder(
            accountProvider: SendAccountPickerAccountProvider(),
            action: .send
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.sendSelectionService.record(selection: account)
        }
        sendAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header)
        )
        sendAccountPickerRouter.interactable.activate()
        sendAccountPickerRouter.load()
        return sendAccountPickerRouter.viewControllable.uiviewController
    }

}
