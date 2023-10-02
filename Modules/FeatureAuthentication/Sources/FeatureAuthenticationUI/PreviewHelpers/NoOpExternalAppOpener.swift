// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpExternalAppOpener: ExternalAppOpener {
    func openMailApp(completionHandler: @escaping (Bool) -> Void) {}
    func openSettingsApp(completionHandler: @escaping (Bool) -> Void) {}
    func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {}
}
