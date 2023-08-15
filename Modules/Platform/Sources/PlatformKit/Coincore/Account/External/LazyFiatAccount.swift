import Blockchain

public typealias FiatAccountWithCapabilities = FiatAccount & FiatAccountCapabilities

public final class LazyFiatAccount: FiatAccount, FiatAccountCapabilities {

    public typealias AccountPublisher = AnyPublisher<FiatAccountWithCapabilities, Never>

    var account: AccountPublisher

    public init(account: AccountPublisher, currency: FiatCurrency) {
        self.account = account
        let uuid = UUID().uuidString
        self.identifier = uuid + "." + currency.code
        self.fiatCurrency = currency
        self.label = uuid
        self.isDefault = false
        self.assetName = currency.name
        self.accountType = .trading
        self.capabilities = nil
        Task {
            for await account in account.values {
                self.identifier = account.identifier
                self.label = account.label
                self.isDefault = account.isDefault
                self.assetName = account.assetName
                self.accountType = account.accountType
                self.capabilities = account.capabilities
            }
        }
    }

    public private(set) var identifier: String
    public private(set) var isDefault: Bool
    public private(set) var label: String
    public private(set) var assetName: String
    public private(set) var accountType: AccountType
    public private(set) var fiatCurrency: FiatCurrency
    public private(set) var capabilities: Capabilities?

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        account.flatMap(\.receiveAddress).eraseToAnyPublisher()
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        account.flatMap(\.pendingBalance).eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        account.flatMap(\.balance).eraseToAnyPublisher()
    }

    public var mainBalanceToDisplay: AnyPublisher<MoneyValue, Error> {
        account.flatMap(\.mainBalanceToDisplay).eraseToAnyPublisher()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        account.flatMap(\.actionableBalance).eraseToAnyPublisher()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        account.flatMap { account in
            account.can(perform: action)
        }.eraseToAnyPublisher()
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        account.flatMap { account in
            account.balancePair(fiatCurrency: fiatCurrency, at: time)
        }.eraseToAnyPublisher()
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        account.flatMap { account in
            account.mainBalanceToDisplayPair(fiatCurrency: fiatCurrency, at: time)
        }.eraseToAnyPublisher()
    }

    private var bag: Set<AnyCancellable> = []

    public func invalidateAccountBalance() {
        account.sink { account in
            account.invalidateAccountBalance()
        }
        .store(in: &bag)
    }
}
