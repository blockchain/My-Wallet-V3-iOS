// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain

public struct FlowKYCInfoClientRequest {
    public enum EntryPoint: String {
        case other = "OTHER"
    }

    let entryPoint: EntryPoint
}
