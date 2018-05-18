//
//  UIApplication.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UIApplication {

    // Opens the mail application, if possible, otherwise, displays an error
    @objc func openMailApplication() {
        guard let mailURL = URL(string: "\(Constants.Schemes.mail)://"), canOpenURL(mailURL) else {
            AlertViewPresenter.shared.standardError(
                message: NSString(
                    format: LocalizationConstants.Errors.cannotOpenURLArg as NSString,
                    Constants.Schemes.mail
                ) as String
            )
            return
        }
        openURL(mailURL)
    }
}
