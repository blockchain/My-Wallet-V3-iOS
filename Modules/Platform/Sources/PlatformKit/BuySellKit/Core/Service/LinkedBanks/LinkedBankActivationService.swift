// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import RxToolKit
import ToolKit

public enum BankActivationState {
    case active(LinkedBankData)
    case pending
    case inactive(LinkedBankData?)

    var isPending: Bool {
        switch self {
        case .pending:
            true
        case .active, .inactive:
            false
        }
    }

    init(_ response: LinkedBankResponse) {
        guard let bankData = LinkedBankData(response: response) else {
            self = .inactive(nil)
            return
        }
        switch response.state {
        case .active:
            self = .active(bankData)
        case .pending:
            self = .pending
        case .blocked:
            self = .inactive(bankData)
        }
    }
}

public protocol LinkedBankActivationServiceAPI {
    /// Cancel polling
    var cancel: Completable { get }

    /// Poll for activation
    func waitForActivation(
        of bankId: String,
        paymentAccountId: String,
        accountId: String
    ) -> Single<PollResult<BankActivationState>>
}

final class LinkedBankActivationService: LinkedBankActivationServiceAPI {

    // MARK: - Properties

    var cancel: Completable {
        pollService.cancel
    }

    // MARK: - Injected

    private let pollService: PollService<BankActivationState>
    private let client: LinkedBanksClientAPI

    // MARK: - Setup

    init(client: LinkedBanksClientAPI = resolve()) {
        self.client = client
        self.pollService = PollService(matcher: { !$0.isPending })
    }

    func waitForActivation(
        of bankId: String,
        paymentAccountId: String,
        accountId: String
    ) -> Single<PollResult<BankActivationState>> {
        pollService.setFetch(weak: self) { (self) -> Single<BankActivationState> in
            self.client.updateBankLinkage(
                for: bankId,
                providerAccountId: paymentAccountId,
                accountId: accountId
            )
            .map { payload in
                guard payload.state != .pending else {
                    return .pending
                }
                return BankActivationState(payload)
            }
            .asSingle()
        }
        return pollService.poll(timeoutAfter: 60)
    }
}
