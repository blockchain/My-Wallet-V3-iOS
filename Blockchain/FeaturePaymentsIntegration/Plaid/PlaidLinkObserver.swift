import BlockchainNamespace
import Combine
import DIKit
import FeaturePlaidUI
import LinkKit
import PlatformKit
import SwiftUI
import UIComponentsKit
import UIKit

/// Handles openning LinkKit (Plaid) SDK with a token for:
/// - (A) linking a new bank
/// - (B) updating credentials for an already linked bank
/// - (C) migrating a bank linked with another partner to Plaid
///
/// Opens the SDK, gets credentials, sends to Plaid and once it gets the public token
/// and account id back from Plaid it posts to our BE.
///
/// Use cases B and C have the same logic.
///

public final class PlaidLinkObserver: Client.Observer {
    unowned let app: AppProtocol
    private var handler: LinkKit.Handler?
    private let topViewController: TopMostViewControllerProviding
    private let linkedBankService: LinkedBanksServiceAPI
    private let beneficiariesService: BeneficiariesServiceAPI

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        linkedBankService: LinkedBanksServiceAPI = DIKit.resolve(),
        beneficiariesService: BeneficiariesServiceAPI = DIKit.resolve(),
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.linkedBankService = linkedBankService
        self.beneficiariesService = beneficiariesService
        self.topViewController = topViewController
    }

    var observers: [AnyCancellable] {
        [
            linkTokenReiceived,
            oauthTokenReceived,
            accountRequiresUpdateReceived,
            reloadLinkedBanksReceived
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
        app.state.set(
            blockchain.ux.payment.method.plaid.is.available,
            to: { [app] in
                let country = try? app.state.get(blockchain.user.address.country.code, as: String.self)
                guard let country, country == "US" else { return false }
                return app.remoteConfiguration.yes(if: blockchain.ux.payment.method.plaid.is.enabled)
            }
        )
    }

    public func stop() {
        cancellables = []
    }

    private lazy var linkTokenReiceived = app.on(
        blockchain.ux.payment.method.plaid.event.receive.link.token
    )
    .receive(on: DispatchQueue.main)
    .sink(to: PlaidLinkObserver.presentLinkToken(_:), on: self)

    private lazy var oauthTokenReceived = app.on(
        blockchain.ux.payment.method.plaid.event.receive.OAuth.token
    )
    .receive(on: DispatchQueue.main)
    .sink(to: PlaidLinkObserver.handlePlaidOauthToken(_:), on: self)

    private lazy var accountRequiresUpdateReceived = app.on(
        blockchain.ux.payment.method.plaid.event.update.account_id
    )
    .receive(on: DispatchQueue.main)
    .sink(to: PlaidLinkObserver.presentUpdateFlow(_:), on: self)

    private lazy var reloadLinkedBanksReceived = app.on(
        blockchain.ux.payment.method.plaid.event.reload.linked_banks
    )
    .receive(on: DispatchQueue.main)
    .sink(to: PlaidLinkObserver.reloadLinkedBanks, on: self)

    func reloadLinkedBanks() {
        linkedBankService.invalidate()
        beneficiariesService.invalidate()
    }

    func presentLinkToken(_ event: Session.Event) {
        guard let token = try? event.context.decode(
            blockchain.ux.payment.method.plaid.event.receive.link.token,
            as: String.self
        ) else { return }

        startWith(token)
    }

    func presentUpdateFlow(_ event: Session.Event) {
        guard let accountId = try? event.context.decode(
            blockchain.ux.payment.method.plaid.event.update.account_id,
            as: String.self
        ) else { return }

        // Dismiss any error popup before starting the Plaid flow
        app.post(event: blockchain.ux.error.then.close)
        startPlaidLinking(accountId)
    }

    func handlePlaidOauthToken(_ event: Session.Event) {
        guard let token = try? event.context.decode(
            blockchain.ux.payment.method.plaid.event.receive.OAuth.token,
            as: String.self
        ) else { return }

        if let url = URL(string: token) {
            handler?.continue(from: url)
        }
    }

    private func startPlaidLinking(_ accountId: String? = nil) {
        let presentingViewController = topViewController.topMostViewController

        let view = PlaidView(store: .init(
            initialState: PlaidState(accountId: accountId),
            reducer: PlaidModule.reducer,
            environment: .init(
                app: app,
                mainQueue: .main,
                plaidRepository: DIKit.resolve(),
                dismissFlow: { _ in
                    presentingViewController?.dismiss(animated: true)
                }
            )
        )).app(app)

        let hostedViewController = UIHostingController(rootView: view)

        hostedViewController.isModalInPresentation = true
        presentingViewController?
            .present(hostedViewController, animated: true)
    }
}

extension PlaidLinkObserver {
    private func startWith(_ token: String) {
        guard let presentingViewController =
                topViewController.topMostViewController else { return }

        // Create Configuration
        // https://plaid.com/docs/link/ios/#create-a-configuration

        var configuration = LinkTokenConfiguration(
            token: token,
            onSuccess: { [weak self, app] linkSuccess in
                // https://plaid.com/docs/link/ios/#onsuccess

                self?.resetPlaidIsLinkingFlag()

                // Posts the public token and account id so they can be sent to our BE
                let publicToken = linkSuccess.publicToken
                guard let accountId: String = linkSuccess.metadata.accounts.first?.id else {
                    return
                }

                app.post(
                    event: blockchain.ux.payment.method.plaid.event.finished,
                    context: [
                        blockchain.ux.payment.method.plaid.event.receive.success.token: publicToken,
                        blockchain.ux.payment.method.plaid.event.receive.success.id: accountId
                    ]
                )
            }
        )

        configuration.noLoadingState = true

        // https://plaid.com/docs/link/ios/#onexit

        configuration.onExit = { [weak self, app] _ in
            self?.resetPlaidIsLinkingFlag()
            app.post(
                event: blockchain.ux.payment.method.plaid.event.finished
            )
        }

        // Create Handler
        // https://plaid.com/docs/link/ios/#create-a-handler

        let result = Plaid.create(configuration)
        switch result {
        case .failure(let error):
            debugPrint("Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            self.handler = handler
        }

        // Open Link SDK
        // https://plaid.com/docs/link/ios/#open-link

        let method: PresentationMethod = .custom(
            { [weak presentingViewController] viewController in
                presentingViewController?.present(viewController, animated: false)
            },
            { _ in } // Leave this empty to avoid the default dismiss, it will be dismissed by the PlaidReducer
        )

        if let handler {
            // Set is_linking flag to true so when the the user returns to the app after incerting the credentials
            // the flow continues instead of dealocating and showing the PIN screen
            app.state.set(
                blockchain.ux.payment.method.plaid.is.linking,
                to: true
            )
            handler.open(presentUsing: method)
        }
    }

    private func resetPlaidIsLinkingFlag() {
        // Reset the linking flag for when the app goes to Safari/Bank app to handle the credentials
        // Setting this to true avoid the app to dealocate everything and go back to the PIN screen
        // and allow us to continue the flow. Setting to false cleans the linking state and allows
        // for the PIN screen to be shown again.
        app.state.set(
            blockchain.ux.payment.method.plaid.is.linking,
            to: false
        )
    }
}
