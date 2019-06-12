//
//  AnnouncementCardViewModel.swift
//  Blockchain
//
//  Created by Maurice A. on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import Foundation

@objc class AnnouncementCardPallete: NSObject {
    let isNew: Bool
    let backgroundImage: UIImage?
    let contentMode: UIView.ContentMode
    let titleTextColor: UIColor
    let messageTextColor: UIColor
    let actionTextColor: UIColor
    let backgroundColor: UIColor
    
    @objc init(
        isNew: Bool = false,
        backgroundImage: UIImage? = nil,
        backgroundContentMode: UIView.ContentMode = .scaleAspectFill,
        titleTextColor: UIColor = #colorLiteral(red: 0.004, green: 0.29, blue: 0.486, alpha: 1),
        messageTextColor: UIColor = #colorLiteral(red: 0.373, green: 0.373, blue: 0.373, alpha: 1),
        actionTextColor: UIColor = #colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1),
        backgroundColor: UIColor = .white
        ) {
        self.isNew = isNew
        self.contentMode = backgroundContentMode
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.titleTextColor = titleTextColor
        self.messageTextColor = messageTextColor
        self.actionTextColor = actionTextColor
    }
    
    static let standard: AnnouncementCardPallete = AnnouncementCardPallete()
}

@objc class AnnouncementCardViewModel: NSObject {
    typealias Action = () -> Void

    let title: String
    let message: String
    let palette: AnnouncementCardPallete
    let actionButtonTitle: String?
    let imageTint: UIColor?
    let image: UIImage?
    let action, onClose: Action

    @objc init(
        title: String,
        message: String,
        actionButtonTitle: String?,
        palette: AnnouncementCardPallete = .standard,
        image: UIImage? = nil,
        imageTint: UIColor? = nil,
        action: @escaping Action,
        onClose: @escaping Action
    ) {
        self.title = title
        self.message = message
        self.palette = palette
        self.actionButtonTitle = actionButtonTitle
        self.image = image
        self.imageTint = imageTint
        self.action = action
        self.onClose = onClose
    }
}

extension AnnouncementCardViewModel {
    static func paxIntro(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        let palette = AnnouncementCardPallete(
            isNew: true,
            backgroundImage: #imageLiteral(resourceName: "announcement_pax_background"),
            titleTextColor: .black,
            messageTextColor: UIColor.gray5,
            actionTextColor: UIColor.brandPrimary
        )
        return AnnouncementCardViewModel(
            title: LocalizationConstants.AnnouncementCards.paxIntroTitle,
            message: LocalizationConstants.AnnouncementCards.paxIntroDescription,
            actionButtonTitle: LocalizationConstants.AnnouncementCards.paxIntroCTA,
            palette: palette,
            action: action,
            onClose: onClose
        )
    }

    @objc class func joinAirdropWaitlist(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.Stellar.weNowSupportStellar,
            message: LocalizationConstants.Stellar.weNowSupportStellarDescription,
            actionButtonTitle: LocalizationConstants.Stellar.getStellarNow,
            image: #imageLiteral(resourceName: "symbol-xlm"),
            imageTint: AssetType.stellar.brandColor,
            action: action,
            onClose: onClose
        )
    }
    
    @objc class func swapCTA(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        let palette = AnnouncementCardPallete(
            isNew: true,
            backgroundImage: #imageLiteral(resourceName: "swap_promo_bg"),
            backgroundContentMode: .topRight,
            titleTextColor: .white,
            messageTextColor: .white,
            actionTextColor: .white,
            backgroundColor: #colorLiteral(red: 0.07, green: 0.08, blue: 0.23, alpha: 1)
        )
        let model = AnnouncementCardViewModel(
            title: LocalizationConstants.Swap.swap,
            message: LocalizationConstants.Swap.swapCardMessage,
            actionButtonTitle: LocalizationConstants.Swap.checkItOut + " " + "👉",
            palette: palette,
            action: action,
            onClose: onClose
        )
        return model
    }

    @objc class func airdropOnItsWay(action: @escaping Action, onClose: @escaping Action) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.Stellar.yourXLMIsOnItsWay,
            message: LocalizationConstants.Stellar.yourXLMIsOnItsWayDescription,
            actionButtonTitle: nil,
            image: #imageLiteral(resourceName: "symbol-xlm-large"),
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
                title: LocalizationConstants.Stellar.kycAirdropTitle,
                message: LocalizationConstants.Stellar.kycAirdropDescription,
                actionButtonTitle: LocalizationConstants.AnnouncementCards.continueKYCActionButtonTitle,
                image: #imageLiteral(resourceName: "Icon-Verified"),
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

    @objc class func resubmitDocuments(
        action: @escaping Action,
        onClose: @escaping Action
    ) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.AnnouncementCards.uploadDocumentsCardTitle,
            message: LocalizationConstants.AnnouncementCards.uploadDocumentsCardDescription,
            actionButtonTitle: LocalizationConstants.AnnouncementCards.uploadDocumentsActionButtonTitle,
            image: #imageLiteral(resourceName: "identity_verification_card"),
            imageTint: nil,
            action: action,
            onClose: onClose
        )
    }

    @objc class func completeYourProfile(
        action: @escaping Action,
        onClose: @escaping Action
    ) -> AnnouncementCardViewModel {
        return AnnouncementCardViewModel(
            title: LocalizationConstants.AnnouncementCards.cardCompleteProfileTitle,
            message: LocalizationConstants.AnnouncementCards.cardCompleteProfileDescription,
            actionButtonTitle: LocalizationConstants.AnnouncementCards.cardCompleteProfileAction,
            image: #imageLiteral(resourceName: "symbol-xlm"),
            imageTint: nil,
            action: action,
            onClose: onClose
        )
    }
}
