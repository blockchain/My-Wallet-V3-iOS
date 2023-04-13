// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift
import ToolKit

public protocol LinkedBanksFactoryAPI {

    var linkedBanks: Single<[LinkedBankAccount]> { get }
    var nonWireTransferBanks: Single<[LinkedBankAccount]> { get }

    func bankPaymentMethods(for currency: FiatCurrency) -> AnyPublisher<[PaymentMethodType], Error>
}

final class LinkedBanksFactory: LinkedBanksFactoryAPI {

    private let linkedBankService: LinkedBanksServiceAPI
    private let paymentMethodService: PaymentMethodTypesServiceAPI

    init(
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        paymentMethodService: PaymentMethodTypesServiceAPI = resolve()
    ) {
        self.linkedBankService = linkedBankService
        self.paymentMethodService = paymentMethodService
    }

    var linkedBanks: Single<[LinkedBankAccount]> {
        linkedBankService
            .fetchLinkedBanks()
            .map { linkedBankData in
                linkedBankData.filter(\.isActive)
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    LinkedBankAccount(
                        label: data.account?.bankName ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        bankAccountType: data.account?.type ?? .checking,
                        currency: data.currency,
                        paymentType: data.paymentMethodType,
                        partner: data.partner,
                        data: data
                    )
                }
            }
    }

    var nonWireTransferBanks: Single<[LinkedBankAccount]> {
        linkedBankService
            .linkedBanks
            .map { banks in
                banks
                    .filter {
                        $0.isActive && $0.paymentMethodType == .bankTransfer
                    }
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    LinkedBankAccount(
                        label: data.account?.name ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        bankAccountType: data.account?.type ?? .checking,
                        currency: data.currency,
                        paymentType: data.paymentMethodType,
                        partner: data.partner,
                        data: data
                    )
                }
            }
    }

    func bankPaymentMethods(for currency: FiatCurrency) -> AnyPublisher<[PaymentMethodType], Error> {
        paymentMethodService
            .eligiblePaymentMethods(for: currency)
            .map { paymentMethodTyps in
                paymentMethodTyps.filter { paymentType in
                    paymentType.method == .bankAccount(.fiat(currency))
                        || paymentType.method == .bankTransfer(.fiat(currency))
                }
            }
            .eraseToAnyPublisher()
    }
}
