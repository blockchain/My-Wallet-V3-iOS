// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import SwiftUI
import UIKit

public protocol InterestAccountListHostingControllerDelegate: AnyObject {
    func presentKYCIfNeeded()
    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency)
}

public final class InterestAccountListHostingController: UIViewController, InterestAccountListViewDelegate {

    public weak var delegate: InterestAccountListHostingControllerDelegate?

    private let contentView: UIHostingController<InterestAccountListView>

    public init(embeddedInNavigationView: Bool) {
        self.contentView = UIHostingController(
            rootView: InterestAccountListView(
                store: .init(
                    initialState: InterestAccountListState(
                        interestAccountDetails: .init(uniqueElements: []),
                        loadingStatus: .fetchingAccountStatus
                    ),
                    reducer: {
                        InterestAccountListReducer(
                            environment: InterestAccountSelectionEnvironment.default
                        )
                    }
                ),
                embeddedInNavigationView: embeddedInNavigationView
            )
        )
        super.init(nibName: nil, bundle: nil)
        contentView.rootView.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView.view)
        addChild(contentView)
        setupConstraints()
    }

    private func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.fillSuperview()
    }

    // MARK: - InterestAccountListViewDelegate

    func didTapVerifyMyIdentity() {
        delegate?.presentKYCIfNeeded()
    }

    func didTapBuyCrypto(_ cryptoCurrency: CryptoCurrency) {
        delegate?.presentBuyIfNeeded(cryptoCurrency)
    }
}
