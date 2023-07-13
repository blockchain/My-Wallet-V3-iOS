// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Localization
import ToolKit
import UIKit

public enum MailApps: String, CaseIterable {

    case mail = "Mail"
    case gmail = "Gmail"
    case inbox = "Inbox"
    case outlook = "Outlook"
    case dispatch = "Dispatch"
    case protonmail = "Proton Mail"

    var url: URL? {
        switch self {
        case .mail:
            return URL(string: "message:")
        case .gmail:
            return URL(string: "googlegmail://")
        case .inbox:
            return URL(string: "inbox-gmail://")
        case .outlook:
            return URL(string: "ms-outlook://")
        case .dispatch:
            return URL(string: "x-dispatch://")
        case .protonmail:
            return URL(string: "protonmail://")
        }
    }

    func action(_ completion: @escaping (Bool) -> Void) -> UIAlertAction? {
        guard let url, UIApplication.shared.canOpenURL(url) else {
             return nil
        }
        let action = UIAlertAction(title: rawValue, style: .default) { _ in
            UIApplication.shared.open(url, completionHandler: completion)
        }
        return action
    }
}

extension ExternalAppOpener {

    public func openMailApp() {
        openMailApp(completionHandler: { _ in })
    }

    public func openMailApp(completionHandler: @escaping (Bool) -> Void) {
        let emailActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        emailActionSheet.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil))

        let actions = MailApps
            .allCases
            .compactMap { $0.action(completionHandler) }

        guard actions.isNotEmpty else {
            completionHandler(false)
            return
        }

        guard actions.count > 1 else {
            if let title = actions.first?.title, let app = MailApps(rawValue: title), let url = app.url {
                open(url, completionHandler: completionHandler)
            } else {
                completionHandler(false)
            }
            return
        }

        actions.forEach(emailActionSheet.addAction)

        UIApplication.shared.firstKeyWindow?.topMostViewController?.present(emailActionSheet, animated: true)
    }

    public func openSettingsApp() {
        openSettingsApp(completionHandler: { _ in })
    }

    public func openSettingsApp(completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completionHandler(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }
}

extension UIApplication: ExternalAppOpener {

    public func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        guard canOpenURL(url) else {
            completionHandler(false)
            return
        }
        open(url, options: [.universalLinksOnly: false], completionHandler: completionHandler)
    }
}

extension UIApplication {

    /// Opens the mail application, if possible, otherwise, displays an error
    public func openMailApplication() {
        openMailApp { success in
            guard success else {
                let message = String(
                    format: LocalizationConstants.Errors.cannotOpenURLArg, MailApps.mail.rawValue
                )
                let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
                alertPresenter.standardError(message: message)
                return
            }
        }
    }
}
