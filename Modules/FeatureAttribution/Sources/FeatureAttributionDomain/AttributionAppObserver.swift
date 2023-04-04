// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation

public final class AttributionAppObserver: Client.Observer {
    let app: AppProtocol
    let attributionService: AttributionServiceAPI
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        attributionService: AttributionServiceAPI
    ) {
        self.app = app
        self.attributionService = attributionService
    }

    var observers: [BlockchainEventSubscription] {
        [
            appDidFinishLaunching,
            signIn
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var appDidFinishLaunching = app.on(blockchain.app.did.finish.launching) { [weak self] _ in
        self?.attributionService.registerForAttribution()
    }

    lazy var signIn = app.on(blockchain.session.event.did.sign.in) { [weak self] _ in
        guard let self else { return }
        attributionService
            .startUpdatingConversionValues()
            .sink(receiveValue: {})
            .store(in: &cancellables)
    }
}
