// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

protocol AccountAuxiliaryViewInteractorAPI {
    /// The view has been tapped.
    /// This should trigger an event that presents
    /// a new screen to select a different account.
    var auxiliaryViewTappedRelay: PublishRelay<Void> { get }
}

extension AccountAuxiliaryViewInteractorAPI {
    /// Streams auxiliary view tap events.
    var auxiliaryViewTapped: Observable<Void> {
        auxiliaryViewTappedRelay
            .asObservable()
    }
}

private typealias LocalizationIds = LocalizationConstants.Transaction

final class AccountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractorAPI {

    // MARK: - State

    struct State {
        let title: String
        let subtitle: String
        let imageResource: ImageResource
        let imageBackgroundColor: UIColor
        let isEnabled: Bool
        let badgeViewModel: BadgeViewModel?

        init(
            title: String,
            subtitle: String,
            imageResource: ImageResource,
            imageBackgroundColor: UIColor,
            isEnabled: Bool = true,
            badgeViewModel: BadgeViewModel? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.imageResource = imageResource
            self.imageBackgroundColor = imageBackgroundColor
            self.isEnabled = isEnabled
            self.badgeViewModel = badgeViewModel
        }

        static let empty: State = .init(
            title: "",
            subtitle: "",
            imageResource: .local(
                name: "icon-bank",
                bundle: .platformUIKit
            ),
            imageBackgroundColor: .background,
            isEnabled: false
        )
    }

    // MARK: - AccountAuxiliaryViewInteractorAPI

    let auxiliaryViewTappedRelay = PublishRelay<Void>()

    // MARK: Public Properties

    var state: Driver<State> {
        stateRelay
            .asDriver()
    }

    let stateRelay = BehaviorRelay<State>(value: .empty)

    // MARK: - Connect API

    func connect(stream: Observable<BlockchainAccount>, tapEnabled: Observable<Bool>) -> Disposable {
        Observable.combineLatest(
            stream,
            tapEnabled
        )
        .map { account, tapEnabled -> State in
            switch account {
            case let bank as LinkedBankAccount:
                let type = bank.bankAccountType.title
                let description = type + (type.isEmpty ? "" : " ") + "\(LocalizationIds.account) -"
                let subtitle = description + " \(bank.accountNumber)"
                return .init(
                    title: bank.label,
                    subtitle: subtitle,
                    imageResource: bank.logoResource,
                    imageBackgroundColor: bank.logoBackgroundColor,
                    isEnabled: tapEnabled
                )

            case let paymentMethodAccount as PaymentMethodAccount:
                var badgeViewModel: BadgeViewModel?
                let block = paymentMethodAccount.paymentMethodType.block
                if let title = paymentMethodAccount.paymentMethodType.ux?.title {
                    badgeViewModel = block ? nil : .warning(with: title)
                }
                return .init(
                    title: paymentMethodAccount.label,
                    subtitle: String(format: LocalizationConstants.maxPurchaseArg, paymentMethodAccount.paymentMethodType.topLimit.displayString),
                    imageResource: paymentMethodAccount.logoResource,
                    imageBackgroundColor: paymentMethodAccount.logoBackgroundColor,
                    isEnabled: tapEnabled,
                    badgeViewModel: badgeViewModel
                )

            case let fiatAccount as FiatAccount:
                return .init(
                    title: fiatAccount.label,
                    subtitle: "",
                    imageResource: fiatAccount.logoResource,
                    imageBackgroundColor: fiatAccount.logoBackgroundColor,
                    isEnabled: tapEnabled
                )

            default:
                unimplemented()
            }
        }
        .bindAndCatch(to: stateRelay)
    }
}
