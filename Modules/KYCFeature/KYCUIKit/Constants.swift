// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

struct Constants {
    struct NotificationKeys {
        static let kycStopped = NSNotification.Name("kycStopped")
    }
    struct Measurements {
        static let ScreenHeightIphone5S: CGFloat = 568.0
    }
    struct Booleans {
        static let IsUsingScreenSizeLargerThan5s = UIScreen.main.bounds.size.height > Measurements.ScreenHeightIphone5S
    }
    struct FontSizes {
        static let ExtraExtraExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 13.0 : 11.0
        static let Small: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 16.0 : 13.0
        static let SmallMedium: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 17.0 : 14.0
    }

    struct FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratSemiBold = "Montserrat-SemiBold"
        static let montserratMedium = "Montserrat-Medium"
    }

    struct Url {
        static let blockchainSupportRequest = blockchainSupport + "/hc/en-us/requests/new?"
        static let blockchainSupport = "https://support.blockchain.com"
        static let airdropProgram = "https://support.blockchain.com/hc/en-us/categories/360001126692-Airdrop-Program"
        static let blockchainHome = "https://www.blockchain.com"
        static let privacyPolicy = blockchainHome + "/privacy"
        static let termsOfService = blockchainHome + "/terms"
        static let blockchainWalletLogin = "https://login.blockchain.com"
        static let verificationRejectedURL = "https://support.blockchain.com/hc/en-us/articles/360018080352-Why-has-my-ID-submission-been-rejected-"
    }
}
