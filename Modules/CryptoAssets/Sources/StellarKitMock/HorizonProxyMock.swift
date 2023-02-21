// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift
@testable import StellarKit
import stellarsdk

final class HorizonProxyMock: HorizonProxyAPI {

    /// Add an entry for each account you want to mock:
    /// e.g. "<id>":  AccountResponse.JSON.valid(accountID: "1", balance: "10000")
    var underlyingAccountResponseJSONMap: [String: String] = [:]

    func accountResponse(
        for accountID: String
    ) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        guard let json = underlyingAccountResponseJSONMap[accountID] else {
            return .failure(.notFound)
        }
        let decoder = JSONDecoder()
        do {
            let data: Data = json.data(using: .utf8)!
            let result = try decoder.decode(AccountResponse.self, from: data)
            return .just(result)
        } catch {
            fatalError(String(describing: error))
        }
    }

    var underlyingMinimumBalance: CryptoValue = .create(minor: 1, currency: .stellar)

    func minimumBalance(subentryCount: UInt) -> CryptoValue {
        underlyingMinimumBalance
    }

    func sign(transaction: Transaction, keyPair: stellarsdk.KeyPair) -> Completable {
        .empty()
    }

    func submitTransaction(transaction: Transaction) -> Single<TransactionPostResponseEnum> {
        .never()
    }
}

extension AccountResponse {
    enum JSON {}
}

extension AccountResponse.JSON {
    static func valid(accountID: String, balance: String) -> String {
        """
        {
            "_links": {},
            "account_id": "\(accountID)",
            "balances":
            [
                {
                    "asset_type": "native",
                    "balance": "\(balance)",
                    "buying_liabilities": "0.0000000",
                    "selling_liabilities": "0.0000000"
                }
            ],
            "data": {},
            "flags":
            {
                "auth_clawback_enabled": false,
                "auth_immutable": false,
                "auth_required": false,
                "auth_revocable": false
            },
            "id": "\(accountID)",
            "last_modified_ledger": 41390683,
            "last_modified_time": "2022-06-19T11:07:14Z",
            "num_sponsored": 0,
            "num_sponsoring": 0,
            "paging_token": "\(accountID)",
            "sequence": "1",
            "signers":
            [
                {
                    "key": "\(accountID)",
                    "type": "ed25519_public_key",
                    "weight": 0
                }
            ],
            "subentry_count": 0,
            "thresholds":
            {
                "high_threshold": 0,
                "low_threshold": 0,
                "med_threshold": 0
            }
        }
        """
    }
}
