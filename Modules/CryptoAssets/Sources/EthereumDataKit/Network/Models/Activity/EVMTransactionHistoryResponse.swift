// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct EVMTransactionHistoryResponse: Decodable {

    enum Status: String, Decodable {
        case pending = "PENDING"
        case confirming = "CONFIRMING"
        case completed = "COMPLETED"
        case failed = "FAILED"
    }

    struct Item: Decodable {
        struct ExtraData: Decodable {
            let blockNumber: String?
        }

        struct Movement: Decodable {
            let type: String
            let address: String
            let amount: String
            let identifier: String
        }

        let txId: String
        let status: Status
        let timestamp: Double
        let fee: String
        let extraData: ExtraData
        let movements: [Movement]
    }

    let history: [Item]
}
