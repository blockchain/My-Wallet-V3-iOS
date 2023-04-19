// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct BeneficiaryResponse: Decodable {

    struct Agent: Decodable {
        let account: String
    }

    let id: String
    let address: String
    let currency: String
    let name: String
    let agent: Agent
}
