// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Errors
import Foundation
import SwiftUI

public struct SettingsSiteMap {
    struct Error: LocalizedError {
        let message: String
        let tag: Tag.Reference
        let context: Tag.Context

        var errorDescription: String? {
            "\(tag.string): \(message)"
        }
    }

    public init() { }

    @MainActor
    @ViewBuilder
    public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.settings.theme.settings:
            ThemeSettingsView()
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}
