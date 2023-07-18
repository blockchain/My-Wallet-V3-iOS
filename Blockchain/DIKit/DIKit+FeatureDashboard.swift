// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAppUI
import FeatureCoinDomain
import FeatureDashboardUI
import FeatureKYCUI
import FeatureSettingsDomain
import FeatureSettingsUI
import NetworkKit
import PlatformUIKit
import RxCocoa
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainDashboard = module {

        single { () -> PricesWatchlistRepositoryAPI in
            PricesWatchlistRepository(
                watchlistRepository: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }
    }
}

final class PricesWatchlistRepository: PricesWatchlistRepositoryAPI {

    private let app: AppProtocol
    private var cancellables = Set<AnyCancellable>()
    private let subject: CurrentValueSubject<Set<String>?, NetworkError> = CurrentValueSubject([])

    init(
        watchlistRepository: WatchlistRepositoryAPI,
        app: AppProtocol
    ) {

        self.app = app

        watchlistRepository.getWatchlist()
            .sink(receiveValue: subject.send(_:))
            .store(in: &cancellables)

        app.on(blockchain.ux.asset.watchlist.add).eraseError()
            .withLatestFrom(subject.eraseError(), selector: { ($0, $1) })
            .map { event, watchlist in
                if let code = try? event.reference.context.decode(blockchain.ux.asset.id) as String {
                    return watchlist?.union(Set([code]))
                }
                return watchlist
            }
            .sink(receiveValue: subject.send(_:))
            .store(in: &cancellables)

        app.on(blockchain.ux.asset.watchlist.remove).eraseError()
            .withLatestFrom(subject.eraseError(), selector: { ($0, $1) })
            .map { event, watchlist in
                var watchlist = watchlist
                if let code = try? event.reference.context.decode(blockchain.ux.asset.id) as String {
                    watchlist?.remove(code)
                }
                return watchlist
            }
            .sink(receiveValue: subject.send(_:))
            .store(in: &cancellables)
    }

    func watchlist() -> AnyPublisher<Result<Set<String>?, Error>, Never> {
        subject.handleEvents(
            receiveOutput: { [app] watchlist in
                Task {
                    try await app.set(blockchain.user.asset.watchlist, to: watchlist?.array)
                }
            }
        )
        .eraseError()
        .result()
    }
}
