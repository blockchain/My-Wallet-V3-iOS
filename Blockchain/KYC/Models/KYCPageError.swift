//
//  KYCPageError.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCPageError {
    case countryNotSupported(KYCCountry)
    case stateNotSupported(KYCState)
}
