// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions

public struct FlowKYCInfo: Equatable {

    public struct NextFlow: NewTypeString {

        public private(set) var value: String

        public init(_ value: String) { self.value = value }

        public static let prove: Self = "/kyc/prove"
    }

    public let nextFlow: NextFlow?

    public init(nextFlow: NextFlow?) {
        self.nextFlow = nextFlow
    }
}
