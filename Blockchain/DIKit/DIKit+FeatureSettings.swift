// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAppUI
import FeatureCryptoDomainDomain
import FeatureCryptoDomainUI
import FeatureKYCUI
import FeatureSettingsDomain
import FeatureSettingsUI
import FeatureTransactionDomain
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainSettings = module {

        single { () -> FeatureSettingsDomain.KeychainItemWrapping in
            KeychainItemSwiftWrapper()
        }

        factory { () -> FeatureSettingsDomain.BlockchainDomainsAdapter in
            let service: BlockchainDomainsAdapter = DIKit.resolve()
            return service as FeatureSettingsDomain.BlockchainDomainsAdapter
        }

        factory { () -> FeatureSettingsUI.ExternalActionsProviderAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveExternalActionsProvider() as ExternalActionsProviderAPI
        }

        factory { () -> FeatureSettingsUI.KYCRouterAPI in
            KYCAdapter() as FeatureSettingsUI.KYCRouterAPI
        }

        factory { () -> FeatureSettingsUI.AuthenticationCoordinating in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveAuthenticationCoordinating() as AuthenticationCoordinating
        }

        factory { () -> FeatureSettingsUI.BlockchainDomainsRouterAdapter in
            let service: BlockchainDomainsRouterAdapter = DIKit.resolve()
            return service as FeatureSettingsUI.BlockchainDomainsRouterAdapter
        }

        factory { () -> BlockchainDomainsRouterAdapter in
            BlockchainDomainsRouterAdapter(
                coincore: DIKit.resolve(),
                nabuUserService: DIKit.resolve(),
                blockchainDomainsAdapter: DIKit.resolve()
            )
        }

        factory { () -> BlockchainDomainsAdapter in
            BlockchainDomainsAdapter(
                claimEligibilityRepository: DIKit.resolve(),
                coincore: DIKit.resolve(),
                nameResolutionRepository: DIKit.resolve(),
                tiersService: DIKit.resolve()
            )
        }
    }
}

struct BlockchainDomainsAdapter: FeatureSettingsDomain.BlockchainDomainsAdapter {

    private let claimEligibilityRepository: ClaimEligibilityRepositoryAPI
    private let coincore: CoincoreAPI
    private let nameResolutionRepository: BlockchainNameResolutionServiceAPI
    private let tiersService: KYCTiersServiceAPI

    init(
        claimEligibilityRepository: ClaimEligibilityRepositoryAPI,
        coincore: CoincoreAPI,
        nameResolutionRepository: BlockchainNameResolutionServiceAPI,
        tiersService: KYCTiersServiceAPI
    ) {
        self.claimEligibilityRepository = claimEligibilityRepository
        self.coincore = coincore
        self.nameResolutionRepository = nameResolutionRepository
        self.tiersService = tiersService
    }

    var canCompleteVerified: AnyPublisher<Bool, Never> {
        tiersService.tiers
            .map(\.canCompleteVerified)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    var claimEligibility: AnyPublisher<Bool, Never> {
        claimEligibilityRepository.checkClaimEligibility()
    }

    enum DomainError: Error {
        case failed
    }

    var associatedDomains: AnyPublisher<[String], Never> {
        Deferred { [coincore] in
            Just(coincore[.ethereum])
        }
        .flatMap { ethereum -> AnyPublisher<[String], Never> in
            guard let provider = ethereum as? DomainResolutionRecordProviderAPI else {
                return .just([])
            }
            return provider.resolutionRecord
                .flatMap { [nameResolutionRepository] resolutionRecord in
                    nameResolutionRepository
                        .reverseResolve(
                            address: resolutionRecord.walletAddress,
                            currency: resolutionRecord.symbol
                        )
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

class BlockchainDomainsRouterAdapter: FeatureSettingsUI.BlockchainDomainsRouterAdapter {

    private let coincore: CoincoreAPI
    private let nabuUserService: NabuUserServiceAPI
    private let blockchainDomainsAdapter: BlockchainDomainsAdapter
    private var cancellables: Set<AnyCancellable> = []

    init(
        coincore: CoincoreAPI,
        nabuUserService: NabuUserServiceAPI,
        blockchainDomainsAdapter: BlockchainDomainsAdapter
    ) {
        self.coincore = coincore
        self.nabuUserService = nabuUserService
        self.blockchainDomainsAdapter = blockchainDomainsAdapter
    }

    func presentFlow(from navigationRouter: NavigationRouterAPI) {
        cancellables = []
        blockchainDomainsAdapter
            .state
            .first()
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { state in
                    switch state {
                    case .readyToClaimDomain:
                        self.presentClaimIntroductionHostingController(from: navigationRouter)
                    case .kycForClaimDomain:
                        let kycRouter: PlatformUIKit.KYCRouterAPI = DIKit.resolve()
                        kycRouter.start(parentFlow: .settings)
                    case .unavailable:
                        break
                    case .domainsClaimed(let domains):
                        let presenter = CryptoDomainsDetailsPresenter(domains: domains)
                        let details = DetailsScreenViewController(presenter: presenter)
                        navigationRouter.present(viewController: details, using: .navigationFromCurrent)
                    }
                }
            )
            .subscribe()
            .store(in: &cancellables)
    }

    func presentClaimIntroductionHostingController(from navigationRouter: NavigationRouterAPI) {
        let viewController = ClaimIntroductionHostingController(
            mainQueue: .main,
            analyticsRecorder: DIKit.resolve(),
            externalAppOpener: DIKit.resolve(),
            searchDomainRepository: DIKit.resolve(),
            orderDomainRepository: DIKit.resolve(),
            userInfoProvider: { [coincore, nabuUserService] in
                Deferred { [coincore] in
                    Just([coincore[.ethereum], coincore[.bitcoin], coincore[.bitcoinCash], coincore[.stellar]])
                }
                .eraseError()
                .flatMap { [nabuUserService] cryptoAssets -> AnyPublisher<([ResolutionRecord], NabuUser), Error> in
                    guard let providers = cryptoAssets as? [DomainResolutionRecordProviderAPI] else {
                        return .empty()
                    }
                    let recordPublisher = providers.map(\.resolutionRecord).zip()
                    let nabuUserPublisher = nabuUserService.user.eraseError()
                    return recordPublisher
                        .zip(nabuUserPublisher)
                        .eraseToAnyPublisher()
                }
                .map { records, nabuUser -> OrderDomainUserInfo in
                    OrderDomainUserInfo(
                        nabuUserId: nabuUser.identifier,
                        nabuUserName: nabuUser
                            .personalDetails
                            .firstName?
                            .replacingOccurrences(of: " ", with: "") ?? "",
                        resolutionRecords: records
                    )
                }
                .eraseToAnyPublisher()
            }
        )
        navigationRouter.present(
            viewController: UINavigationController(rootViewController: viewController),
            using: .modalOverTopMost
        )
    }
}

final class CryptoDomainsDetailsPresenter: DetailsScreenPresenterAPI {

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark
    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default
    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default
    var cells: [DetailsScreen.CellType]
    var reloadRelay: PublishRelay<Void> = .init()
    var titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(
        value: .text(value: LocalizationConstants.Settings.cryptoDomainsTitle)
    )

    init(domains: [String]) {
        self.cells = domains
            .map { domain in
                DetailsScreen.CellType
                    .label(
                        DefaultLabelContentPresenter(
                            knownValue: domain,
                            descriptors: .lineItemDescription(accessibilityIdPrefix: "")
                        )
                    )
            }
    }
}
