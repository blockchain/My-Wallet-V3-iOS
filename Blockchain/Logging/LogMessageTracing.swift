// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseCrashlytics
import Foundation
import ObservabilityKit
import ToolKit

extension LogMessageTracing {
    public static func live(
        loggers: [LogMessageServiceAPI]
    ) -> LogMessageServiceAPI {
        LogMessageTracing.service(
            loggers: loggers
        )
    }

    static func provideLoggers() -> [LogMessageServiceAPI] {
    #if DEBUG || INTERNAL_BUILD
        return [
            LocalLogMessaging()
        ]
    #else
        return [
            CrashlyticsLogMessaging(client: CrashlyticsRecorder())
        ]
    #endif
    }
}

// MARK: - Services

final class LocalLogMessaging: LogMessageServiceAPI {
    func logError(message: String, properties: [String: String]?) {
        message.peek(as: .error)
        properties?.peek(as: .error)
    }

    func logError(error: Error, properties: [String: String]?) {
        error.localizedDescription.peek(as: .error)
        properties?.peek(as: .error)
    }

    func logWarning(message: String, properties: [String: String]?) {
        message.peek(as: .debug)
        properties?.peek(as: .debug)
    }

    func logInfo(message: String, properties: [String: String]?) {
        message.peek(as: .info)
        properties?.peek(as: .info)
    }
}

final class CrashlyticsLogMessaging: LogMessageServiceAPI {

    enum LogError: Error {
        case failure(String)
    }

    private let client: Recording

    init(client: Recording) {
        self.client = client
    }

    func logError(error: Error, properties: [String: String]?) {
        client.error(error)
    }

    func logError(message: String, properties: [String: String]?) {
        client.error(LogError.failure(message))
    }

    func logWarning(message: String, properties: [String: String]?) {
        client.record("[Warning]: \(message)")
    }

    func logInfo(message: String, properties: [String: String]?) {
        client.record("[Info]: \(message)")
    }
}
