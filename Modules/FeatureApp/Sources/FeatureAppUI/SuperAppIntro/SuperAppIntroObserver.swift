// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureBackupRecoveryPhraseUI
import FeatureSuperAppIntroUI
import Foundation
import Localization
import SwiftUI
import UIComponentsKit

public final class SuperAppIntroObserver: Client.Observer {
    unowned let app: AppProtocol
    let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
    }

    var observers: [AnyCancellable] {
        [
            userDidSignIn,
            userDidSignOut,
            tradingTutorial,
            deFiTutorial
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
    }

    public func stop() {
        cancellables = []
    }

    lazy var userDidSignIn = Publishers.Merge3(
        app.on(blockchain.session.event.did.sign.in),
        app.on(blockchain.ux.onboarding.intro.event.show.sign.up),
        app.on(blockchain.ux.onboarding.intro.event.show.sign.in)
    )
        .receive(on: DispatchQueue.main)
        .sink(to: SuperAppIntroObserver.showSuperAppIntro(_:), on: self)

    lazy var userDidSignOut = app.on(blockchain.session.event.did.sign.out)
        .receive(on: DispatchQueue.main)
        .sink(to: SuperAppIntroObserver.reset, on: self)

    lazy var tradingTutorial = app.on(blockchain.ux.onboarding.intro.event.show.tutorial.trading)
        .receive(on: DispatchQueue.main)
        .map { _ -> FeatureSuperAppIntro.State.Flow in
            .tradingFirst
        }
        .sink(to: SuperAppIntroObserver.presentSuperAppIntro, on: self)

    lazy var deFiTutorial = app.on(blockchain.ux.onboarding.intro.event.show.tutorial.defi)
        .receive(on: DispatchQueue.main)
        .map { _ -> FeatureSuperAppIntro.State.Flow in
            .defiFirst
        }
        .sink(to: SuperAppIntroObserver.presentSuperAppIntro, on: self)

    func showSuperAppIntro(_ event: Session.Event) {
        Task {
            let appMode: AppMode? = try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self)
            let pkwOnly = appMode == AppMode.pkw

            let introDidShow = await app.get(blockchain.ux.onboarding.intro.did.show, as: Bool.self, or: false)

            let userDidSignUp = event.tag == blockchain.ux.onboarding.intro.event.show.sign.up[]

            let userDidSignIn = event.tag == blockchain.ux.onboarding.intro.event.show.sign.in[]

            guard !introDidShow, !pkwOnly else {
                return
            }

            if userDidSignUp {
                app.state.set(blockchain.ux.onboarding.intro.did.show, to: true)

                await MainActor.run {
                    self.presentSuperAppIntro(.newUser)
                }
            } else if userDidSignIn {
                app.state.set(blockchain.ux.onboarding.intro.did.show, to: true)

                await MainActor.run {
                    self.presentSuperAppIntro(.existingUser)
                }
            }
        }
    }

    func reset() {
        app.state.set(blockchain.ux.onboarding.intro.did.show, to: false)
    }

    func presentSuperAppIntro(_ flow: FeatureSuperAppIntro.State.Flow) {
        let pkwOnly = (try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self) == AppMode.pkw) ?? false
        let intro = IntroView(flow, pkwOnly: pkwOnly)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.topViewController.topMostViewController?.present(
                intro,
                inNavigationController: false,
                modalPresentationStyle: UIModalPresentationStyle.fullScreen
            )
        }
    }

    private func dismissView() {
        topViewController.topMostViewController?.dismiss(animated: true)
    }
}

extension IntroView {
    init(_ flow: FeatureSuperAppIntro.State.Flow, pkwOnly: Bool) {
        switch flow {
        case .defiFirst:
            self.init(.pkw, actionTitle: LocalizationConstants.okString)
        case .tradingFirst:
            self.init(.trading, actionTitle: LocalizationConstants.okString)
        default:
            if pkwOnly {
                self.init(.pkw)
            } else {
                self.init(.trading)
            }
        }
    }
}
