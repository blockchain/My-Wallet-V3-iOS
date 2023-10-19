// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseCrashlytics
import Foundation
import PlatformKit
import ToolKit

/// Crashlytics implementation of `Recording`. Should be injected as a service.
final class CrashlyticsRecorder: Recording {

    // MARK: - Properties

    private let crashlytics: Crashlytics

    // MARK: - Setup

    init(crashlytics: Crashlytics = Crashlytics.crashlytics()) {
        self.crashlytics = crashlytics
    }

    // MARK: - ErrorRecording

    /// Records error using Crashlytics.
    /// If the only necessary recording data is the context, just call `error()` with no `error` parameter.
    /// - Parameter error: The error to be recorded by the crash service. defaults to `BreadcrumbError` instance.
    func error(_ error: Error) {
        let userInfo: [String: Any] = [
            "description": String(describing: error),
            "localizedDescription": String(describing: error)
        ]
        let prettyError = NSError(domain: domain(for: error), code: 0, userInfo: userInfo)
        crashlytics.record(error: prettyError)
    }

    /// From the assumption that the error is a enumeration, return its case 'name' by parsing its description.
    /// e.g. For an given `Error.nameOfTheError(params ...)` returns `nameOfTheError`
    private func errorName(for error: Error) -> String {
        let description = String(describing: error)
        guard let name = description.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true).first else {
            return ""
        }
        return String(name)
    }

    /// Sets the user id on Crashlytics.
    func setUserId(for id: String) {
        crashlytics.setUserID(id)
    }

    /// For a given error, returns the string reflection of its type plus its name. Differs from the default NSError.domain because it won't contain
    ///  any memory address and also has the error name.
    /// e.g. for an Error `Error.nameOfTheError(params ...)` nested inside a class `Class` in a framework
    /// `Framework` returns `Framework.Class.Error.nameOfTheError`.
    private func domain(for error: Error) -> String {
        String(reflecting: type(of: error))
            .components(separatedBy: ".")
            .filter { component in
                !component.contains("unknown context at $")
            }
            .joined(separator: ".")
            .appending("." + errorName(for: error))
    }

    // MARK: - MessageRecording

    /// Records any type of message.
    /// - Parameter message: The message to be recorded by the crash service. defaults to an empty string.
    func record(_ message: String) {
        crashlytics.log(message)
    }

    // MARK: - UIOperationRecording

    /// Should be called if there is a suspicion that a UI action is performed on a background thread.
    /// In such case, a non-fatal error will be recorded.
    func recordIllegalUIOperationIfNeeded() {
        guard !Thread.isMainThread else {
            return
        }

        error(UIOperationError.changingUIOnBackgroundThread)
    }
}
