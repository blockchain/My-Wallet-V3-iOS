// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct RecoveryPhraseWord: Identifiable, Equatable, Hashable {
    public init(label: String) {
        self.label = label
    }

    public var id: String = UUID().uuidString
    public var label: String
}

extension [RecoveryPhraseWord] {
    public var recoveryPhrase: String {
        map(\.label).joined(separator: " ")
    }
}
