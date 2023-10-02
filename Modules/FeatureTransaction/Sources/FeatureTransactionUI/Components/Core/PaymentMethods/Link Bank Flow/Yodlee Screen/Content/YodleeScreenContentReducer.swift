// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureOpenBankingUI
import Localization
import PlatformKit

final class YodleeScreenContentReducer {

    private enum Image {
        static var filledBlockchainLogo: ImageLocation {
            .local(name: "filled_blockchain_logo", bundle: .platformUIKit)
        }

        static var largeBankIcon: ImageLocation {
            .local(name: "large-bank-icon", bundle: .platformUIKit)
        }

        static var filledYodleeLogo: ImageLocation {
            .local(name: "filled_yodlee_logo", bundle: .platformUIKit)
        }
    }

    // MARK: Pending Content

    typealias LocalizedStrings = LocalizationConstants.SimpleBuy.YodleeWebScreen

    let continueButtonViewModel: ButtonViewModel = .primary(
        with: LocalizedStrings.WebViewSuccessContent.mainActionButtonTitle
    )

    let tryAgainButtonViewModel: ButtonViewModel = .primary(
        with: LocalizedStrings.FailurePendingContent.Generic.mainActionButtonTitle
    )

    let tryDifferentBankButtonViewModel: ButtonViewModel = .primary(
        with: LocalizedStrings.FailurePendingContent.AccountUnsupported.mainActionButtonTitle
    )

    let cancelButtonViewModel: ButtonViewModel = .secondary(
        with: LocalizedStrings.FailurePendingContent.Generic.cancelActionButtonTitle
    )

    let okButtonViewModel: ButtonViewModel = .secondary(
        with: LocalizedStrings.FailurePendingContent.AlreadyLinked.mainActionButtonTitle
    )

    private let subtitleTextStyle = InteractableTextViewModel.Style(color: .descriptionText, font: .main(.regular, 14))
    private let subtitleLinkTextStyle = InteractableTextViewModel.Style(color: .primary, font: .main(.regular, 14))

    private let supportUrl = "https://support.blockchain.com/hc/en-us/requests/new"

    // MARK: Pending Content

    func webviewSuccessContent(bankName: String?) -> YodleePendingContent {
        var subtitle = LocalizedStrings.WebViewSuccessContent.subtitleGeneric
        if let bankName {
            subtitle = String(format: LocalizedStrings.WebViewSuccessContent.subtitleWithBankName, bankName)
        }
        return YodleePendingContent(
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(Image.largeBankIcon),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.success.imageResource),
                        position: .rightCorner
                    )
                )
            ),
            mainTitleContent: .init(
                text: LocalizedStrings.WebViewSuccessContent.title,
                font: .main(.bold, 20),
                color: .darkTitleText,
                alignment: .center
            ),
            subtitleTextViewModel: .init(
                inputs: [.text(string: subtitle)],
                textStyle: subtitleTextStyle,
                linkStyle: subtitleLinkTextStyle
            ),
            buttonContent: continueButtonContent()
        )
    }

    func webviewPendingContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(Image.filledYodleeLogo),
                    sideViewAttributes: .init(type: .loader, position: .rightCorner)
                )
            ),
            mainTitleContent: .init(
                text: LocalizedStrings.WebViewPendingContent.title,
                font: .main(.bold, 20),
                color: .darkTitleText,
                alignment: .center
            ),
            subtitleTextViewModel: .init(
                inputs: [.text(string: LocalizedStrings.WebViewPendingContent.subtitle)],
                textStyle: subtitleTextStyle,
                linkStyle: subtitleLinkTextStyle
            ),
            buttonContent: nil
        )
    }

    func webviewFailureContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(Image.filledBlockchainLogo),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.circleError.imageResource),
                        position: .rightCorner
                    )
                )
            ),
            mainTitleContent: .init(
                text: LocalizedStrings.FailurePendingContent.Generic.title,
                font: .main(.bold, 20),
                color: .darkTitleText,
                alignment: .center
            ),
            subtitleTextViewModel: .init(
                inputs: [
                    .text(string: LocalizedStrings.FailurePendingContent.Generic.subtitle),
                    .url(string: LocalizedStrings.FailurePendingContent.contactSupport, url: supportUrl)
                ],
                textStyle: subtitleTextStyle,
                linkStyle: subtitleLinkTextStyle
            ),
            buttonContent: tryAgainAndCanceButtonContent()
        )
    }

    func linkingBankPendingContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(Image.filledBlockchainLogo),
                    sideViewAttributes: .init(type: .loader, position: .rightCorner)
                )
            ),
            mainTitleContent: .init(
                text: LocalizedStrings.LinkingPendingContent.title,
                font: .main(.bold, 20),
                color: .darkTitleText,
                alignment: .center
            ),
            subtitleTextViewModel: .empty,
            buttonContent: nil
        )
    }

    func linkingBankFailureContent(error: LinkedBankData.LinkageError) -> YodleePendingContent {
        let failureTitles = linkingBankFailureTitles(from: error)
        let buttonContent = linkingBankFailureButtonContent(from: error)
        return YodleePendingContent(
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(Image.filledBlockchainLogo),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.circleError.imageResource),
                        position: .rightCorner
                    )
                )
            ),
            mainTitleContent: .init(
                text: failureTitles.title,
                font: .main(.bold, 20),
                color: .darkTitleText,
                alignment: .center
            ),
            subtitleTextViewModel: failureTitles.subtitle,
            buttonContent: buttonContent
        )
    }

    // MARK: Button Content

    func tryAgainAndCanceButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: nil,
            tryAgainButtonViewModel: tryAgainButtonViewModel,
            cancelActionButtonViewModel: cancelButtonViewModel
        )
    }

    func tryDifferentBankAndCancelButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: nil,
            tryAgainButtonViewModel: tryDifferentBankButtonViewModel,
            cancelActionButtonViewModel: cancelButtonViewModel
        )
    }

    func continueButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: continueButtonViewModel,
            tryAgainButtonViewModel: nil,
            cancelActionButtonViewModel: nil
        )
    }

    func okButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: nil,
            tryAgainButtonViewModel: nil,
            cancelActionButtonViewModel: okButtonViewModel
        )
    }

    // MARK: Private

    private func linkingBankFailureButtonContent(
        from linkageError: LinkedBankData.LinkageError
    ) -> YodleeButtonsContent {
        switch linkageError {
        case .alreadyLinked:
            return okButtonContent()
        case .infoNotFound:
            return tryDifferentBankAndCancelButtonContent()
        case .nameMismatch:
            return tryDifferentBankAndCancelButtonContent()
        case .failed:
            return tryAgainAndCanceButtonContent()
        default:
            return tryAgainAndCanceButtonContent()
        }
    }

    private func linkingBankFailureTitles(
        from linkageError: LinkedBankData.LinkageError
    ) -> (title: String, subtitle: InteractableTextViewModel) {
        let ui = BankState.UI.errors[.code(linkageError.rawValue), default: BankState.UI.defaultError]
        return (
            ui.info.title,
            .init(
                inputs: [
                    .text(string: ui.info.subtitle)
                ],
                textStyle: subtitleTextStyle,
                linkStyle: subtitleLinkTextStyle,
                alignment: .center
            )
        )
    }
}
