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
import Web3Wallet

enum WalletConnectGenericError: Error {
    case unableToDecodeProposal
}

public final class WalletConnectObserver {

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
                case .failure(let message, let metadata):
                    displayErrorSheet(
                        app: app,
                        message: message,
                        metadata: metadata
                    )
                }
            }
            .store(in: &bag)

        setupObservers()
    }

    private func setupObservers() {
        app.on(blockchain.ux.wallet.connect.pair.request.accept)
            .sink { [app, service] event in
                guard let proposal = try? event.context.decode(
                    blockchain.ux.wallet.connect.pair.request.proposal,
                    as: WalletConnectProposal.self
                ) else {
                    app.post(error: WalletConnectGenericError.unableToDecodeProposal)
                    return
                }
                Task(priority: .userInitiated) { [service, app] in
                    do {
                        try await service.approve(proposal: proposal.proposal)
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

        app.on(blockchain.ux.wallet.connect.pair.request.declined)
            .sink { [app, service] event in
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
        case .failure(let message, let metadata):
            displayErrorSheet(
                app: app,
                message: message,
                metadata: metadata
            )
        }
    }
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
