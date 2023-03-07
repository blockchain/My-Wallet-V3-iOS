// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
@testable import FeatureAccountPickerUI
import FeatureCardPaymentDomain
import MoneyKit
@testable import PlatformKit
@testable import PlatformKitMock
@testable import PlatformUIKit
import RxSwift
import SnapshotTesting
import SwiftUI
import XCTest

class AccountPickerRowViewTests: XCTestCase {

    var isShowingMultiBadge = false

    let accountGroupIdentifier = UUID()
    let singleAccountIdentifier = UUID()

    lazy var accountGroup = AccountPickerRow.AccountGroup(
        id: accountGroupIdentifier,
        title: "All Wallets",
        description: "Total Balance"
    )

    lazy var singleAccount = AccountPickerRow.SingleAccount(
        id: singleAccountIdentifier,
        title: "BTC Trading Wallet",
        description: "Bitcoin"
    )

    lazy var linkedBankAccountModel = AccountPickerRow.LinkedBankAccount(
        id: self.linkedBankAccount.identifier,
        title: "Title",
        description: "Description"
    )

    // swiftlint:disable:next force_try
    let linkedBankData = try! LinkedBankData(
        response: LinkedBankResponse(
            json: [
                "id": "id",
                "currency": "GBP",
                "partner": "YAPILY",
                "bankAccountType": "SAVINGS",
                "name": "Name",
                "accountName": "Account Name",
                "accountNumber": "123456",
                "routingNumber": "123456",
                "agentRef": "040004",
                "isBankAccount": false,
                "isBankTransferAccount": true,
                "state": "PENDING",
                "attributes": [
                    "entity": "Safeconnect(UK)"
                ]
            ]
        )
    )!

    lazy var linkedBankAccount = LinkedBankAccount(
        label: "LinkedBankAccount",
        accountNumber: "0",
        accountId: "0",
        bankAccountType: .checking,
        currency: .USD,
        paymentType: .bankAccount,
        partner: .yapily,
        data: linkedBankData
    )

    let paymentMethodFunds = PaymentMethodAccount(
        paymentMethodType: .account(
            FundData(
                balance: .init(
                    currency: .fiat(.GBP),
                    available: .create(majorBigInt: 25000, currency: .fiat(.GBP)),
                    withdrawable: .create(majorBigInt: 25000, currency: .fiat(.GBP)),
                    pending: .zero(currency: .GBP),
                    mainBalanceToDisplay: .create(majorBigInt: 25000, currency: .fiat(.GBP))
                ),
                max: .create(majorBigInt: 1000000, currency: .GBP)
            )
        ),
        paymentMethod: .init(
            type: .funds(.fiat(.GBP)),
            max: .create(majorBigInt: 10000, currency: .GBP),
            min: .create(majorBigInt: 5, currency: .GBP),
            isEligible: true,
            isVisible: true,
            capabilities: nil
        ),
        priceService: PriceServiceMock()
    )

    let paymentMethodCard = PaymentMethodAccount(
        paymentMethodType: .card(
            CardData(
                ownerName: "John Smith",
                number: "4000 0000 0000 0000",
                expirationDate: "12/30",
                cvv: "000"
            )!
        ),
        paymentMethod: .init(
            type: .card([.visa]),
            max: .create(majorBigInt: 1200, currency: .USD),
            min: .create(majorBigInt: 5, currency: .USD),
            isEligible: true,
            isVisible: true,
            capabilities: nil
        ),
        priceService: PriceServiceMock()
    )

    private func paymentMethodRowModel(for account: PaymentMethodAccount) -> AccountPickerRow.PaymentMethod {
        AccountPickerRow.PaymentMethod(
            id: account.identifier,
            title: account.label,
            description: account.paymentMethodType.balance.displayString,
            badgeView: account.logoResource.image,
            badgeBackground: Color(account.logoBackgroundColor)
        )
    }

    @ViewBuilder private func badgeView(for identifier: AnyHashable) -> some View {
        switch identifier {
        case singleAccount.id:
            BadgeImageViewRepresentable(
                viewModel: {
                    let model: BadgeImageViewModel = .default(
                        image: CryptoCurrency.bitcoin.logoResource,
                        cornerRadius: .round,
                        accessibilityIdSuffix: ""
                    )
                    model.marginOffsetRelay.accept(0)
                    return model
                }(),
                size: 32
            )
        case accountGroup.id:
            BadgeImageViewRepresentable(
                viewModel: {
                    let model: BadgeImageViewModel = .primary(
                        image: .local(name: "icon-wallet", bundle: .platformUIKit),
                        cornerRadius: .round,
                        accessibilityIdSuffix: "walletBalance"
                    )
                    model.marginOffsetRelay.accept(0)
                    return model
                }(),
                size: 32
            )
        case linkedBankAccountModel.id:
            BadgeImageViewRepresentable(
                viewModel: .default(
                    image: .local(name: "icon-bank", bundle: .platformUIKit),
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                ),
                size: 32
            )
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func multiBadgeView(for identity: AnyHashable) -> some View {
        if isShowingMultiBadge {
            switch identity {
            case linkedBankAccount.identifier:
                MultiBadgeViewRepresentable(
                    viewModel: SingleAccountBadgeFactory(withdrawalService: MockWithdrawalServiceAPI())
                        .badge(account: linkedBankAccount, action: .withdraw)
                        .map {
                            MultiBadgeViewModel(
                                layoutMargins: LinkedBankAccountCellPresenter.multiBadgeInsets,
                                height: 24.0,
                                badges: $0
                            )
                        }
                        .asDriver(onErrorJustReturn: .init())
                )
            case singleAccount.id:
                MultiBadgeViewRepresentable(
                    viewModel: .just(MultiBadgeViewModel(
                        layoutMargins: UIEdgeInsets(
                            top: 8,
                            left: 60,
                            bottom: 16,
                            right: 24
                        ),
                        height: 24,
                        badges: [
                            DefaultBadgeAssetPresenter.makeLowFeesBadge(),
                            DefaultBadgeAssetPresenter.makeFasterBadge()
                        ]
                    ))
                )
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private func iconView(for _: AnyHashable) -> some View {
        BadgeImageViewRepresentable(
            viewModel: {
                let model: BadgeImageViewModel = .template(
                    image: .local(name: "ic-private-account", bundle: .platformUIKit),
                    templateColor: CryptoCurrency.bitcoin.brandUIColor,
                    backgroundColor: .white,
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(1)
                return model
            }(),
            size: 16
        )
    }

    @ViewBuilder private func descriptionView(for _: AnyHashable) -> some View {
        Text(singleAccount.description)
            .textStyle(.subheading)
            .scaledToFill()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    @ViewBuilder private func view(
        row: AccountPickerRow,
        fiatBalance: String? = nil,
        cryptoBalance: String? = nil,
        currencyCode: String? = nil
    ) -> some View {
        AccountPickerRowView(
            model: row,
            send: { _ in },
            badgeView: badgeView(for:),
            descriptionView: descriptionView(for:),
            iconView: iconView(for:),
            multiBadgeView: multiBadgeView(for:),
            withdrawalLocksView: { EmptyView() },
            topMoversView: { EmptyView() },
            fiatBalance: fiatBalance,
            cryptoBalance: cryptoBalance,
            currencyCode: currencyCode
        )
        .app(App.preview)
        .fixedSize()
    }

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testAccountGroup() {
        let accountGroupRow = AccountPickerRow.accountGroup(
            accountGroup
        )

        let view = view(
            row: accountGroupRow,
            fiatBalance: "$2,302.39",
            cryptoBalance: "0.21204887 BTC",
            currencyCode: "USD"
        )

        assertSnapshot(matching: view, as: .image)
    }

    func testAccountGroupLoading() {
        let accountGroupRow = AccountPickerRow.accountGroup(
            accountGroup
        )

        assertSnapshot(matching: view(row: accountGroupRow), as: .image)
    }

    func testSingleAccount() {
        let singleAccountRow = AccountPickerRow.singleAccount(
            singleAccount
        )

        let view = view(
            row: singleAccountRow,
            fiatBalance: "$2,302.39",
            cryptoBalance: "0.21204887 BTC",
            currencyCode: nil
        )

        assertSnapshot(matching: view, as: .image)

        isShowingMultiBadge = true

        assertSnapshot(matching: view, as: .image)
    }

    func testSingleAccountLoading() {
        let singleAccountRow = AccountPickerRow.singleAccount(
            singleAccount
        )

        assertSnapshot(matching: view(row: singleAccountRow), as: .image)
    }

    func testButton() {
        let buttonRow = AccountPickerRow.button(
            .init(
                id: UUID(),
                text: "+ Add New"
            )
        )

        assertSnapshot(matching: view(row: buttonRow), as: .image)
    }

    func testLinkedAccount() {
        let linkedAccountRow = AccountPickerRow.linkedBankAccount(
            linkedBankAccountModel
        )

        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)

        isShowingMultiBadge = true

        assertSnapshot(matching: view(row: linkedAccountRow), as: .image(perceptualPrecision: 0.98))
    }

    func testPaymentMethod_funds() {
        let linkedAccountRow = AccountPickerRow.paymentMethodAccount(
            paymentMethodRowModel(for: paymentMethodFunds)
        )
        assertSnapshot(matching: view(row: linkedAccountRow), as: .image(perceptualPrecision: 0.98))
    }

    func testPaymentMethod_card() {
        let linkedAccountRow = AccountPickerRow.paymentMethodAccount(
            paymentMethodRowModel(for: paymentMethodCard)
        )
        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)
    }
}

struct MockWithdrawalServiceAPI: WithdrawalServiceAPI {

    func withdrawFeeAndLimit(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<WithdrawalFeeAndLimit> {
        .just(.init(
            maxLimit: .zero(currency: currency),
            minLimit: .zero(currency: currency),
            fee: .zero(currency: currency)
        ))
    }

    func withdrawal(
        for checkout: WithdrawalCheckoutData
    ) -> Single<Result<FiatValue, Error>> {
        fatalError("Not implemented")
    }

    func withdrawalFee(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }

    func withdrawalMinAmount(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }
}
