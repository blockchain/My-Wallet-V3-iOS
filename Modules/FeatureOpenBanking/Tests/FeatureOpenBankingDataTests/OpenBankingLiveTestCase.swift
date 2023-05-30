// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
@testable import FeatureOpenBankingData
import FirebaseProtocol
@testable import NetworkKit
import TestKit

/// Used for testing without any UI
final class OpenBankingLiveTestCase: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBankingClient!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = App(remote: Mock.RemoteConfiguration())
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        banking = OpenBankingClient(
            app: app,
            requestBuilder: RequestBuilder(
                config: Network.Config(
                    scheme: "https",
                    host: "api.blockchain.info",
                    components: ["nabu-gateway"]
                ),
                headers: ["Authorization": "Bearer "]
            ),
            network: NetworkAdapter(
                communicator: EphemeralNetworkCommunicator(
                    session: .shared,
                    isRecording: true,
                    directory: "/tmp/OpenBanking"
                )
            ).network,
            scheduler: DispatchQueue.main.eraseToAnyScheduler()
        )
    }

    func x_test_delete() throws {

        let accounts = try banking.fetchAllBankAccounts()
            .wait(timeout: 5)

        for account in accounts where account.state != .active {
            print("Deleting \(account.id.value)", terminator: " ")
            switch Result(catching: { try account.delete(in: banking).wait() }) {
            case .failure(let error):
                print("❌ \(error)")
            case .success:
                print("✅")
            }
        }
    }

    func x_test_link() throws {

        let bankAccount = try banking.createBankAccount()
            .wait(timeout: 5)

        let activation = try bankAccount.activateBankAccount(
            with: bankAccount.attributes.institutions![1].id,
            in: banking
        )
        .wait(timeout: 5)

        let subscription = app.publisher(for: blockchain.ux.payment.method.open.banking.authorisation.url, as: URL.self)
            .map(\.result)
            .sink { result in
                switch result {
                case .success(let url):
                    var consentToken = ""
                    // Stop debugger on `print` and set `consentToken`
                    // to mutate the open banking state to finalise the transaction
                    consentToken = ""
                    print(url) // e consentToken = "..."
                    self.app.state.set(blockchain.ux.payment.method.open.banking.consent.token, to: consentToken)
                case .failure(FetchResult.Error.keyDoesNotExist):
                    break
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }

        let account = try activation.poll(in: banking)
            .wait(timeout: 120000)

        subscription.cancel()
        _ = account
    }

    func x_test_payment() throws {

        let bankAccount = try banking.fetchAllBankAccounts()
            .wait(timeout: 5)
            .first(where: { $0.state == "ACTIVE" })
            .unwrap()

        let payment = try bankAccount.deposit(amountMinor: "1000", product: "SIMPLEBUY", in: banking)
            .wait(timeout: 5)

        let subscription = banking.app
            .publisher(for: blockchain.ux.payment.method.open.banking.authorisation.url, as: URL.self)
            .map(\.result)
            .sink { result in
                switch result {
                case .success(let url):
                    var consentToken = ""
                    // Stop debugger on `print` and set `consentToken`
                    // to mutate the open banking state to finalise the transaction
                    consentToken = ""
                    print(url) // e consentToken = "..."
                    self.app.state.set(blockchain.ux.payment.method.open.banking.consent.token, to: consentToken)
                case .failure(FetchResult.Error.keyDoesNotExist):
                    break
                case .failure(let error):
                    XCTFail("\(error)")
                }
            }

        let details = try payment.poll(in: banking)
            .wait(timeout: 120000)

        subscription.cancel()
        _ = details
    }
}
