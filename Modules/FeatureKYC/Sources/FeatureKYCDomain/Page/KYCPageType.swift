// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public enum KYCPageType: Int {
    // Need to set the first enumeration as 1. The order of these enums also matter
    // since KycSettings.latestKycPage will look at the rawValue of the enum when
    // the latestKycPage is set.
    case welcome = 1
    case enterEmail
    case confirmEmail
    case country
    case states
    case profile
    case profileNew
    case address
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case resubmitIdentity
    case applicationComplete
    case accountStatus
    case accountUsageForm
    case finish
}

extension KYCPageType {

    // swiftlint:disable force_try
    public var descendant: [String] {
        try! tag[].idRemainder(after: blockchain.ux.kyc.type.state[])
            .splitIfNotEmpty()
            .map(String.init)
    }

    public var tag: Tag.Event {
        switch self {
        case .welcome:
            return blockchain.ux.kyc.type.state.welcome
        case .enterEmail:
            return blockchain.ux.kyc.type.state.enter.email
        case .confirmEmail:
            return blockchain.ux.kyc.type.state.confirm.email
        case .country:
            return blockchain.ux.kyc.type.state.country
        case .states:
            return blockchain.ux.kyc.type.state.states
        case .profile, .profileNew:
            return blockchain.ux.kyc.type.state.profile
        case .address:
            return blockchain.ux.kyc.type.state.address
        case .enterPhone:
            return blockchain.ux.kyc.type.state.enter.phone
        case .confirmPhone:
            return blockchain.ux.kyc.type.state.confirm.phone
        case .verifyIdentity:
            return blockchain.ux.kyc.type.state.verify.identity
        case .resubmitIdentity:
            return blockchain.ux.kyc.type.state.resubmit.identity
        case .applicationComplete:
            return blockchain.ux.kyc.type.state.application.complete
        case .accountStatus:
            return blockchain.ux.kyc.type.state.account.status
        case .accountUsageForm:
            return blockchain.ux.kyc.type.state.account.form
        case .finish:
            return blockchain.ux.kyc.type.state.finish
        }
    }
}
