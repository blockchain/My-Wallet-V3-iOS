// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol PendingTransactionPageInteractable: Interactable {
    var listener: PendingTransactionPageListener? { get set }
}

protocol PendingTransactionPageViewControllable: ViewControllable {}
