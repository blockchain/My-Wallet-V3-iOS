// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Network

final class Reachability {

    private let monitor: NWPathMonitor
    private let logger: ((String) -> Void)?

    init(
        monitor: NWPathMonitor = .init(),
        logger: ((String) -> Void)? = { $0.peek("🌎") }
    ) {
        self.monitor = monitor
        self.logger = logger
        monitor.pathUpdateHandler = { path in
            logger?("Reachability: \(path.status).")
        }
        monitor.start(queue: DispatchQueue.global(qos: .default))
    }

    deinit {
        logger?("Reachability: Cancel.")
        monitor.cancel()
    }

    var hasInternetConnection: Bool {
#if TARGET_OS_SIMULATOR
        true
#else
        monitor.currentPath.status != .unsatisfied
#endif
    }
}
