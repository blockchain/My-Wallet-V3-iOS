// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit
import PlatformUIKit

public class TabSwappingMock: UIViewController, TabSwapping {
    public func send(from account: BlockchainAccount) {}
    public func send(from account: BlockchainAccount, target: TransactionTarget) {}
    public func sign(from account: BlockchainAccount, target: TransactionTarget) {}
    public func receive(into account: BlockchainAccount) {}
    public func withdraw(from account: BlockchainAccount) {}
    public func deposit(into account: BlockchainAccount) {}
    public func interestTransfer(into account: BlockchainAccount) {}
    public func interestWithdraw(from account: BlockchainAccount, target: TransactionTarget) {}
    public func switchToSend() {}
    public func switchTabToReceive() {}
    public func switchToActivity() {}
}
