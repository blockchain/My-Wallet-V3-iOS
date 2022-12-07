// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum VerificationResult: Equatable {
    public enum Failure {
        case generic
        case verification
    }

    case success
    case abandoned
    case failure(Failure)
}
