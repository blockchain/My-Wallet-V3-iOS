import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import ToolKit

final class NabuUserSessionObserver: Client.Observer {

    unowned let app: AppProtocol

    private var bag: Set<AnyCancellable> = []
    private let userService: NabuUserServiceAPI
    private let tokenRepository: NabuTokenRepositoryAPI
    private let offlineTokenRepository: NabuOfflineTokenRepositoryAPI
    private let kycTierService: KYCTiersServiceAPI

    init(
        app: AppProtocol,
        tokenRepository: NabuTokenRepositoryAPI = resolve(),
        offlineTokenRepository: NabuOfflineTokenRepositoryAPI = resolve(),
        userService: NabuUserServiceAPI = resolve(),
        kycTierService: KYCTiersServiceAPI = resolve()
    ) {
        self.app = app
        self.tokenRepository = tokenRepository
        self.offlineTokenRepository = offlineTokenRepository
        self.userService = userService
        self.kycTierService = kycTierService
    }

    var token: AnyCancellable?

    func start() {

        resetTokenObserver()
        tokenRepository.sessionTokenPublisher
            .compactMap(\.wrapped?.token)
            .removeDuplicates()
            .sink { [app] token in
                app.post(value: token, of: blockchain.user.token.nabu)
            }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.in, blockchain.ux.kyc.event.status.did.change)
            .flatMap { [userService] _ in userService.fetchUser() }
            .sink(to: NabuUserSessionObserver.fetched(user:), on: self)
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.out)
            .sink(to: My.resetTokenObserver, on: self)
            .store(in: &bag)

        app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .removeDuplicates()
            .dropFirst()
            .flatMap { [userService] currency -> AnyPublisher<NabuUser, Never> in
                userService.setTradingCurrency(currency)
                    .flatMap { userService.fetchUser().mapError(\.nabu) }
                    .ignoreFailure()
                    .eraseToAnyPublisher()
            }
            .sink(to: NabuUserSessionObserver.fetched(user:), on: self)
            .store(in: &bag)

        kycTierService.tiersStream
            .removeDuplicates()
            .sink(to: My.fetched(tiers:), on: self)
            .store(in: &bag)
    }

    func stop() {
        bag = []
    }

    func resetTokenObserver() {
        token = offlineTokenRepository.offlineTokenPublisher
            .receive(on: DispatchQueue.main)
            .compactMap(\.success?.userId)
            .removeDuplicates()
            .sink { [app] userId in
                app.signIn(userId: userId)
            }
    }

    func fetched(user: NabuUser) {
        app.state.transaction { state in

            state.set(blockchain.user.is.cowboy.fan, to: user.isCowboys)
            state.set(blockchain.user.is.superapp.user, to: user.isSuperAppUser)
            state.set(blockchain.user.is.superapp.v1.user, to: user.isSuperAppV1User)
            state.set(blockchain.user.email.address, to: user.email.address)
            state.set(blockchain.user.email.is.verified, to: user.email.verified)
            state.set(blockchain.user.name.first, to: user.personalDetails.firstName)
            state.set(blockchain.user.name.last, to: user.personalDetails.lastName)
            state.set(blockchain.user.currency.currencies, to: user.currencies.userFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.preferred.fiat.trading.currency, to: user.currencies.preferredFiatTradingCurrency.code)
            state.set(blockchain.user.currency.available.currencies, to: user.currencies.usableFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.default, to: user.currencies.defaultWalletCurrency.code)
            state.set(blockchain.user.address.line_1, to: user.address?.lineOne)
            state.set(blockchain.user.address.line_2, to: user.address?.lineTwo)
            state.set(blockchain.user.address.state, to: user.address?.state)
            state.set(blockchain.user.address.city, to: user.address?.city)
            state.set(blockchain.user.address.postal.code, to: user.address?.postalCode)
            state.set(blockchain.user.address.country.code, to: user.address?.countryCode)
            state.set(blockchain.user.account.tier, to: (user.tiers?.current).tag)
            state.set(blockchain.user.account.kyc.id, to: (user.tiers?.current).tag.id)
            state.set(blockchain.user.is.tier.gold, to: user.isGoldTierVerified)
        }
        app.post(event: blockchain.user.event.did.update)
    }

    func fetched(tiers: KYC.UserTiers) {
        app.state.transaction { state in
            for kyc in tiers.tiers {
                state.set(blockchain.user.account.kyc[kyc.tier.tag.id].name, to: kyc.name)
                state.set(blockchain.user.account.kyc[kyc.tier.tag.id].limits.annual, to: kyc.limits?.annual)
                state.set(blockchain.user.account.kyc[kyc.tier.tag.id].limits.daily, to: kyc.limits?.daily)
                state.set(blockchain.user.account.kyc[kyc.tier.tag.id].limits.currency, to: kyc.limits?.currency)
                state.set(blockchain.user.account.kyc[kyc.tier.tag.id].state, to: blockchain.user.account.kyc.state[][kyc.state.rawValue.lowercased()])
            }
        }
    }
}

extension KYC.Tier {

    var tag: Tag {
        switch self {
        case .tier0:
            return blockchain.user.account.tier.none[]
        case .tier1:
            return blockchain.user.account.tier.silver[]
        case .tier2:
            return blockchain.user.account.tier.gold[]
        }
    }
}

extension KYC.Tier? {

    var tag: Tag {
        switch self {
        case .some(let tier):
            return tier.tag
        case .none:
            return blockchain.user.account.tier.none[]
        }
    }
}
