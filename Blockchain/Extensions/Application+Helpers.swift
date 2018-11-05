//
//  UIApplication.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices

extension UIApplication {

    // Prefer using SFSafariViewController over UIWebview due to privacy and security improvements.
    // https://medium.com/ios-os-x-development/security-flaw-with-uiwebview-95bbd8508e3c
    func openSafariViewController(url: String, presentingViewController: UIViewController) {
        guard let urlTarget = URL(string: url) else {
            return
        }
        let viewController = SFSafariViewController(url: urlTarget)
        viewController.modalPresentationStyle = .overFullScreen
        presentingViewController.present(viewController, animated: true, completion: nil)
    }

    @objc func openWebView(url: String, title: String, presentingViewController: UIViewController) {
        let webViewController = SettingsWebViewController()
        webViewController.urlTargetString = url
        let navigationController = BCNavigationController(rootViewController: webViewController, title: title)
        presentingViewController.present(navigationController, animated: true)
    }

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
        open(mailURL)
    }

    // MARK: - Rate Application

    @objc func rateApp() {
        let url = URL(string: "\(Constants.Url.appStoreLinkPrefix)\(Constants.AppStore.AppID)")!
        self.open(url)
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
