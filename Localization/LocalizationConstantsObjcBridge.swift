//
//  LocalizationConstantsObjcBridge.swift
//  Localization
//
//  Created by Paulo on 08/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc public class LocalizationConstantsObjcBridge: NSObject {

    @objc public class func etherSecondPasswordPrompt() -> String { LocalizationConstants.Authentication.EtherPasswordScreen.description }

    @objc public class func privateKeyNeeded() -> String { LocalizationConstants.Authentication.ImportKeyPasswordScreen.title }

    @objc public class func paxFee() -> String { LocalizationConstants.Transactions.paxfee }

    @objc public class func copiedToClipboard() -> String { LocalizationConstants.Receive.Text.copiedToClipboard }

    @objc public class func createWalletLegalAgreementPrefix() -> String {
        LocalizationConstants.Onboarding.termsOfServiceAndPrivacyPolicyNoticePrefix
    }

    @objc public class func termsOfService() -> String { LocalizationConstants.tos }

    @objc public class func privacyPolicy() -> String { LocalizationConstants.privacyPolicy     }

    @objc public class func twoFactorExchangeDisabled() -> String { LocalizationConstants.Exchange.twoFactorNotEnabled }

    @objc public class func sendAssetExchangeDestination() -> String { LocalizationConstants.Exchange.Send.destination }

    @objc public class func continueString() -> String { LocalizationConstants.continueString }

    @objc public class func warning() -> String { LocalizationConstants.Errors.warning }

    @objc public class func requestFailedCheckConnection() -> String { LocalizationConstants.Errors.requestFailedCheckConnection }

    @objc public class func information() -> String { LocalizationConstants.information }

    @objc public class func error() -> String { LocalizationConstants.Errors.error }

    @objc public class func noInternetConnection() -> String { LocalizationConstants.Errors.noInternetConnection }

    @objc public class func onboardingRecoverFunds() -> String { LocalizationConstants.Onboarding.recoverFunds }

    @objc public class func tryAgain() -> String { LocalizationConstants.tryAgain }

    @objc public class func passwordRequired() -> String { LocalizationConstants.Authentication.passwordRequired }

    @objc public class func loadingWallet() -> String { LocalizationConstants.Authentication.loadingWallet }

    @objc public class func timedOut() -> String { LocalizationConstants.Errors.timedOut }

    @objc public class func incorrectPin() -> String { LocalizationConstants.Pin.incorrect }

    @objc public class func logout() -> String { LocalizationConstants.SideMenu.logout }

    @objc public class func debug() -> String { LocalizationConstants.SideMenu.debug }

    @objc public class func noPasswordEntered() -> String { LocalizationConstants.Authentication.noPasswordEntered }

    @objc public class func success() -> String { LocalizationConstants.success }

    @objc public class func syncingWallet() -> String { LocalizationConstants.syncingWallet }

    @objc public class func loadingImportKey() -> String { LocalizationConstants.AddressAndKeyImport.loadingImportKey }

    @objc public class func loadingProcessingKey() -> String { LocalizationConstants.AddressAndKeyImport.loadingProcessingKey }

    @objc public class func incorrectBip38Password() -> String { LocalizationConstants.AddressAndKeyImport.incorrectBip38Password }

    @objc public class func scanQRCode() -> String { LocalizationConstants.scanQRCode }

    @objc public class func nameAlreadyInUse() -> String { LocalizationConstants.Errors.nameAlreadyInUse }

    @objc public class func unknownKeyFormat() -> String { LocalizationConstants.AddressAndKeyImport.unknownKeyFormat }

    @objc public class func unsupportedPrivateKey() -> String { LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey }

    @objc public class func cookiePolicy() -> String { LocalizationConstants.Settings.cookiePolicy }

    @objc public class func gettingQuote() -> String { LocalizationConstants.Swap.gettingQuote }

    @objc public class func confirming() -> String { LocalizationConstants.Swap.confirming }

    @objc public class func loadingTransactions() -> String { LocalizationConstants.Swap.loadingTransactions }

    @objc public class func invalidXAddressY() -> String { LocalizationConstants.SendAsset.invalidXAddressY }

    @objc public class func nonSpendable() -> String { LocalizationConstants.AddressAndKeyImport.nonSpendable }

    @objc public class func dontShowAgain() -> String { LocalizationConstants.dontShowAgain }

    @objc public class func loadingExchange() -> String { LocalizationConstants.Swap.loading }

    @objc public class func notEnoughXForFees() -> String { LocalizationConstants.Errors.notEnoughXForFees }

    @objc public class func balances() -> String { LocalizationConstants.balances }

    @objc public class func dashboardBitcoinPrice() -> String { LocalizationConstants.Dashboard.bitcoinPrice }

    @objc public class func dashboardEtherPrice() -> String { LocalizationConstants.Dashboard.etherPrice }

    @objc public class func dashboardBitcoinCashPrice() -> String { LocalizationConstants.Dashboard.bitcoinCashPrice }

    @objc public class func dashboardStellarPrice() -> String { LocalizationConstants.Dashboard.stellarPrice }

    @objc public class func justNow() -> String { LocalizationConstants.Transactions.justNow }

    @objc public class func secondsAgo() -> String { LocalizationConstants.Transactions.secondsAgo }

    @objc public class func oneMinuteAgo() -> String { LocalizationConstants.Transactions.oneMinuteAgo }

    @objc public class func minutesAgo() -> String { LocalizationConstants.Transactions.minutesAgo }

    @objc public class func oneHourAgo() -> String { LocalizationConstants.Transactions.oneHourAgo }

    @objc public class func hoursAgo() -> String { LocalizationConstants.Transactions.hoursAgo }

    @objc public class func yesterday() -> String { LocalizationConstants.Transactions.yesterday }

    @objc public class func balancesErrorGeneric() -> String { LocalizationConstants.Errors.balancesGeneric }

    @objc public class func myBitcoinWallet() -> String { LocalizationConstants.Account.myWallet }

    @objc public class func myEtherWallet() -> String { LocalizationConstants.Account.myWallet }
}
