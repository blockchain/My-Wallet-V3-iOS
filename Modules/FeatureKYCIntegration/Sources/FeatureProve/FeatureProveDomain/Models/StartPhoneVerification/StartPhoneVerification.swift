// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public struct StartPhoneVerification: Equatable {
    public let resendWaitTime: Int?

    public init(resendWaitTime: Int?) {
        self.resendWaitTime = resendWaitTime
    }
}
