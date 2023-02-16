// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public protocol TabSwapping: UIViewController {
    func send(from account: BlockchainAccount)
    func send(from account: BlockchainAccount, target: TransactionTarget)
    func sign(from account: BlockchainAccount, target: TransactionTarget)
    func receive(into account: BlockchainAccount)
    func withdraw(from account: BlockchainAccount)
    func deposit(into account: BlockchainAccount)
    func interestTransfer(into account: BlockchainAccount)
    func interestWithdraw(from account: BlockchainAccount)
    func switchToSend()
    func switchTabToReceive()
    func switchToActivity()
}
