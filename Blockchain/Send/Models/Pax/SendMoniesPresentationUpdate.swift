//
//  SendMoniesPresentationUpdate.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum SendMoniesPresentationUpdate: Hashable {
    case cryptoValueTextField(CryptoValue?)
    case fiatValueTextField(FiatValue?)
    case toAddressTextField(String?)
    case feeValueLabel(CryptoValue?)
    case sendButtonEnabled(Bool)
    case updateNavigationItems
    case textFieldEditingEnabled(Bool)
    case showAlertSheetForError(SendMoniesInternalError)
    case showAlertSheetForSuccess
    case hideConfirmationModal
    case loadingIndicatorVisibility(Visibility)
}
