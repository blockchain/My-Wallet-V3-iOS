// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum TextRegex: String {
    case cardholderName = "^.{2,26}$" // 2-26 characters as defined in `ISO/IEC 7813`: https://en.wikipedia.org/wiki/ISO/IEC_7813#Track_1
    case cvv = "^[0-9]{3,4}$"
    case cardExpirationDate = "^((0[1-9])|(1[0-2]))/[2-9][0-9]$"
    case walletIdentifier = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    case email = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    case notEmpty = "^.+$"
    case noSpecialCharacters = "^[a-zA-Z0-9]*$"
    case memo = "^.{0,28}$"
}
