// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

public enum ImageAsset: String {
    case iconSend = "icon_send"
    case iconReceive = "icon_receive"
    case emptyActivity = "empty_activity"
    case linkPattern = "link-pattern"

    public var imageResource: ImageLocation {
        .local(name: rawValue, bundle: .UIComponents)
    }
}
