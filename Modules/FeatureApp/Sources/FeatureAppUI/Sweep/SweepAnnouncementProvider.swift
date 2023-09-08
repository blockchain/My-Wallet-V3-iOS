// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Blockchain
import BlockchainUI
import Combine
import DIKit
import FeatureAnnouncementsDomain
import Localization
import MoneyKit
import PlatformKit
import WalletPayloadKit

public final class SweepAnnouncementProvider: AnnouncementsServiceAPI {

    private static let filteringPrefix = "1"

    private let app: AppProtocol
    private let settingsService: SettingsServiceAPI
    private let walletHolder: WalletHolderAPI

    public init(
        app: AppProtocol = resolve(),
        settingsService: SettingsServiceAPI = resolve(),
        walletHolder: WalletHolderAPI = resolve()
    ) {
        self.app = app
        self.settingsService = settingsService
        self.walletHolder = walletHolder
    }

    public func fetchMessages(for modes: [FeatureAnnouncementsDomain.Announcement.AppMode], force: Bool) async throws -> [FeatureAnnouncementsDomain.Announcement] {
        let flag = app
            .publisher(for: blockchain.app.configuration.sweep.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()

        let recommendImportedSweep: AnyPublisher<Bool, Never> = settingsService
            .valuePublisher
            .map(\.recommendImportedSweep)
            .catch { _ in false }
            .removeDuplicates()
            .eraseToAnyPublisher()

        let isEnabled: AnyPublisher<Bool, Never> = flag
            .flatMap { enabled -> AnyPublisher<Bool, Never> in
                enabled ? recommendImportedSweep : .just(false)
            }
            .eraseToAnyPublisher()

        let addresses: AnyPublisher<[String], Never> = walletHolder
            .walletStatePublisher
            .map { state -> [String] in
                guard let wrapper = state?.wrapper else {
                    return []
                }
                return wrapper.wallet
                    .addresses
                    .map(\.addr)
                    .filter { $0.hasPrefix(Self.filteringPrefix) }
            }
            .eraseToAnyPublisher()

        let announcement: AnyPublisher<Bool, Never> = addresses
            .flatMap { addresses -> AnyPublisher<Bool, Never> in
                guard addresses.isNotEmpty else {
                    return .just(false)
                }

                return Publishers.Zip(
                    hasBalance(.bitcoin, addresses: addresses),
                    hasBalance(.bitcoinCash, addresses: addresses)
                )
                .map { $0 || $1 }
                .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        let shouldDisplayAnnouncement = try await isEnabled.await()

        guard shouldDisplayAnnouncement else {
            return []
        }

        let announcements = try await announcement
            .flatMap { [app] shouldSweep -> AnyPublisher<[Announcement], Never> in
                if shouldSweep {
                    return .just([Announcement.sweep])
                } else {
                    let skip = (try? app.state.get(blockchain.ui.device.sweep.did.show.message, as: Bool.self)) ?? false
                    if skip {
                        return .just([])
                    } else {
                        app.state.set(blockchain.ui.device.sweep.did.show.message, to: true)
                        return .just([Announcement.updated])
                    }
                }
            }
            .await()

        return announcements
    }
    
    public func setRead(announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }
    
    public func setTapped(announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }
    
    public func setDismissed(_ announcement: FeatureAnnouncementsDomain.Announcement, with action: FeatureAnnouncementsDomain.Announcement.Action) -> AnyPublisher<Void, Errors.NabuNetworkError> {
        .just(())
    }
    
    public func handle(_ announcement: FeatureAnnouncementsDomain.Announcement) -> AnyPublisher<Void, Never> {
        guard announcement == Announcement.sweep else {
            return .just(())
        }

        // TODO: launch internal flow @Dimitrios
        app.post(
            event: blockchain.ux.dashboard.announcements.open.paragraph.button.primary.tap.then.launch.url,
            context: [
                blockchain.ui.type.action.then.launch.url: announcement.content.actionUrl
            ]
        )

        return .just(())
    }
}

private func hasBalance(
    _ currency: BitcoinChainCoin,
    addresses: [String]
) -> AnyPublisher<Bool, Never> {
    let fetcher: FetchMultiAddressFor = resolve(tag: currency)
    return fetcher(
        addresses
            .map {
                XPub(address: $0, derivationType: .legacy)
            }
    )
    .retry(max: 5, delay: .seconds(5), scheduler: DispatchQueue.global(qos: .background))
    .map { response in
        response
            .addresses
            .map { address in
                CryptoValue
                    .create(minor: address.finalBalance, currency: currency.cryptoCurrency)
                    .storeAmount
                > currency.dust
            }
            .filter { $0 }
            .isNotEmpty
    }
    .catch { _ in false }
    .eraseToAnyPublisher()
}

extension Announcement {

    static let sweep: Announcement = Announcement(
        id: "internal-sweep",
        createdAt: .now,
        content: Announcement.Content(
            title: LocalizationConstants.Announcements.Sweep.Prompt.title,
            description: LocalizationConstants.Announcements.Sweep.Prompt.message,
            icon: Icon.alert.color(.semantic.error).medium(),
            actionUrl: "https://login.blockchain.com/",
            appMode: .universal
        ),
        priority: 42,
        read: false,
        expiresAt: Date(timeIntervalSinceNow: .years(1))
    )

    static let updated = Announcement(
        id: "internal-updated",
        createdAt: .now,
        content: Announcement.Content(
            title: LocalizationConstants.Announcements.Sweep.Updated.title,
            description: LocalizationConstants.Announcements.Sweep.Updated.message,
            icon: Icon.checkCircle.color(.semantic.success).medium(),
            actionUrl: "",
            appMode: .universal
        ),
        priority: 42,
        read: false,
        expiresAt: Date(timeIntervalSinceNow: .years(1))
    )
}
