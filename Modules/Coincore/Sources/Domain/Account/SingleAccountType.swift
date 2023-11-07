// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum SingleAccountType: Hashable {
    case custodial(CustodialAccountType)
    case nonCustodial

    public enum CustodialAccountType: String, Hashable {
        case trading
        case savings
    }

    public var isTrading: Bool {
        switch self {
        case .nonCustodial,
             .custodial(.savings):
            false
        case .custodial(.trading):
            true
        }
    }

    public var isSavings: Bool {
        switch self {
        case .nonCustodial,
             .custodial(.trading):
            false
        case .custodial(.savings):
            true
        }
    }

    public var description: String {
        switch self {
        case .custodial(let type):
            "SingleAccountType.custodial.\(type.rawValue)"
        case .nonCustodial:
            "SingleAccountType.nonCustodial"
        }
    }
}
