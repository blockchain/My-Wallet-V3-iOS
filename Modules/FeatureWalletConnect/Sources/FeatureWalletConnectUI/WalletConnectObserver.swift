// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import MoneyKit
import PlatformUIKit
import SwiftUI
import UIKit
import WalletConnectRouter
import Web3Wallet

enum WalletConnectGenericError: Error {
    case unableToDecodeProposal
    case unableToDecodeAuthRequest
}

public final class WalletConnectObserver {

    private var lifetimeBag: Set<AnyCancellable> = []
    private var bag: Set<AnyCancellable> = []

    private let app: AppProtocol
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let service: WalletConnectServiceV2API

    @LazyInject private var tabSwapping: TabSwapping

    init(
        app: AppProtocol,
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        service: WalletConnectServiceV2API
    ) {
        self.app = app
        self.analyticsEventRecorder = analyticsEventRecorder
        self.service = service

        app.publisher(for: blockchain.user.id)
            .map(\.value.isNotNil)
            .combineLatest(app.publisher(for: blockchain.app.configuration.wallet.connect.is.enabled, as: Bool.self).map(\.value))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signedIn, isEnabled in
                guard let isEnabled else {
                    self?.bag = []
                    return
                }
                if signedIn, isEnabled {
                    self?.setup()
                } else {
                    self?.bag = []
                }
            }
            .store(in: &lifetimeBag)
    }

    private func setup() {
        service.sessionEvents
            .sink { [weak self] event in
                self?.handleSessionEvents(event)
            }
            .store(in: &bag)

        service.userEvents
            .sink { [weak self, app] event in
                switch event {
                case .signMessage(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .signTransaction(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .sendTransaction(let account, let target):
                    self?.tabSwapping.send(from: account, target: target)
                case .authRequest(let request):
                    app.post(
                        action: blockchain.ux.wallet.connect.auth.request.then.enter.into,
                        value: blockchain.ux.wallet.connect.auth.request,
                        context: [
                            blockchain.ux.wallet.connect.auth.request.payload: request,
                            blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                            blockchain.ui.type.action.then.enter.into.detents: [
                                blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                            ]
                        ]
                    )
                case .failure(let message, let metadata):
                    displayErrorSheet(
                        app: app,
                        message: message,
                        metadata: metadata
                    )
                case .authFailure(let error, let domain):
                    displayErrorSheet(
                        app: app,
                        message: error.localizedDescription,
                        metadata: AppMetadata(
                            name: domain,
                            description: "",
                            url: "",
                            icons: []
                        )
                    )
                }
            }
            .store(in: &bag)

        // Redirect to dApp if needed after the use has closed the tx flow
        app.on(blockchain.ux.transaction.event.did.finish, priority: .userInitiated) { [app] _ in
            try await routeBackToDappIfNeeded(app: app)
        }
        .store(in: &bag)

        setupObservers()
        setupAuthObservers()
    }

    private func setupObservers() {
        app.on(blockchain.ux.wallet.connect.pair.request.accept)
            .sink { [app, service] event in
                guard let proposal = try? event.context.decode(
                    blockchain.ux.wallet.connect.pair.request.proposal,
                    as: WalletConnectProposal.self
                ) else {
                    clearRouteToDappState(app: app)
                    app.post(error: WalletConnectGenericError.unableToDecodeProposal)
                    return
                }
                Task(priority: .userInitiated) { [service, app] in
                    do {
                        try await service.approve(proposal: proposal.proposal)
                    } catch {
                        clearRouteToDappState(app: app)
                        app.post(error: error)
                        app.post(event: blockchain.ui.type.action.then.close)
                        displayErrorSheet(
                            app: app,
                            message: error.localizedDescription,
                            metadata: proposal.proposal.proposer
                        )
                    }
                }
            }
            .store(in: &bag)

        app.on(blockchain.ux.wallet.connect.pair.request.declined)
            .sink { [app, service] event in
                clearRouteToDappState(app: app)
                guard let proposal = try? event.context.decode(
                    blockchain.ux.wallet.connect.pair.request.proposal,
                    as: WalletConnectProposal.self
                ) else {
                    app.post(error: WalletConnectGenericError.unableToDecodeProposal)
                    return
                }
                Task(priority: .userInitiated) {
                    do {
                        try await service.reject(proposal: proposal.proposal)
                        app.post(event: blockchain.ui.type.action.then.close)
                    } catch {
                        app.post(error: error)
                        app.post(event: blockchain.ui.type.action.then.close)
                        displayErrorSheet(
                            app: app,
                            message: error.localizedDescription,
                            metadata: proposal.proposal.proposer
                        )
                    }
                }
            }
            .store(in: &bag)
    }

    private func setupAuthObservers() {
        app.on(blockchain.ux.wallet.connect.auth.approve, priority: .userInitiated) { [app, service] event in
            guard let request = try? event.context.decode(
                blockchain.ux.wallet.connect.auth.request.payload,
                as: AuthRequest.self
            ) else {
                app.post(error: WalletConnectGenericError.unableToDecodeAuthRequest)
                return
            }
            do {
                try await service.authApprove(request: request)
                app.post(event: blockchain.ux.wallet.connect.auth.request.approved)
                app.post(event: blockchain.ui.type.action.then.close)
            } catch {
                app.post(error: error)
                app.post(event: blockchain.ui.type.action.then.close)
                displayErrorSheet(
                    app: app,
                    message: error.localizedDescription,
                    metadata: .init(name: request.payload.domain, description: "", url: "", icons: [])
                )
            }
        }
        .store(in: &bag)

        app.on(blockchain.ux.wallet.connect.auth.reject, priority: .userInitiated) { [app, service] event in
            guard let request = try? event.context.decode(
                blockchain.ux.wallet.connect.auth.request.payload,
                as: AuthRequest.self
            ) else {
                app.post(error: WalletConnectGenericError.unableToDecodeAuthRequest)
                return
            }
            do {
                try await service.authReject(request: request)
            } catch {
                app.post(error: error)
                displayErrorSheet(
                    app: app,
                    message: error.localizedDescription,
                    metadata: .init(name: request.payload.domain, description: "", url: "", icons: [])
                )
            }
        }
        .store(in: &bag)
    }

    private func handleSessionEvents(_ event: SessionV2Event) {
        switch event {
        case .pairRequest(let sessionProposal):
            app.post(
                action: blockchain.ux.wallet.connect.pair.request.then.enter.into,
                value: blockchain.ux.wallet.connect.pair.request,
                context: [
                    blockchain.ux.wallet.connect.pair.request.proposal: sessionProposal,
                    blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                    blockchain.ui.type.action.then.enter.into.detents: [
                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                    ]
                ]
            )
        case .pairSettled(let session):
            app.post(event: blockchain.ui.type.action.then.close)
            Task(priority: .userInitiated) {
                // in case the connection was originated from a deeplink we automatically redirect to the dApp
                // and skip the success screen
                if try await app.get(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp) {
                    Router.goBack()
                    clearRouteToDappState(app: app)
                } else {
                    app.post(
                        action: blockchain.ux.wallet.connect.pair.settled.then.enter.into,
                        value: blockchain.ux.wallet.connect.pair.settled,
                        context: [
                            blockchain.ux.wallet.connect.pair.settled.session: session,
                            blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                            blockchain.ui.type.action.then.enter.into.detents: [
                                blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                            ]
                        ]
                    )
                }
            }
        case .failure(let message, let metadata):
            analyticsEventRecorder.record(
                event: AnalyticsWalletConnect.dappConnectionRejected(appName: metadata.name))
            displayErrorSheet(
                app: app,
                message: message,
                metadata: metadata
            )
        }
    }
}

private func routeBackToDappIfNeeded(app: AppProtocol) async throws {
    if try await app.get(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp) {
        Router.goBack()
        app.state.clear(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp)
    }
}

private func clearRouteToDappState(app: AppProtocol) {
    app.state.clear(blockchain.app.deep_link.walletconnect.redirect.back.to.dapp)
}

private func displayErrorSheet(app: AppProtocol, message: String?, metadata: AppMetadata?) {
    app.post(
        action: blockchain.ux.wallet.connect.failure.then.enter.into,
        value: blockchain.ux.wallet.connect.failure,
        context: [
            blockchain.ux.wallet.connect.failure.message: message,
            blockchain.ux.wallet.connect.failure.metadata: metadata,
            blockchain.ui.type.action.then.enter.into.grabber.visible: true,
            blockchain.ui.type.action.then.enter.into.detents: [
                blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
            ]
        ]
    )
}
