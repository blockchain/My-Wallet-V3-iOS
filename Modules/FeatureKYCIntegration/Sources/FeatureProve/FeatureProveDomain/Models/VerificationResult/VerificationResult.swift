// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

public enum VerificationResult: Equatable {
    case success
    case abandoned
    case failure(Nabu.ErrorCode)
}
