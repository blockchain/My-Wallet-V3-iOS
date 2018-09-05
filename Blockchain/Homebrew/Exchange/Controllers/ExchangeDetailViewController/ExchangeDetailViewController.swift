//
//  ExchangeDetailViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeDetailViewController: UIViewController {
    
    enum PageModel {
        case confirm(Trade)
        case locked(Trade)
        case overview(ExchangeTradeCellModel)
    }
    
    static func make(with model: PageModel) -> ExchangeDetailViewController {
        let controller = ExchangeDetailViewController.makeFromStoryboard()
        controller.model = model
        return controller
    }
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    // MARK: Private Properties
    
    fileprivate var model: PageModel!
    fileprivate var cellModels: [ExchangeCellModel]?
    fileprivate var reuseIdentifiers: Set<String> = []
    fileprivate var coordinator: ExchangeDetailCoordinator!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = ExchangeDetailCoordinator(delegate: self, interface: self)
        coordinator.handle(event: .pageAppeared(model))
    }
    
    fileprivate func registerCells() {
        tableView.delegate = self
        tableView.dataSource = self
        
        cellModels?.forEach({ (cellModel) in
            let reuse = cellModel.reuseIdentifier
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib.init(nibName: reuse, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        })
    }
}

extension ExchangeDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = cellModels else { return UITableViewCell() }
        let item = items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath) as? ExchangeDetailCell else { return UITableViewCell() }
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO (Nothing)
    }
}

extension ExchangeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let items = cellModels else { return tableView.estimatedRowHeight }
        guard items.count > indexPath.row else { return 0.0 }
        let item = items[indexPath.row]
        let cellType = item.cellType()
        return cellType.heightForProposedWidth(
            tableView.bounds.width,
            model: item
        )
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension ExchangeDetailViewController: ExchangeDetailCoordinatorDelegate {
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, updated models: [ExchangeCellModel]) {
        registerCells()
        tableView.reloadData()
    }
}

extension ExchangeDetailViewController: ExchangeDetailInterface {
    func updateBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    func rightBarButtonVisibility(_ visibility: Visibility) {
        // TODO
    }
    
    func updateTitle(_ value: String) {
        title = value
    }
}
