//
//  KYCAddressDetailViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class KYCAddressDetailViewController: UIViewController {

    struct PageModel {
        let cellModels: [CellModel]
        let address: PostalAddress
    }

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var model: PageModel!
    fileprivate var reuseIdentifiers: Set<String> = []

    // MARK: Class Functions

    static func make(_ address: PostalAddress) -> KYCAddressDetailViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! KYCAddressDetailViewController
        let model = PageModel(
            cellModels: address.generateCellModels(),
            address: address
        )
        controller.model = model
        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerAllCellTypes()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    fileprivate func registerAllCellTypes() {
        model.cellModels.forEach { (model) in
            let reuse = model.cellType().identifier
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib.init(nibName: reuse, bundle: Bundle(for: model.cellType()))
                tableView.register(nib, forCellReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        }

        let footerNib = UINib(nibName: String(describing: ConfirmationFooterView.self), bundle: nil)
        tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: String(describing: ConfirmationFooterView.self))
    }
}

extension KYCAddressDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = model.cellModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellModel.cellType().identifier,
            for: indexPath
        ) as? BaseTableViewCell else { return UITableViewCell() }
        cell.configure(with: cellModel)
        if let textEntry = cell as? TextEntryCell {
            textEntry.delegate = self
        }
        cell.separatorInset = UIEdgeInsets(
            top: 0.0,
            left: 16.0,
            bottom: 0.0,
            right: 16.0
        )
        return cell
    }
}

extension KYCAddressDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = model.cellModels[indexPath.item]
        return cellModel.heightForProposed(width: tableView.bounds.width)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: ConfirmationFooterView.self)
        ) as? ConfirmationFooterView else { return nil }
        footer.actionBlock = { [weak self] in
            // TODO: pass along updated address
            self?.performSegue(withIdentifier: "showPersonalDetails", sender: nil)
        }
        
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ConfirmationFooterView.footerHeight()
    }
}

extension KYCAddressDetailViewController: TextEntryCellDelegate {
    func textEntryCell(_ cell: TextEntryCell, enteredValue value: String) {
        // TODO:
    }
}
