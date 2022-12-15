// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import UIComponentsKit
import UIKit

final class PortfolioEmptyStateTableViewCell: UITableViewCell {

    // MARK: - Private Properties

    private let title: UILabel = .init()
    private let subtitle: UILabel = .init()
    private let cta: ButtonView = .init()
    private let presenter: PortfolioEmptyStatePresenter = .init()
    private var minimalDoubleButton: UIHostingController<MinimalDoubleButton<Icon, Icon>>!

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func setup() {
        minimalDoubleButton = UIHostingController(
            rootView: MinimalDoubleButton(
                leadingTitle: "Receive",
                leadingLeadingView: { Icon.qrCode },
                leadingAction: { [presenter] in
                    presenter.didTapReceive.accept(())
                },
                trailingTitle: "Deposit",
                trailingLeadingView: { Icon.bank },
                trailingAction: { [presenter] in
                    presenter.didTapDeposit.accept(())
                }
            )
        )

        title.numberOfLines = 0
        subtitle.numberOfLines = 0
        title.content = presenter.title
        subtitle.content = presenter.subtitle
        cta.viewModel = presenter.cta
        let button: UIView! = minimalDoubleButton.view

        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(cta)
        contentView.addSubview(button)

        title.layoutToSuperview(axis: .horizontal, offset: 24)
        subtitle.layoutToSuperview(axis: .horizontal, offset: 24)
        cta.layoutToSuperview(axis: .horizontal, offset: 24)
        button.layoutToSuperview(axis: .horizontal, offset: 24)

        title.layoutToSuperview(.top, offset: 70)
        title.layout(dimension: .height, to: 32)
        title.layout(edge: .bottom, to: .top, of: subtitle)
        subtitle.layout(edge: .bottom, to: .top, of: cta, offset: -24)
        cta.layout(dimension: .height, to: ButtonSize.Standard.height)
        cta.layout(edge: .bottom, to: .top, of: button, offset: -16)
        button.layoutToSuperview(.centerX)
        button.layoutToSuperview(.bottom, offset: 24)
    }
}
