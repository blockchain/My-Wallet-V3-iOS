//
//  AnnouncementCardViewModel.swift
//  Blockchain
//
//  Created by Maurice A. on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AnnouncementCardViewModel: NSObject {
    typealias Action = () -> Void

    let title: String
    let message: String
    let actionButtonTitle: String?
    let imageTint: UIColor?
    let image: UIImage
    let action, onClose: Action

    @objc init(
        title: String,
        message: String,
        actionButtonTitle: String?,
        image: UIImage,
        imageTint: UIColor?,
        action: @escaping Action,
        onClose: @escaping Action
    ) {
        self.title = title
        self.message = message
        self.actionButtonTitle = actionButtonTitle
        self.image = image
        self.imageTint = imageTint
        self.action = action
        self.onClose = onClose
    }
}

extension AnnouncementCardViewModel {
    @objc class func joinAirdropWaitlist(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.Stellar.weNowSupportStellar,
            message: LocalizationConstants.Stellar.weNowSupportStellarDescription,
            actionButtonTitle: LocalizationConstants.Stellar.claimYourFreeXLMNow,
            image: #imageLiteral(resourceName: "symbol-xlm"),
            imageTint: #colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1),
            action: action,
            onClose: onClose
        )
    }

    @objc class func airdropOnItsWay(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.Stellar.yourXLMIsOnItsWay,
            message: LocalizationConstants.Stellar.yourXLMIsOnItsWayDescription,
            actionButtonTitle: nil,
            image: #imageLiteral(resourceName: "symbol-xlm"),
            imageTint: #colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1),
            action: action,
            onClose: onClose
        )
    }

    @objc class func continueWithKYC(
        isAirdropUser: Bool,
        action: @escaping Action,
        onClose: @escaping Action
    ) -> AnnouncementCardViewModel {
        if isAirdropUser {
            return AnnouncementCardViewModel(
                title: LocalizationConstants.Stellar.claimYourStellarXLM,
                message: LocalizationConstants.Stellar.claimYourStellarDescription,
                actionButtonTitle: LocalizationConstants.AnnouncementCards.continueKYCActionButtonTitle,
                image: #imageLiteral(resourceName: "symbol-xlm"),
                imageTint: #colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1),
                action: action,
                onClose: onClose
            )
        } else {
            return AnnouncementCardViewModel(
                title: LocalizationConstants.AnnouncementCards.continueKYCCardTitle,
                message: LocalizationConstants.AnnouncementCards.continueKYCCardDescription,
                actionButtonTitle: LocalizationConstants.AnnouncementCards.continueKYCActionButtonTitle,
                image: #imageLiteral(resourceName: "identity_verification_card"),
                imageTint: nil,
                action: action,
                onClose: onClose
            )
        }
    }
}
