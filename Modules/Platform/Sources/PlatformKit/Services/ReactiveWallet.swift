// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxRelay
import RxSwift
import ToolKit
import WalletPayloadKit

/// An extension to `Wallet` which makes wallet functionality Rx friendly.
final class ReactiveWallet: ReactiveWalletAPI {

    // MARK: - Types

    private enum WalletAndMetadataState {

        struct PartialState {
            let walletInitialized: Bool
            let metadataLoaded: Bool

            init(walletInitialized: Bool = false, metadataLoaded: Bool = false) {
                self.walletInitialized = walletInitialized
                self.metadataLoaded = metadataLoaded
            }
        }

        case uninitialized
        case partiallyInitialised(PartialState)
        case initialized

        var isInitialized: Bool {
            guard case .initialized = self else {
                return false
            }
            return true
        }

        mutating func setWalletInitialised() -> Bool {
            switch self {
            case .uninitialized:
                self = .partiallyInitialised(.init(walletInitialized: true))
            case .partiallyInitialised(let state) where state.metadataLoaded:
                self = .initialized
                return true
            default:
                break
            }
            return false
        }

        mutating func setMetadataLoaded() -> Bool {
            switch self {
            case .uninitialized:
                self = .partiallyInitialised(.init(walletInitialized: true))
            case .partiallyInitialised(let state) where state.walletInitialized:
                self = .initialized
                return true
            default:
                break
            }
            return false
        }

        mutating func setUninitialized() {
            self = .uninitialized
        }
    }

    // MARK: - Properties

    var waitUntilInitialized: AnyPublisher<Void, Never> {
        waitUntilInitializedPublisher
            .share()
            .eraseToAnyPublisher()
    }

    var waitUntilInitializedFirst: AnyPublisher<Void, Never> {
        waitUntilInitializedPublisher
            .first()
            .eraseToAnyPublisher()
    }

    var initializationState: AnyPublisher<WalletSetup.State, Never> {
        stateSubject
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var waitUntilInitializedPublisher: AnyPublisher<Void, Never> {
        stateSubject
            .filter { state -> Bool in
                state == .initialized
            }
            .subscribe(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
            .mapToVoid()
    }

    private let stateSubject = CurrentValueSubject<WalletSetup.State, Never>(.uninitialized)

    private let walletAndMetadataState = Atomic<WalletAndMetadataState>(.uninitialized)

    // MARK: - Init

    init() {
        NotificationCenter.when(.walletInitialized) { [weak self] _ in
            guard let self else { return }

            walletAndMetadataState.mutate { state in
                if state.setWalletInitialised() {
                    self.setInitialized()
                }
            }
        }

        NotificationCenter.when(.walletMetadataLoaded) { [weak self] _ in
            guard let self else { return }

            walletAndMetadataState.mutate { state in
                if state.setMetadataLoaded() {
                    self.setInitialized()
                }
            }
        }

        NotificationCenter.when(.logout) { [weak self] _ in
            self?.resetState()
        }
    }

    // MARK: - Private methods

    private func setInitialized() {
        stateSubject.send(.initialized)
    }

    private func resetState() {
        walletAndMetadataState.mutate { $0.setUninitialized() }
        stateSubject.send(.uninitialized)
    }
}
