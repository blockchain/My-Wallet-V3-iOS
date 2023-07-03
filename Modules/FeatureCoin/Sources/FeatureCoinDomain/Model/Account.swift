// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import Foundation
import Localization
import MoneyKit

public struct Account: Identifiable {

    public enum AccountType: String, Codable {
        case privateKey
        case trading
        case interest
        case exchange
        case staking
        case activeRewards

        public var supportRates: Bool {
            self == .interest || self == .staking || self == .activeRewards
        }
    }

    public var id: AnyHashable

    public let name: String
    public let assetName: String
    public let accountType: AccountType
    public let cryptoCurrency: CryptoCurrency
    public let fiatCurrency: FiatCurrency
    public let actionsPublisher: () -> AnyPublisher<OrderedSet<Account.Action>, Error>
    public let cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>
    public let fiatBalancePublisher: AnyPublisher<MoneyValue, Never>
    public let receiveAddressPublisher: AnyPublisher<String, Never>

    /// `true` if the accountType is not fully supported
    public var isComingSoon: Bool {
        false // accountType == .staking
    }

    public init(
        id: AnyHashable,
        name: String,
        assetName: String,
        accountType: Account.AccountType,
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        actionsPublisher: @escaping () -> AnyPublisher<OrderedSet<Account.Action>, Error>,
        cryptoBalancePublisher: AnyPublisher<MoneyValue, Never>,
        fiatBalancePublisher: AnyPublisher<MoneyValue, Never>,
        receiveAddressPublisher: AnyPublisher<String, Never>
    ) {
        self.id = id
        self.name = name
        self.assetName = assetName
        self.accountType = accountType
        self.cryptoCurrency = cryptoCurrency
        self.fiatCurrency = fiatCurrency
        self.actionsPublisher = actionsPublisher
        self.cryptoBalancePublisher = cryptoBalancePublisher
        self.fiatBalancePublisher = fiatBalancePublisher
        self.receiveAddressPublisher = receiveAddressPublisher
    }
}

extension Account {

    public struct Snapshot: Hashable, Identifiable {

        public var id: AnyHashable

        public let name: String
        public let assetName: String
        public let accountType: AccountType
        public let cryptoCurrency: CryptoCurrency
        public let fiatCurrency: FiatCurrency
        public let receiveAddress: String?
        public let actions: OrderedSet<Account.Action>
        public let crypto: MoneyValue?
        public let fiat: MoneyValue?
        public let isComingSoon: Bool

        public init(
            id: AnyHashable,
            name: String,
            assetName: String,
            accountType: Account.AccountType,
            cryptoCurrency: CryptoCurrency,
            fiatCurrency: FiatCurrency,
            actions: OrderedSet<Account.Action>,
            crypto: MoneyValue?,
            fiat: MoneyValue?,
            isComingSoon: Bool,
            receiveAddress: String?
        ) {
            self.id = id
            self.name = name
            self.assetName = assetName
            self.accountType = accountType
            self.cryptoCurrency = cryptoCurrency
            self.fiatCurrency = fiatCurrency
            self.actions = actions
            self.crypto = crypto
            self.fiat = fiat
            self.isComingSoon = isComingSoon
            self.receiveAddress = receiveAddress
        }
    }
}

extension Account {

    public struct Action: Hashable, Identifiable {
        public var id: L
        public var title: String
        public var description: String
        public var icon: Icon
    }
}

extension Account.Action {

    typealias L10n = LocalizationConstants.CoinDomain.Button

    public static let buy = Account.Action(
        id: blockchain.ux.asset.account.buy,
        title: L10n.Title.buy,
        description: L10n.Description.buy,
        icon: .walletBuy
    )

    public static let sell = Account.Action(
        id: blockchain.ux.asset.account.sell,
        title: L10n.Title.sell,
        description: L10n.Description.sell,
        icon: .walletSell
    )

    public static let send = Account.Action(
        id: blockchain.ux.asset.account.send,
        title: L10n.Title.send,
        description: L10n.Description.send,
        icon: .walletSend
    )

    public static let receive = Account.Action(
        id: blockchain.ux.asset.account.receive,
        title: L10n.Title.receive,
        description: L10n.Description.receive,
        icon: .walletReceive
    )

    public static let swap = Account.Action(
        id: blockchain.ux.asset.account.currency.exchange,
        title: L10n.Title.swap,
        description: L10n.Description.swap,
        icon: .walletSwap
    )

    public static let staking = (
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.staking.withdraw,
            title: L10n.Title.withdraw,
            description: L10n.Description.Staking.withdraw,
            icon: .walletWithdraw
        ),
        deposit: Account.Action(
            id: blockchain.ux.asset.account.staking.deposit,
            title: L10n.Title.deposit,
            description: L10n.Description.Staking.deposit,
            icon: .walletDeposit
        ),
        summary: Account.Action(
            id: blockchain.ux.asset.account.staking.summary,
            title: L10n.Title.Rewards.summary,
            description: L10n.Description.Staking.summary,
            icon: .walletPercent
        )
    )

    public static let active = (
        deposit: Account.Action(
            id: blockchain.ux.asset.account.active.rewards.deposit,
            title: L10n.Title.deposit,
            description: L10n.Description.ActiveRewards.deposit,
            icon: .walletDeposit
        ),
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.active.rewards.withdraw,
            title: L10n.Title.withdraw,
            description: L10n.Description.ActiveRewards.withdraw,
            icon: .walletWithdraw
        ),
        summary: Account.Action(
            id: blockchain.ux.asset.account.active.rewards.summary,
            title: L10n.Title.Rewards.summary,
            description: L10n.Description.ActiveRewards.summary,
            icon: .walletPercent
        )
    )

    public static let rewards = (
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.rewards.withdraw,
            title: L10n.Title.withdraw,
            description: L10n.Description.Rewards.withdraw,
            icon: .walletWithdraw
        ),
        deposit: Account.Action(
            id: blockchain.ux.asset.account.rewards.deposit,
            title: L10n.Title.deposit,
            description: L10n.Description.Rewards.deposit,
            icon: .walletDeposit
        ),
        summary: Account.Action(
            id: blockchain.ux.asset.account.rewards.summary,
            title: L10n.Title.Rewards.summary,
            description: L10n.Description.Rewards.summary,
            icon: .walletPercent
        )
    )

    public static let exchange = (
        withdraw: Account.Action(
            id: blockchain.ux.asset.account.exchange.withdraw,
            title: L10n.Title.withdraw,
            description: L10n.Description.Exchange.withdraw,
            icon: .walletWithdraw
        ),
        deposit: Account.Action(
            id: blockchain.ux.asset.account.exchange.deposit,
            title: L10n.Title.deposit,
            description: L10n.Description.Exchange.deposit,
            icon: .walletDeposit
        )
    )

    public static let activity = Account.Action(
        id: blockchain.ux.asset.account.activity,
        title: L10n.Title.activity,
        description: L10n.Description.activity,
        icon: .walletPending
    )
}

extension Collection<Account> {
    public var snapshot: AnyPublisher<[Account.Snapshot], Never> {
        map { account -> AnyPublisher<Account.Snapshot, Never> in
            account.cryptoBalancePublisher
                .combineLatest(
                    account.fiatBalancePublisher,
                    account.actionsPublisher().replaceError(with: []).prepend([]),
                    account.receiveAddressPublisher
                )
                .map { crypto, fiat, actions, receiveAddress in
                    Account.Snapshot(
                        id: account.id,
                        name: account.name,
                        assetName: account.assetName,
                        accountType: account.accountType,
                        cryptoCurrency: account.cryptoCurrency,
                        fiatCurrency: account.fiatCurrency,
                        actions: actions,
                        crypto: crypto,
                        fiat: fiat,
                        isComingSoon: account.isComingSoon,
                        receiveAddress: receiveAddress
                    )
                }
                .prepend(
                    Account.Snapshot(
                        id: account.id,
                        name: account.name,
                        assetName: account.assetName,
                        accountType: account.accountType,
                        cryptoCurrency: account.cryptoCurrency,
                        fiatCurrency: account.fiatCurrency,
                        actions: [],
                        crypto: nil,
                        fiat: nil,
                        isComingSoon: false,
                        receiveAddress: nil
                    )
                )
                .eraseToAnyPublisher()
        }
        .combineLatest()
        .eraseToAnyPublisher()
    }
}

extension Collection<Account.Snapshot> {

    public var cryptoBalance: MoneyValue? {
        guard let currency = first?.cryptoCurrency else { return nil }
        return try? compactMap(\.crypto)
            .reduce(MoneyValue.zero(currency: currency), +)
    }

    public var fiatBalance: MoneyValue? {
        guard let currency = first?.fiatCurrency else { return nil }
        return try? compactMap(\.fiat)
            .reduce(MoneyValue.zero(currency: currency), +)
    }

    public var canSwap: Bool {
        first(where: { account in account.actions.contains(.swap) }) != nil
    }

    public var hasPositiveBalanceForSelling: Bool {
        first(where: { account in account.accountType == .trading })?.fiat?.isPositive
            ?? first(where: { account in account.accountType == .privateKey })?.fiat?.isPositive
            ?? false
    }
}

extension Account.Snapshot {

    public static var preview = (
        privateKey: Account.Snapshot.stub(
            id: "PrivateKey",
            name: "DeFi Wallet",
            accountType: .privateKey,
            actions: [.send, .receive, .activity]
        ),
        trading: Account.Snapshot.stub(
            id: "Trading",
            name: "Blockchain.com Account",
            accountType: .trading,
            actions: [.buy, .sell, .send, .receive, .swap, .activity]
        ),
        rewards: Account.Snapshot.stub(
            id: "Rewards",
            name: "Rewards Account",
            accountType: .interest,
            actions: [.rewards.withdraw, .rewards.deposit]
        ),
        exchange: Account.Snapshot.stub(
            id: "Exchange",
            name: "Exchange Account",
            accountType: .exchange,
            actions: [.exchange.withdraw, .exchange.deposit]
        )
    )

    public static func stub(
        id: AnyHashable = "PrivateKey",
        name: String = "DeFi Wallet",
        accountType: Account.AccountType = .privateKey,
        cryptoCurrency: CryptoCurrency = .bitcoin,
        fiatCurrency: FiatCurrency = .USD,
        actions: OrderedSet<Account.Action> = [.send, .receive],
        crypto: MoneyValue = .create(minor: BigInt(123000000), currency: .crypto(.bitcoin)),
        fiat: MoneyValue = .create(minor: BigInt(4417223), currency: .fiat(.USD)),
        isComingSoon: Bool = false
    ) -> Account.Snapshot {
        Account.Snapshot(
            id: id,
            name: name,
            assetName: "",
            accountType: accountType,
            cryptoCurrency: cryptoCurrency,
            fiatCurrency: fiatCurrency,
            actions: actions,
            crypto: crypto,
            fiat: fiat,
            isComingSoon: isComingSoon,
            receiveAddress: nil
        )
    }
}

extension CryptoCurrency {
    public static let nonTradable =
        CryptoCurrency(
            assetModel: AssetModel(
                code: "NOTRADE",
                displayCode: "NTRD",
                kind: .coin(minimumOnChainConfirmations: 0),
                name: "Non-Tradable Coin",
                precision: 0,
                products: [],
                logoPngUrl: nil,
                spotColor: nil,
                sortIndex: 0
            )
        )!
}
