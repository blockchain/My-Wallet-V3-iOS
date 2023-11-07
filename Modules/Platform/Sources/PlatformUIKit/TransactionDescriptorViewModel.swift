// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

struct BadgeImageAttributes {
    let imageResource: ImageLocation
    let brandColor: UIColor
    let isFiat: Bool

    static let empty = BadgeImageAttributes(
        imageResource: .local(name: "", bundle: .platformUIKit),
        brandColor: .white,
        isFiat: false
    )

    init(_ currencyType: CurrencyType) {
        self.imageResource = currencyType.logoResource
        self.brandColor = currencyType.brandUIColor
        self.isFiat = currencyType.isFiatCurrency
    }

    init(imageResource: ImageLocation, brandColor: UIColor, isFiat: Bool) {
        self.imageResource = imageResource
        self.brandColor = brandColor
        self.isFiat = isFiat
    }
}

public struct TransactionDescriptorViewModel {
    public var transactionTypeBadgeImageViewModel: Driver<BadgeImageViewModel> {
        guard adjustActionIconColor else {
            return Driver.just(
                provideBadgeImageViewModel(
                    accentColor: .primary,
                    backgroundColor: .lightBlueBackground
                )
            )
        }
        return fromAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { attributes -> BadgeImageViewModel in
                provideBadgeImageViewModel(
                    accentColor: attributes.brandColor,
                    backgroundColor: attributes.brandColor.withAlphaComponent(0.15)
                )
            }
    }

    public var fromAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        fromAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { attributes -> BadgeImageViewModel in
                var model: BadgeImageViewModel = switch attributes.isFiat {
                case true:
                    BadgeImageViewModel.primary(
                        image: attributes.imageResource,
                        contentColor: .white,
                        backgroundColor: attributes.brandColor,
                        cornerRadius: attributes.isFiat ? .roundedHigh : .round,
                        accessibilityIdSuffix: ""
                    )
                case false:
                    BadgeImageViewModel.default(
                        image: attributes.imageResource,
                        cornerRadius: attributes.isFiat ? .roundedHigh : .round,
                        accessibilityIdSuffix: ""
                    )
                }
                model.marginOffsetRelay.accept(0)
                return model
            }
    }

    public var toAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        toAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { attributes -> BadgeImageViewModel in
                let model = BadgeImageViewModel.default(
                    image: attributes.imageResource,
                    cornerRadius: attributes.isFiat ? .roundedHigh : .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(0)
                return model
            }
    }

    public var toAccountBadgeIsHidden: Driver<Bool> {
        toAccountRelay
            .map(\.isEmpty)
            .asDriver(onErrorDriveWith: .empty())
    }

    private let assetAction: AssetAction
    private let adjustActionIconColor: Bool

    public init(assetAction: AssetAction, adjustActionIconColor: Bool = false) {
        self.assetAction = assetAction
        self.adjustActionIconColor = adjustActionIconColor
    }

    public enum TransactionAccountValue {
        case value(SingleAccount)
        case empty

        var account: SingleAccount? {
            switch self {
            case .value(let account):
                account
            case .empty:
                nil
            }
        }

        var isEmpty: Bool {
            switch self {
            case .value:
                false
            case .empty:
                true
            }
        }
    }

    /// The `SingleAccount` that the transaction is originating from
    public let fromAccountRelay = BehaviorRelay<TransactionAccountValue>(value: .empty)

    /// The `SingleAccount` that is the destination for the transaction
    public let toAccountRelay = BehaviorRelay<TransactionAccountValue>(value: .empty)

    public init(
        sourceAccount: SingleAccount? = nil,
        destinationAccount: SingleAccount? = nil,
        assetAction: AssetAction,
        adjustActionIconColor: Bool = false
    ) {
        self.assetAction = assetAction
        self.adjustActionIconColor = adjustActionIconColor
        if let sourceAccount {
            fromAccountRelay.accept(.value(sourceAccount))
        }
        if let destinationAccount {
            toAccountRelay.accept(.value(destinationAccount))
        }
    }

    private func provideBadgeImageViewModel(accentColor: UIColor, backgroundColor: UIColor) -> BadgeImageViewModel {
        let viewModel = BadgeImageViewModel.template(
            image: .local(name: assetAction.assetImageName, bundle: .platformUIKit),
            templateColor: accentColor,
            backgroundColor: backgroundColor,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )
        viewModel.marginOffsetRelay.accept(0)
        return viewModel
    }
}

extension AssetAction {
    fileprivate var assetImageName: String {
        switch self {
        case .deposit,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit:
            "deposit-icon"
        case .receive:
            "receive-icon"
        case .viewActivity:
            "clock-icon"
        case .buy:
            "plus-icon"
        case .sell:
            "minus-icon"
        case .send:
            "send-icon"
        case .sign:
            fatalError("Impossible.")
        case .swap:
            "swap-icon"
        case .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            "withdraw-icon"
        }
    }
}
