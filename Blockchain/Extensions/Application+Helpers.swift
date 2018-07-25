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

    // MARK: - Rate Application

    @objc func rateApp() {
        let url = URL(string: "\(Constants.Url.appStoreLinkPrefix)\(Constants.AppStore.AppID)")!
        self.openURL(url)
    }
}

// MARK: - Swifty Storyboards 📜 using Generics ✨🧙‍♂️✨

extension UIStoryboard {
    static func instantiate<Child: UIViewController, Parent: UIViewController>(
        child _ : Child.Type,
        from _ : Parent.Type,
        in storyboard: UIStoryboard,
        identifier: String) -> Child {
        guard
            let parent = storyboard.instantiateViewController(withIdentifier: identifier) as? Parent,
            object_setClass(parent, Child.self) != nil,
            let viewController = parent as? Child else {
                fatalError("Could not instantiate view controller of type \(Parent.description()) using identifier \(identifier).")
        }
        return viewController
    }
}
