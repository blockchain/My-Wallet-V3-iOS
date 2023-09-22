// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import UIComponentsKit

extension ImageLocation {

    var media: UIComponentsKit.Media {
        switch self {
        case .local(name: let name, bundle: let bundle):
            return .image(named: name, in: bundle)
        case .systemName(let name):
            return .image(systemName: name)
        case .remote(url: let url):
            return .image(at: url, placeholder: nil)
        }
    }
}

extension BankState.UI {

    static func error(
        _ error: OpenBanking.Error,
        currency: String? = nil,
        in environment: OpenBankingEnvironment
    ) -> Self {
        switch error {
        case .timeout:
            return .errorMessage(Localization.Bank.Error.timeout)
        case .message(let message):
            return .errorMessage(message)
        default:
            var ui = errors[error, default: defaultError]
            if ui.info.media == .inherited {
                if let currency {
                    ui.info.media = environment.cryptoCurrencyFormatter.displayImage(currency: currency).map(\.media)
                        ?? environment.fiatCurrencyFormatter.displayImage(currency: currency).map(\.media)
                        ?? .bankIcon
                } else {
                    ui.info.media = .bankIcon
                }
            }
            return ui
        }
    }

    public static var errors: [OpenBanking.Error: Self] = [
        .bankTransferAccountNameMismatch: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountNameMismatch.title,
                subtitle: Localization.Bank.Error.bankTransferAccountNameMismatch.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountNameMismatch.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountExpired: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountExpired.title,
                subtitle: Localization.Bank.Error.bankTransferAccountExpired.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountExpired.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountFailed: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountFailed.title,
                subtitle: Localization.Bank.Error.bankTransferAccountFailed.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountRejected: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountRejected.title,
                subtitle: Localization.Bank.Error.bankTransferAccountRejected.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountRejected.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountInvalid: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountInvalid.title,
                subtitle: Localization.Bank.Error.bankTransferAccountInvalid.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountInvalid.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountAlreadyLinked: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountAlreadyLinked.title,
                subtitle: Localization.Bank.Error.bankTransferAccountAlreadyLinked.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountAlreadyLinked.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountNotSupported: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountNotSupported.title,
                subtitle: Localization.Bank.Error.bankTransferAccountNotSupported.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountNotSupported.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountFailedInternal: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountFailedInternal.title,
                subtitle: Localization.Bank.Error.bankTransferAccountFailedInternal.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountFailedInternal.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountRejectedFraud: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountRejectedFraud.title,
                subtitle: Localization.Bank.Error.bankTransferAccountRejectedFraud.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountRejectedFraud.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountInfoNotFound: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountRejectedFraud.title,
                subtitle: Localization.Bank.Error.bankTransferAccountRejectedFraud.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountRejectedFraud.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentInvalid: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferPaymentInvalid.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentInvalid.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentInvalid.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentFailed: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferPaymentFailed.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentFailed.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentFailed.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentDeclined: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.bankTransferPaymentDeclined.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentDeclined.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentDeclined.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentRejected: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.bankTransferPaymentRejected.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentRejected.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentRejected.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentExpired: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .clock),
                title: Localization.Bank.Error.bankTransferPaymentExpired.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentExpired.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentExpired.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentLimitExceeded: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferPaymentLimitExceeded.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentLimitExceeded.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentLimitExceeded.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentUserAccountInvalid: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.bankTransferPaymentUserAccountInvalid.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentUserAccountInvalid.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentUserAccountInvalid.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentFailedInternal: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferPaymentFailedInternal.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentFailedInternal.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentFailedInternal.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferPaymentInsufficientFunds: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.bankTransferPaymentInsufficientFunds.title,
                subtitle: Localization.Bank.Error.bankTransferPaymentInsufficientFunds.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferPaymentInsufficientFunds.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateAbandoned: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateAbandoned.title,
                subtitle: Localization.Bank.Error.cardCreateAbandoned.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateAbandoned.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateBankDeclined: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateBankDeclined.title,
                subtitle: Localization.Bank.Error.cardCreateBankDeclined.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateBankDeclined.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateDebitOnly: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateDebitOnly.title,
                subtitle: Localization.Bank.Error.cardCreateDebitOnly.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateDebitOnly.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateDuplicate: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateDuplicate.title,
                subtitle: Localization.Bank.Error.cardCreateDuplicate.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateDuplicate.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateExpired: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateExpired.title,
                subtitle: Localization.Bank.Error.cardCreateExpired.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateExpired.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateFailed: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateFailed.title,
                subtitle: Localization.Bank.Error.cardCreateFailed.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateFailed.action, action: .request),
                .cancel
            ]
        ),
        .cardCreateNoToken: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardCreateNoToken.title,
                subtitle: Localization.Bank.Error.cardCreateNoToken.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardCreateDuplicate.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentAbandoned: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardPaymentAbandoned.title,
                subtitle: Localization.Bank.Error.cardPaymentAbandoned.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentAbandoned.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentBankDeclined: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardPaymentBankDeclined.title,
                subtitle: Localization.Bank.Error.cardPaymentBankDeclined.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentBankDeclined.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentDebitOnly: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardPaymentDebitOnly.title,
                subtitle: Localization.Bank.Error.cardPaymentDebitOnly.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentDebitOnly.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentExpired: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.cardPaymentExpired.title,
                subtitle: Localization.Bank.Error.cardPaymentExpired.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentExpired.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentFailed: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.cardPaymentFailed.title,
                subtitle: Localization.Bank.Error.cardPaymentFailed.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentFailed.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentInsufficientFunds: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.cardPaymentInsufficientFunds.title,
                subtitle: Localization.Bank.Error.cardPaymentInsufficientFunds.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentInsufficientFunds.action, action: .request),
                .cancel
            ]
        ),
        .cardPaymentNotSupported: .init(
            info: .init(
                media: .inherited,
                overlay: .init(media: .cross),
                title: Localization.Bank.Error.cardPaymentNotSupported.title,
                subtitle: Localization.Bank.Error.cardPaymentNotSupported.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.cardPaymentNotSupported.action, action: .request),
                .cancel
            ]
        )
    ]

    public static var defaultError: Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.default.title,
                subtitle: Localization.Bank.Error.default.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.default.action, action: .request),
                .cancel
            ]
        )
    }

    static func errorMessage(_ message: String) -> Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.default.title,
                subtitle: message
            ),
            action: [
                .retry(label: Localization.Bank.Error.default.action, action: .request),
                .cancel
            ]
        )
    }
}
