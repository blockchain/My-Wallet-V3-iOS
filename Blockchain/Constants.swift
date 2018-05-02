//
//  Constants.swift
//  Blockchain
//
//  Created by Mark Pfluger on 6/26/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

struct Constants {
    struct Animation {
        static let duration = 0.2
        static let durationLong = 0.5
    }
    struct Colors {
        static let TextFieldBorderGray = UIColorFromRGB(0xcdcdcd)
        static let BlockchainBlue = UIColorFromRGB(0x004a7c)
        static let BlockchainLightBlue = UIColorFromRGB(0x10ade4)
        static let BlockchainLightestBlue = UIColorFromRGB(0xb2d5e5)
        static let SecondaryGray = UIColorFromRGB(0xebebeb)
        static let SuccessGreen = UIColorFromRGB(0x199D69)
        static let WarningRed = UIColorFromRGB(0xB83940)
        static let SentRed = UIColorFromRGB(0xF26C57)
        static let DisabledGray = UIColorFromRGB(0xEBEBEB)
        static let DarkGray = UIColorFromRGB(0x4c4c4c)
    }
    struct Measurements {
        static let DefaultHeaderHeight: CGFloat = 65
        static let BackupButtonCornerRadius: CGFloat = 4
        static let BusyViewLabelWidth: CGFloat = 230
        static let BusyViewLabelHeight: CGFloat = 30
        static let BusyViewLabelAlpha: CGFloat = 0.75
        static let BusyViewLabelFontSystemSize: CGFloat = 14.0

        static let ScreenHeightIphone4S: CGFloat = 480
        static let ScreenHeightIphone5S: CGFloat = 568
    }
    struct FontSizes {
        static let Small: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 16.0 : 13.0
        static let SmallMedium: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 17.0 : 14.0
        static let Medium: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 18.0 : 15.0
        static let MediumLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 19.0 : 16.0
        static let Large: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 20.0 : 17.0
        static let ExtraLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 21.0 : 18.0
        static let ExtraExtraLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 23.0 : 20.0
    }
    struct FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratSemiBold = "Montserrat-SemiBold"
        static let montserratSemiLight = "Montserrat-Light"
        static let montserratSemiExtraLight = "Montserrat-ExtraLight"
        static let gillSans = "GillSans"
        static let gillSansLight = "GillSans-Light"
        static let helveticaNueue = "Helvetica Neue"
        static let helveticaNueueMedium = "HelveticaNeue-Medium"
    }
    struct Defaults {
        static let NumberOfRecoveryPhraseWords = 12
    }
    struct Booleans {
        static let IsUsingScreenSizeLargerThan5s = UIScreen.main.bounds.size.height > Measurements.ScreenHeightIphone5S
    }
    struct NotificationKeys {
        static let modalViewDismissed = NSNotification.Name("modalViewDismissed")
        static let reloadToDismissViews = NSNotification.Name("reloadToDismissViews")
        static let newAddress = NSNotification.Name("newAddress")
    }
    struct PushNotificationKeys {
        static let userInfoType = "type"
        static let userInfoId = "id"
        static let typePayment = "payment"
    }
    struct Schemas {
        static let mail = "message://"
    }
    struct Time {
        static let securityReminderModalTimeInterval: TimeInterval = 60 * 60 * 24 * 30 // Seconds in thirty days
    }
    struct Locales {
        struct English {
            static let us = "en_US"
        }
    }
}

/// Constant class wrapper so that Constants can be accessed from Obj-C. Should deprecate this
/// once Obj-C is no longer using this
@objc class ConstantsObjcBridge: NSObject {
    @objc class func animationDuration() -> Double { return Constants.Animation.duration }

    @objc class func animationDurationLong() -> Double { return Constants.Animation.durationLong }

    @objc class func notificationKeyModalViewDismissed() -> String {
        return Constants.NotificationKeys.modalViewDismissed.rawValue
    }

    @objc class func notificationKeyReloadToDismissViews() -> String {
        return Constants.NotificationKeys.reloadToDismissViews.rawValue
    }

    @objc class func notificationKeyNewAddress() -> String {
        return Constants.NotificationKeys.newAddress.rawValue
    }
}

// MARK: Helper functions

func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
