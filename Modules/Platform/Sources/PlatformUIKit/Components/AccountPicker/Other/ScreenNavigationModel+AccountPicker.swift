// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension ScreenNavigationModel {
    public enum AccountPicker {}
}

extension ScreenNavigationModel.AccountPicker {

    public static func modal(title: String = LocalizationConstants.WalletPicker.title) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: .none,
            trailingButton: .close,
            titleViewStyle: .text(value: title),
            barStyle: .darkContent(background: .semantic.light)
        )
    }

    public static let navigation = ScreenNavigationModel(
        leadingButton: .back,
        trailingButton: .none,
        titleViewStyle: .text(value: LocalizationConstants.WalletPicker.title),
        barStyle: .darkContent(background: .semantic.light)
    )

    public static func navigationClose(title: String = LocalizationConstants.WalletPicker.title) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: .back,
            trailingButton: .close,
            titleViewStyle: .text(value: title),
            barStyle: .darkContent(background: .semantic.light)
        )
    }
}
