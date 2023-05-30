// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import MoneyKit
import PlatformUIKit
import SwiftUI
import UIKit
import WalletConnectSwift

import struct MetadataKit.WalletConnectSession

final class WalletConnectRouter: WalletConnectRouterAPI {

    private var cancellables = [AnyCancellable]()
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let service: WalletConnectServiceAPI
    @LazyInject private var navigation: NavigationRouterAPI
    @LazyInject private var tabSwapping: TabSwapping

    init(
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        service: WalletConnectServiceAPI
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        self.service = service

        service.sessionEvents
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .didConnect(let session):
                    self?.didConnect(session: session)
                case .didDisconnect:
                    break
                case .didFailToConnect(let session):
                    self?.didFail(session: session)
                case .didUpdate:
                    break
                case .shouldStart(let session, let action):
                    self?.shouldStart(session: session, action: action)
                case .shouldChangeChainID(let session, let request, let network):
                    self?.shouldChangeChainID(session: session, request: request, network: network)
                }
            })
            .store(in: &cancellables)

        service.userEvents
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .signMessage(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .signTransaction(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .sendTransaction(let account, let target):
                    self?.tabSwapping.send(from: account, target: target)
                case .failure:
                    break // ignore for v1
                }
            })
            .store(in: &cancellables)
    }

    private func didFail(session: Session) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: service,
            router: self,
            analyticsEventRecorder: analyticsEventRecorder,
            onComplete: { _ in
                presenter?.dismiss(animated: true)
            }
        )
        let state = WalletConnectEventState(session: session, state: .fail)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom

        presenter?.present(controller, animated: true, completion: nil)
    }

    private func shouldChangeChainID(session: Session, request: Request, network: EVMNetwork) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: service,
            router: self,
            analyticsEventRecorder: analyticsEventRecorder,
            onComplete: { [service] approved in
                presenter?.dismiss(animated: true) {
                    service.respondToChainIDChangeRequest(
                        session: session,
                        request: request,
                        network: network,
                        approved: approved
                    )
                }
            }
        )
        let state = WalletConnectEventState(session: session, state: .chainID(name: network.networkConfig.name))
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom

        presenter?.present(controller, animated: true, completion: nil)
    }

    private func shouldStart(session: Session, action: @escaping (Session.WalletInfo) -> Void) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: service,
            router: self,
            analyticsEventRecorder: analyticsEventRecorder,
            onComplete: { [service, action] validate in
                presenter?.dismiss(animated: true) {
                    if validate {
                        service.acceptConnection(session: session, completion: action)
                    } else {
                        service.denyConnection(session: session, completion: action)
                    }
                }
            }
        )
        let state = WalletConnectEventState(session: session, state: .idle)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom

        presenter?.present(controller, animated: true, completion: nil)
    }

    private func didConnect(session: Session) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: service,
            router: self,
            analyticsEventRecorder: analyticsEventRecorder,
            onComplete: { _ in
                presenter?.dismiss(animated: true)
            }
        )
        let state = WalletConnectEventState(session: session, state: .success)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom

        presenter?.present(controller, animated: true, completion: nil)
    }

    func showConnectedDApps(_ completion: (() -> Void)?) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = DAppListEnvironment(
            mainQueue: .main,
            router: self,
            sessionRepository: resolve(),
            analyticsEventRecorder: analyticsEventRecorder,
            onComplete: { _ in
                completion?()
                presenter?.dismiss(animated: true)
            }
        )
        let state = DAppListState()
        let store = Store(initialState: state, reducer: dAppListReducer, environment: env)
        let controller = UIHostingController(rootView: DAppListView(store: store))
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom

        presenter?.present(controller, animated: true, completion: nil)
    }

    func showSessionDetails(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let walletConnectSession = session.session(address: ""),
                      let self
                else {
                    return
                }

                let presenter = self.navigation.topMostViewControllerProvider.topMostViewController
                let env = WalletConnectEventEnvironment(
                    mainQueue: .main,
                    service: self.service,
                    router: self,
                    analyticsEventRecorder: self.analyticsEventRecorder,
                    onComplete: { _ in
                        presenter?.dismiss(animated: true)
                        promise(.success(()))
                    }
                )

                let state = WalletConnectEventState(
                    session: walletConnectSession,
                    state: .details
                )
                let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
                let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
                controller.transitioningDelegate = self.sheetPresenter
                controller.modalPresentationStyle = .custom

                presenter?.present(controller, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }

    func openWebsite(for client: Session.ClientMeta) {
        UIApplication.shared.open(client.url)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: true)
}

#if DEBUG

final class MockWalletConnectRouter: WalletConnectRouterAPI {
    func showConnectedDApps(_ completion: (() -> Void)?) {}
    func showSessionDetails(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        .just(())
    }

    func openWebsite(for client: Session.ClientMeta) {}
}

final class MockAnalyticsRecorder: AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvent) {}
}

#endif
