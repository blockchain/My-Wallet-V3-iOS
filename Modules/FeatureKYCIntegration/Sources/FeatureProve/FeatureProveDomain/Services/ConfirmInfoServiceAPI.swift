// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ConfirmInfoServiceAPI {

    func confirmInfo(
        confirmInfo: ConfirmInfo
    ) async throws -> ConfirmInfo
}
