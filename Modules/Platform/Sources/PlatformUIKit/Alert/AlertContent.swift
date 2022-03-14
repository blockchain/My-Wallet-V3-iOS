// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AlertViewContent: Equatable {

    public typealias Action = (UIAlertAction) -> Void

    public let title: String
    public let message: String
    public let actions: [UIAlertAction]

    public init(title: String, message: String, actions: [UIAlertAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}
