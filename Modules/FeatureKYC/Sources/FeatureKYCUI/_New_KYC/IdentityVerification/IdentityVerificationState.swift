// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import PlatformKit

struct IdentityVerificationState: Equatable {
    @BindingState var documentTypes: [KYCDocumentType] = []
    var isLoading = false
}
