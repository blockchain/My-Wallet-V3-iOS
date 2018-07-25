//
//  HTTPCookieStorage.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension HTTPCookieStorage {
    func deleteAllCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        guard let cookies = cookieStorage.cookies else {
            Logger.shared.info("No cookies to delete")
            return
        }
        cookies.forEach { cookieStorage.deleteCookie($0) }
    }
}
