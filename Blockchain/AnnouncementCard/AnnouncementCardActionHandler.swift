//
//  AnnouncementCardActionHandler.swift
//  Blockchain
//
//  Created by kevinwu on 3/4/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit

// Class used to keep objects in memory while performing async operations for
// the CardsViewController instance.
@objc class AnnouncementCardActionHandler: NSObject {
    private let stellarAirdropRouter = StellarAirdropRouter()

    @objc func stellarAirdropCardActionTapped() {
        registerForAirdropThenKyc()
    }

    @objc func coinifyKycActionTapped() {
        registerForAirdropThenKyc()
    }

    private func registerForAirdropThenKyc() {
        stellarAirdropRouter.registerForCampaign(success: { user in
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
                return
            }
            KYCCoordinator.shared.start(from: rootViewController, tier: .tier2)
        }, error: { error in
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
        })
    }

    @objc func stellarModalPromptForAirdropRegistrationActionTapped() {
        stellarAirdropRouter.registerForCampaign(success: { user in
            let okAction = AlertAction(style: .confirm(LocalizationConstants.okString))
            let alertModel = AlertModel(
                headline: LocalizationConstants.AnnouncementCards.registerAirdropSuccessTitle,
                body: LocalizationConstants.AnnouncementCards.registerAirdropSuccessDescription,
                actions: [okAction]
            )
            let alert = AlertView.make(with: alertModel, completion: nil)
            alert.show()
        }, error: { error in
            AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
        })
    }
}
