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
            return false
        case .custodial(.trading):
            return true
        }
    }

    public var isSavings: Bool {
        switch self {
        case .nonCustodial,
             .custodial(.trading):
            return false
        case .custodial(.savings):
            return true
        }
    }

    public var description: String {
        switch self {
        case .custodial(let type):
            return "SingleAccountType.custodial.\(type.rawValue)"
        case .nonCustodial:
            return "SingleAccountType.nonCustodial"
        }
    }
}
