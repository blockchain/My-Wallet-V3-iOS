//
//  AppReviewPrompt.swift
//  Blockchain
//
//  Created by Maurice A. on 6/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import StoreKit

/**
 App Review Prompt
 Used to prompt the user to review the application.
 */
@objc
final class AppReviewPrompt: NSObject {

    // MARK: - Properties

    private let numberOfTransactionsBeforePrompt = 3

    static let shared = AppReviewPrompt()

    @objc class func sharedInstance() -> AppReviewPrompt {
        return AppReviewPrompt.shared
    }

    override private init() {
        super.init()
    }

    /// Ask to show the prompt, else handle failure silently
    @objc func askToShow() {
        if WalletManager.shared.wallet.getAllTransactionsCount() < numberOfTransactionsBeforePrompt {
            #if DEBUG
            print("App review prompt will not show because the user needs at least \(numberOfTransactionsBeforePrompt) transactions.")
            #endif
            return
        }

        // TODO: support overriding appOpenedCount for debugging
        let count = BlockchainSettings.App.shared.appOpenedCount
        switch count {
        case 10, 50: requestReview()
        case _ where (count >= 100) && (count % 100 == 0): requestReview()
        default:
            #if DEBUG
            print("App review prompt will not show because the application open count is too low (\(count)).")
            #endif
            return
        }
    }

    private func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            let settings = BlockchainSettings.App.shared
            if settings.dontAskUserToShowAppReviewPrompt {
                #if DEBUG
                print("App review prompt will not show because the user does not want to be asked.")
                #endif
                return
            }
            let affirmativeAction = UIAlertAction(
                title: LocalizationConstants.AppReviewFallbackPrompt.affirmativeActionTitle,
                style: .default,
                handler: { _ in
                    settings.dontAskUserToShowAppReviewPrompt = true
                    UIApplication.shared.rateApp()
            })
            let secondaryAction = UIAlertAction(
                title: LocalizationConstants.AppReviewFallbackPrompt.secondaryActionTitle,
                style: .cancel,
                handler: nil)
            let tertiaryAction = UIAlertAction(title: LocalizationConstants.dontShowAgain, style: .cancel, handler: { _ in
                settings.dontAskUserToShowAppReviewPrompt = true
            })
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.AppReviewFallbackPrompt.message,
                title: LocalizationConstants.AppReviewFallbackPrompt.title,
                actions: [affirmativeAction, secondaryAction, tertiaryAction]
            )
        }
    }
}
