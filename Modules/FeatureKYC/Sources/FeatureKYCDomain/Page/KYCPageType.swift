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
    case ssn
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
            blockchain.ux.kyc.type.state.welcome
        case .enterEmail:
            blockchain.ux.kyc.type.state.enter.email
        case .confirmEmail:
            blockchain.ux.kyc.type.state.confirm.email
        case .country:
            blockchain.ux.kyc.type.state.country
        case .states:
            blockchain.ux.kyc.type.state.states
        case .profile, .profileNew:
            blockchain.ux.kyc.type.state.profile
        case .address:
            blockchain.ux.kyc.type.state.address
        case .enterPhone:
            blockchain.ux.kyc.type.state.enter.phone
        case .confirmPhone:
            blockchain.ux.kyc.type.state.confirm.phone
        case .verifyIdentity:
            blockchain.ux.kyc.type.state.verify.identity
        case .resubmitIdentity:
            blockchain.ux.kyc.type.state.resubmit.identity
        case .applicationComplete:
            blockchain.ux.kyc.type.state.application.complete
        case .accountStatus:
            blockchain.ux.kyc.type.state.account.status
        case .accountUsageForm:
            blockchain.ux.kyc.type.state.account.form
        case .ssn:
            blockchain.ux.kyc.type.state.ssn
        case .finish:
            blockchain.ux.kyc.type.state.finish
        }
    }
}
