//
//  TransactionsViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import PlatformKit

// TICKET: IOS-1380 - Refactor and use autolayout
class SimpleTransactionsViewController: SimpleListViewController {
    // Used to filter by specific HD accounts or imported addresses.
    var filterIndex: Int32 = 0
    
    fileprivate static let filterHeight: CGFloat = 40.0

    @IBOutlet var topToTableViewConstraint: NSLayoutConstraint!
    
    private var noTransactionsTitle: UILabel?
    private var noTransactionsDescription: UILabel?
    private var getBitcoinButton: UIButton?
    private var noTransactionsView: UIView?
    private var _balance = ""
    private var balance: String {
        get {
            return _balance
        }
        set(balance) {
            _balance = balance

            updateBalanceLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilter()
    }
    
    private func setupFilter() {
        guard topToTableViewConstraint != nil else { return }
        guard topToTableViewConstraint.constant == 0 else { return }
        
        filterIndex = Constants.FilterIndexes.all

        filterView.addSubview(filterSelectorLabel)
        filterView.addSubview(chevron)
        filterView.addSubview(separator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterSelectorViewTapped))
        filterView.addGestureRecognizer(tapGesture)
        
        view.addSubview(filterView)
        topToTableViewConstraint.constant = SimpleTransactionsViewController.filterHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc private func getAssetButtonClicked() {
        Logger.shared.warning("Warning! getAssetButtonClicked not overriden!")
    }

    @objc func filterSelectorViewTapped() {
        // Overridden by subclass
    }

    func changeFilterLabel(_ newText: String?) {
        // Overridden by subclass
    }

    private func getAmountForReceivedTransaction(_ transaction: Transaction?) -> UInt64 {
        Logger.shared.debug("TransactionsViewController: getting amount for received transaction")
        guard let transaction = transaction else { return 0 }
        return UInt64(abs(transaction.amount))
    }

    private func updateBalanceLabel() {
        title = balance
    }
    
    // MARK: Lazy Properties
    
    private lazy var filterView: UIView = {
        let rect = CGRect(
            origin: .zero,
            size: .init(
                width: view.frame.width,
                height: SimpleTransactionsViewController.filterHeight
            )
        )
        let filter = UIView(frame: rect)
        filter.backgroundColor = .lightGray
        return filter
    }()
    
    private lazy var filterSelectorLabel: UILabel = {
        let label = UILabel(frame:
            CGRect(
                x: 8.0,
                y: 0,
                width: filterView.bounds.width - 34.0,
                height: filterView.bounds.height
            )
        )
        label.font = Font(
            .branded(.montserratRegular),
            size: .standard(.small(.h2))).result
        label.textColor = .gray5
        label.text = LocalizationConstants.Transactions.allWallets
        return label
    }()
    
    private lazy var chevron: UIImageView = {
        let frame = CGRect(
            x: filterView.frame.width - 18.0,
            y: (filterView.frame.height - 10.0) / 2.0,
            width: 10.0,
            height: 10.0
        )
        let image = UIImageView(frame: frame)
        image.image = UIImage(named: "chevron_right_white")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .gray5
        return image
    }()
    
    private lazy var separator: BCLine = {
        let separator = BCLine(yPosition: filterView.bounds.height - 1)
        return separator
    }()
}
