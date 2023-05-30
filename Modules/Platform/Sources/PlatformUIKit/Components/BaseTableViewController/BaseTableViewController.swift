// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit
import UIKit

open class BaseTableViewController: BaseScreenViewController {

    // MARK: - Public UI Elements

    public let tableView = SelfSizingTableView()
    public let scrollView = UIScrollView()

    // MARK: - Private UI Elements

    private let separatorView = UIView()
    private let outerStackView = UIStackView()
    private let bottomContainerView = UIView()
    private let bottomStackView = UIStackView()
    private var contentBottomZeroHeightConstraint: NSLayoutConstraint?
    private let disposeBag = DisposeBag()

    // MARK: - Public UI Constraints

    public private(set) var contentBottomConstraint: NSLayoutConstraint!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        // Setup view

        view = UIView()
        view.backgroundColor = .white

        // Add all views
        view.addSubview(scrollView)
        scrollView.addSubview(outerStackView)
        outerStackView.addArrangedSubview(tableView)

        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(separatorView)
        bottomContainerView.addSubview(bottomStackView)

        // Setup Table View
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 28
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionFooterHeight = 28
        tableView.estimatedSectionFooterHeight = 0
        tableView.contentInset.bottom = 28

        // Setup Scrollview
        scrollView.keyboardDismissMode = .interactive
        scrollView.layout(edges: .leading, .trailing, .top, to: view, usesSafeAreaLayoutGuide: true)
        scrollView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true

        bottomContainerView.layout(edges: .leading, .trailing, .bottom, to: view)
        bottomContainerView.backgroundColor = .clear
        contentBottomZeroHeightConstraint = bottomContainerView.heightAnchor.constraint(equalToConstant: 0)
        contentBottomZeroHeightConstraint?.isActive = true
        contentBottomConstraint = bottomContainerView
            .layoutToSuperview(.bottom)

        // Setup OuterStackView
        outerStackView.axis = .vertical
        outerStackView.distribution = .equalSpacing
        outerStackView.spacing = 0
        outerStackView.layoutToSuperview(.trailing, .leading, .top, .bottom, .width)
        outerStackView.layoutToSuperview(.height, relation: .greaterThanOrEqual)

        // Setup BottomContainerView
        bottomContainerView.layout(edges: .leading, .trailing, to: view)
        bottomContainerView.contentCompressionResistancePriority = (.penultimateHigh, .penultimateHigh)
        bottomContainerView.contentHuggingPriority = (.init(rawValue: 251), .init(rawValue: 251))

        // Setup SeparatorView
        separatorView.layout(dimension: .height, to: 1)
        separatorView.layout(edges: .leading, .trailing, .top, to: bottomContainerView)
        separatorView.layout(edge: .bottom, to: .top, of: bottomStackView, offset: -16.0, priority: .defaultHigh)
        separatorView.backgroundColor = .semantic.light

        // Setup ButtonStackView
        bottomStackView.axis = .vertical
        bottomStackView.distribution = .fill
        bottomStackView.spacing = 8
        bottomStackView.layoutToSuperview(.leading, offset: 24)
        bottomStackView.layoutToSuperview(.trailing, offset: -24)
        bottomStackView.layoutToSuperview(.bottom, offset: -32)
    }

    public func addStickyBottomView(_ view: UIView) {
        bottomStackView.addArrangedSubview(view)
        contentBottomZeroHeightConstraint?.isActive = bottomStackView.subviews.isEmpty
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.availableHeight = scrollView.frame.height
        tableView.unavailableHeight = bottomContainerView.frame.height
    }
}
