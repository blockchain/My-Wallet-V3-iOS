// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import ToolKit
import UIComponentsKit
import UIKit

public final class ReceiveRootBuilder {
    private typealias LocalizedReceive = LocalizationConstants.Receive

    private let receiveSelectionService: AccountSelectionServiceAPI

    init(
        receiveSelectionService: AccountSelectionServiceAPI
    ) {
        self.receiveSelectionService = receiveSelectionService
    }

    var receiveAccountPickerRouter: AccountPickerRouting!

    public func receive() -> UIViewController {

        let header = AccountPickerHeaderModel(
            imageContent: .init(
                imageResource: ImageAsset.iconReceive.imageResource,
                accessibility: .none,
                renderingMode: .normal
            ),
            searchable: true,
            subtitle: nil,
            title: LocalizedReceive.Header.receiveCryptoNow
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .qrCode,
            titleViewStyle: .text(value: LocalizedReceive.Text.request),
            barStyle: .lightContent()
        )
        let builder = AccountPickerBuilder(
            accountProvider: ReceiveAccountProvider(),
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
}
