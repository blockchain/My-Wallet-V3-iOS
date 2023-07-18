// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Network

final class Reachability {

    private let monitor: NWPathMonitor
    private let logger: ((String) -> Void)?

    init(
        monitor: NWPathMonitor = .init(),
        queue: DispatchQueue = DispatchQueue.global(qos: .default),
        logger: ((String) -> Void)? = { $0.peek("🌎") }
    ) {
        self.monitor = monitor
        self.logger = logger
        monitor.pathUpdateHandler = { path in
            logger?("Reachability: \(path.status).")
        }
        monitor.start(queue: queue)
    }

    deinit {
        logger?("Reachability: Cancel.")
        monitor.cancel()
    }

    var hasInternetConnection: Bool {
        isSimulator || monitor.currentPath.status != .unsatisfied
    }

    private var isSimulator: Bool {
        var value: Bool = false
#if targetEnvironment(simulator)
        value = true
        logger?("Reachability: targetEnvironment(simulator).")
#endif
        return value
    }
}
