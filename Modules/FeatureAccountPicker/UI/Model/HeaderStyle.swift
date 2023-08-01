// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import SwiftUI

public enum HeaderStyle: Equatable {
    case none
    case simple(
        subtitle: String?,
        searchable: Bool,
        switchable: Bool,
        switchTitle: String?
    )
    case normal(
        title: String,
        subtitle: String?,
        image: ImageResource?,
        tableTitle: String?,
        searchable: Bool
    )
}
