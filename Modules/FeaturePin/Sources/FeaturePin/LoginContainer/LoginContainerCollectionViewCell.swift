// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

class LoginContainerCollectionViewCell: UICollectionViewCell {

    // MARK: - Injected

    var input: LoginContainerViewController.Input! {
        didSet {
            let view = input.view
            contentView.addSubview(view)
            view.layoutToSuperviewCenter()
            view.layoutToSuperviewSize()
            contentView.layoutIfNeeded()
        }
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        input.viewController?.remove()
        input.view.removeFromSuperview()
    }
}
