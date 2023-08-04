import BlockchainNamespace
import Combine

/// Allow places where `AppProtocol` is not available or reachable to post an error event
///
/// At call site you'd do the following
/// ```
/// NotificationCenter.default.post(
///     name: NSNotification.Name(rawValue: "error.notification"),
///     object: nil,
///     userInfo: [
///         "error": AnError.someError
///     ]
/// )
/// ```
/// Note: The object passed to `error` should conform to `Error` protocol
final class AppNotificationCenterObservation: Client.Observer {

    let app: AppProtocol
    var bag: Set<AnyCancellable> = []

    init(app: AppProtocol) {
        self.app = app
    }

    func start() {
        NotificationCenter.default.publisher(for: Notification.Name("error.notification"))
            .sink { [app] notification in
                if let error = notification.userInfo?["error"] as? Error {
                    app.post(error: error)
                }
            }
            .store(in: &bag)
    }

    func stop() {
        bag = []
    }
}
