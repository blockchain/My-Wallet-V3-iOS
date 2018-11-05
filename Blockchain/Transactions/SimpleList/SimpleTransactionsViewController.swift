//
//  TransactionsViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TICKET: IOS-1380 - Refactor and use autolayout
class SimpleTransactionsViewController: SimpleListViewController {
    // Used to filter by specific HD accounts or imported addresses.
    var filterIndex: Int32 = 0

    private var noTransactionsTitle: UILabel?
    private var noTransactionsDescription: UILabel?
    private var getBitcoinButton: UIButton?
    private var noTransactionsView: UIView?
    private var filterSelectorView: UIView?
    private var filterSelectorLabel: UILabel?
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
    
    // swiftlint:disable function_body_length
    private func setupFilter() {
        filterIndex = Constants.FilterIndexes.all

        filterSelectorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        filterSelectorView?.backgroundColor = UIColor.lightGray

        let padding: CGFloat = 8
        let imageViewWidth: CGFloat = 10
        filterSelectorLabel = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: (filterSelectorView?.bounds.size.width ?? 0.0) - padding * 3 - imageViewWidth,
            height: filterSelectorView?.bounds.size.height ?? 0.0))
        if let extraSmall = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraSmall) {
            filterSelectorLabel?.font = extraSmall
        }
        filterSelectorLabel?.textColor = UIColor.gray5
        filterSelectorLabel?.text = LocalizationConstants.Transactions.allWallets
        if let aLabel = filterSelectorLabel {
            filterSelectorView?.addSubview(aLabel)
        }

        let chevronImageView = UIImageView(frame: CGRect(
            x: (filterSelectorView?.frame.size.width ?? 0.0) - imageViewWidth - padding,
            y: ((filterSelectorView?.frame.size.height ?? 0.0) - imageViewWidth) / 2,
            width: imageViewWidth,
            height: imageViewWidth + 2))
        chevronImageView.image = UIImage(named: "chevron_right_white")?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tintColor = UIColor.gray5
        filterSelectorView?.addSubview(chevronImageView)

        if let lineAboveButtonsView = BCLine(yPosition: filterSelectorView!.bounds.size.height - 1) {
            filterSelectorView?.addSubview(lineAboveButtonsView)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.filterSelectorViewTapped))
        filterSelectorView?.addGestureRecognizer(tapGesture)

        view.addSubview(filterSelectorView!)
    }

    private func setupNoTransactionsView(in view: UIView?, assetType: LegacyAssetType) {
        noTransactionsView?.removeFromSuperview()

        let convertedAssetType = AssetTypeLegacyHelper.convert(fromLegacy: assetType)
        let descriptionText = String(
            format: LocalizationConstants.Transactions.noTransactionsAssetArgument, convertedAssetType.description.lowercased()
        )

        var buttonText: String

        switch convertedAssetType {
        case .bitcoin:
            buttonText = String(format: LocalizationConstants.Transactions.getArgument, convertedAssetType.description.lowercased())
        case .ethereum:
            buttonText = String(format: LocalizationConstants.Transactions.requestArgument, convertedAssetType.description.lowercased())
        case .bitcoinCash:
            buttonText = String(format: LocalizationConstants.Transactions.getArgument, convertedAssetType.description.lowercased())
        case .stellar:
            buttonText = String(format: LocalizationConstants.Transactions.requestArgument, convertedAssetType.description.lowercased())
        default:
            Logger.shared.error("Unsupported asset type")
            return
        }

        let noTransactionsViewVar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))

        // Title label Y origin will be above midpoint between end of cards view and table view height
        let noTransactionsTitleVar = UILabel(frame: CGRect.zero)
        noTransactionsTitleVar.textAlignment = .center
        if let smallMedium = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.SmallMedium) {
            noTransactionsTitleVar.font = smallMedium
        }
        noTransactionsTitleVar.text = LocalizationConstants.Transactions.noTransactions
        noTransactionsTitleVar.textColor = UIColor.brandPrimary
        noTransactionsTitleVar.sizeToFit()

        let noTransactionsViewCenterY: CGFloat = (self.view.frame.size.height - noTransactionsViewVar.frame.origin.y) / 2
            - noTransactionsTitleVar.frame.size.height
        noTransactionsTitleVar.center = CGPoint(x: noTransactionsViewVar.center.x, y: noTransactionsViewCenterY)
        noTransactionsViewVar.addSubview(noTransactionsTitleVar)
        noTransactionsTitle = noTransactionsTitleVar

        // Description label Y origin will be 8 points under title label
        let noTransactionsDescriptionVar = UILabel(frame: CGRect.zero)
        noTransactionsDescriptionVar.textAlignment = .center
        if let extraSmall = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraSmall) {
            noTransactionsDescriptionVar.font = extraSmall
        }

        noTransactionsDescriptionVar.numberOfLines = 0
        noTransactionsDescriptionVar.text = descriptionText
        noTransactionsDescriptionVar.textColor = UIColor.gray5
        noTransactionsDescriptionVar.sizeToFit()
        let labelSize = noTransactionsDescriptionVar.sizeThatFits(CGSize(width: 170, height: CGFloat.greatestFiniteMagnitude))
        var labelFrame: CGRect = noTransactionsDescriptionVar.frame
        labelFrame.size = labelSize
        noTransactionsDescriptionVar.frame = labelFrame
        noTransactionsViewVar.addSubview(noTransactionsDescriptionVar)
        noTransactionsDescriptionVar.center = CGPoint(x: noTransactionsViewVar.center.x, y: noTransactionsDescriptionVar.center.y)
        noTransactionsDescriptionVar.frame = CGRect(
            x: noTransactionsDescriptionVar.frame.origin.x,
            y: noTransactionsTitleVar.frame.origin.y + noTransactionsTitleVar.frame.size.height + 8,
            width: noTransactionsDescriptionVar.frame.size.width,
            height: noTransactionsDescriptionVar.frame.size.height
        )

        // Get bitcoin button Y origin will be 16 points under description label
        let getBitcoinButtonVar = UIButton(frame: CGRect(
            x: 0,
            y: noTransactionsDescriptionVar.frame.origin.y + noTransactionsDescriptionVar.frame.size.height + 16,
            width: 240,
            height: 44))
        getBitcoinButtonVar.clipsToBounds = true
        getBitcoinButtonVar.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        getBitcoinButtonVar.backgroundColor = UIColor.brandSecondary
        getBitcoinButtonVar.center = CGPoint(x: noTransactionsViewVar.center.x, y: getBitcoinButtonVar.center.y)
        if let extraSmall = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraSmall) {
            getBitcoinButtonVar.titleLabel?.font = extraSmall
        }
        getBitcoinButtonVar.setTitleColor(UIColor.white, for: .normal)
        getBitcoinButtonVar.setTitle(buttonText.uppercased(), for: .normal)
        getBitcoinButtonVar.addTarget(self, action: #selector(self.getAssetButtonClicked), for: .touchUpInside)
        noTransactionsViewVar.addSubview(getBitcoinButtonVar)

        self.view.addSubview(noTransactionsViewVar)

        // Reposition description label Y to center of screen, and reposition title and button Y origins around it
        noTransactionsDescriptionVar.center = CGPoint(x: noTransactionsTitleVar.center.x, y: noTransactionsViewVar.frame.size.height / 2)
        noTransactionsTitleVar.center = CGPoint(
            x: noTransactionsTitleVar.center.x,
            y: noTransactionsDescriptionVar.frame.origin.y
                - noTransactionsTitleVar.frame.size.height - 8
                + noTransactionsTitleVar.frame.size.height / 2
        )
        getBitcoinButtonVar.center = CGPoint(
            x: getBitcoinButtonVar.center.x,
            y: noTransactionsDescriptionVar.frame.origin.y +
                noTransactionsDescriptionVar.frame.size.height + 16
                + noTransactionsDescriptionVar.frame.size.height / 2
        )
        getBitcoinButtonVar.isHidden = false

        noTransactionsView = noTransactionsViewVar
        noTransactionsDescription = noTransactionsDescriptionVar
        noTransactionsTitle = noTransactionsTitleVar
        getBitcoinButton = getBitcoinButtonVar
    }
    // swiftlint:enable function_body_length

    @objc private func getAssetButtonClicked() {
        Logger.shared.warning("Warning! getAssetButtonClicked not overriden!")
    }

    @objc private func filterSelectorViewTapped() {
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
        let tabViewController: TabViewController? = AppCoordinator.sharedInstance().tabControllerManager.tabViewController
        if tabViewController?.activeViewController == self {
            tabViewController?.updateBalanceLabelText(balance)
        }
    }
}
