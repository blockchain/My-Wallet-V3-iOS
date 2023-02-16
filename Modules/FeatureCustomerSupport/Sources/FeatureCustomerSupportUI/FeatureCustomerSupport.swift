import BlockchainNamespace
import Combine
import Extensions
import Foundation

public final class CustomerSupportObserver<Intercom: Intercom_p>: Client.Observer {

    unowned let app: AppProtocol
    let notificationCenter: NotificationCenter
    let scheduler: AnySchedulerOf<DispatchQueue>

    let apiKey: String
    let appId: String
    let open: (URL) -> Void
    let unreadNotificationName: NSNotification.Name
    let sdk: Intercom.Type

    private var url = URL(string: "https://support.blockchain.com")!

    public init(
        app: AppProtocol,
        notificationCenter: NotificationCenter = .default,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        apiKey: String,
        appId: String,
        open: @escaping (URL) -> Void,
        unreadNotificationName: NSNotification.Name,
        intercom: Intercom.Type = Intercom.self
    ) {
        self.app = app
        self.notificationCenter = notificationCenter
        self.scheduler = scheduler
        self.apiKey = apiKey
        self.appId = appId
        self.open = open
        self.unreadNotificationName = unreadNotificationName
        self.sdk = intercom
    }

    private var bag: Set<AnyCancellable> = []

    public func start() {

        sdk.setApiKey(apiKey, forAppId: appId)

        app.on(blockchain.session.event.did.sign.in)
            .flatMap { [app] _ -> AnyPublisher<(String, String), Never> in
                app.publisher(for: blockchain.user.id, as: String.self)
                    .compactMap(\.value)
                    .zip(app.state.publisher(for: blockchain.user.email.address).decode().compactMap(\.value))
                    .first()
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { [weak self] id, email in self?.login(id: id, email: email) }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.out)
            .receive(on: scheduler)
            .sink { [weak self] _ in self?.logout() }
            .store(in: &bag)

        app.on(blockchain.ux.customer.support.show.messenger)
            .flatMap { [app] _ -> AnyPublisher<Bool, Never> in
                app.publisher(for: blockchain.app.configuration.customer.support.is.enabled, as: Bool.self)
                    .replaceError(with: false)
                    .first()
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { [weak self] isEnabled in self?.showMessenger(isEnabled) }
            .store(in: &bag)

        app.on(blockchain.ux.customer.support.show.help.center)
            .flatMap { [app] _ -> AnyPublisher<Bool, Never> in
                app.publisher(for: blockchain.app.configuration.customer.support.is.enabled, as: Bool.self)
                    .replaceError(with: false)
                    .first()
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .sink { [weak self] isEnabled in self?.showHelpCenter(isEnabled) }
            .store(in: &bag)

        app.publisher(for: blockchain.app.configuration.customer.support.url, as: URL.self)
            .compactMap(\.value)
            .receive(on: scheduler)
            .sink { [weak self] url in self?.url = url }
            .store(in: &bag)

        notificationCenter.publisher(for: unreadNotificationName)
            .sink { [app] _ in
                app.state.set(blockchain.ux.customer.support.unread.count, to: Int(Intercom.unreadConversationCount()))
            }
            .store(in: &bag)
    }

    public func stop() {
        bag.removeAll()
    }

    private func login(id: String, email: String) {
        let attributes = Intercom.UserAttributes()
        attributes.userId = id
        attributes.email = email
        attributes.languageOverride = Locale.preferredLanguages.first
        sdk.loginUser(with: attributes) { [app] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                app.post(error: error)
            }
        }
    }

    private func logout() {
        sdk.logout()
    }

    private func showMessenger(_ isEnabled: Bool) {
        if isEnabled {
            sdk.showMessenger()
        } else {
            open(url)
        }
    }

    private func showHelpCenter(_ isEnabled: Bool) {
        if isEnabled {
            sdk.showHelpCenter()
        } else {
            open(url)
        }
    }
}
