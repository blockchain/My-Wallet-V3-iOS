import MoneyKit
import PlatformKit
@testable import StellarKit
import stellarsdk
import TestKit
import XCTest

final class AccountResponseTests: XCTestCase {

    let json = Fixtures.loadJSONData(filename: "account_response", in: .module)!

    func test_total_balance() throws {

        let account = try JSONDecoder().decode(AccountResponse.self, from: json)

        XCTAssertEqual(
            account.totalBalance,
            CryptoValue.create(major: 80.8944518, currency: .stellar)
        )
    }
}
