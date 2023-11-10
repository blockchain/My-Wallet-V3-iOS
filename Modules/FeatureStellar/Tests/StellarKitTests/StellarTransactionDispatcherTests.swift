// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import BlockchainNamespace
@testable import StellarKit
import stellarsdk
import XCTest

final class StellarTransactionDispatcherTests: XCTestCase {

    var sut: StellarTransactionDispatcher!

    var accountRepository: StellarWalletAccountRepositoryMock!
    var horizonProxy: HorizonProxyMock!

    override func setUp() {
        super.setUp()
        accountRepository = StellarWalletAccountRepositoryMock()
        horizonProxy = HorizonProxyMock()
        sut = StellarTransactionDispatcher(
            app: App.test,
            accountRepository: accountRepository,
            horizonProxy: horizonProxy
        )
    }

    func testDryRunValidTransaction() throws {
        let sendDetails = SendDetails.valid()
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "1")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        _ = try sut.dryRunTransaction(sendDetails: sendDetails).wait()
    }

    func testDryRunTransaction_InsufficientFunds() throws {
        let sendDetails = SendDetails.valid()
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "51")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "1")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        let desiredAmount = try sendDetails.value.moneyValue + sendDetails.fee.moneyValue
        dryRunInvalidTransaction(
            sendDetails,
            with: .insufficientFunds(.create(majorBigInt: 51, currency: .crypto(.stellar)), desiredAmount)
        )
    }

    func testDryRunTransaction_BelowMinimumSend_NewAccount() throws {
        let sendAmount = CryptoValue.create(minor: 9999999, currency: .stellar)
        let minAmount = stellarMinimumBalance(subentryCount: 0)
        XCTAssertTrue(try minAmount > sendAmount)

        let sendDetails = SendDetails.valid(value: sendAmount)
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON

        dryRunInvalidTransaction(
            sendDetails,
            with: .belowMinimumSendNewAccount(minAmount.moneyValue)
        )
    }

    func testDryRunTransaction_BelowMinimumSend() throws {
        let sendDetails = SendDetails.valid(value: .create(minor: 1, currency: .stellar))
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        _ = try sut.dryRunTransaction(sendDetails: sendDetails).wait()
    }

    func testDryRunTransaction_BadDestinationAccountID() throws {
        let sendDetails = SendDetails.valid(toAddress: "HDKDDBJNREDV4ITL65Z3PNKAGWYJQL7FZJSV4P2UWGLRXI6AWT36UED")
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON

        dryRunInvalidTransaction(sendDetails, with: .badDestinationAccountID)
    }

    private func dryRunInvalidTransaction(
        _ sendDetails: SendDetails,
        with expectedError: SendFailureReason,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            _ = try sut.dryRunTransaction(sendDetails: sendDetails).wait()
            XCTFail("Should have failed", file: file, line: line)
        } catch {
            if (error as? SendFailureReason) != expectedError {
                XCTFail("Unexpected error \(String(describing: error))", file: file, line: line)
            }
        }
    }

}

extension SendDetails {
    fileprivate static func valid(
        toAddress: String = "GCJD4FLZFAEYXYLZYCNH3PVUHAQGEBLXHTJHLWXG5Q6XA6YXCPCYJGPA",
        value: CryptoValue = .create(majorBigInt: 50, currency: .stellar)
    ) -> SendDetails {
        SendDetails(
            fromAddress: "GAAZI4TCR3TY5OJHCTJC2A4QSY6CJWJH5IAJTGKIN2ER7LBNVKOCCWN7",
            fromLabel: "From Label",
            toAddress: toAddress,
            toLabel: "To Label",
            value: value,
            fee: .create(majorBigInt: 1, currency: .stellar),
            memo: "1234567890"
        )
    }
}
