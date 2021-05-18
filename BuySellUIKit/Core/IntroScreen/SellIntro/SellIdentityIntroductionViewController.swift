//
//  SellIdentityIntroductionViewController.swift
//  BuySellUIKit
//
//  Created by Alex McGregor on 9/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class SellIdentityIntroductionViewController: BaseScreenViewController {
    
    private let tableView = SelfSizingTableView()
    private let presenter: SellIdentityIntroductionPresenter
    
    init(presenter: SellIdentityIntroductionPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        tableView.reloadData()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal, usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(axis: .vertical, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        tableView.register(BadgeNumberedTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SellIdentityIntroductionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        presenter.cellCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .announcement(let viewModel):
            cell = announcement(for: indexPath, viewModel: viewModel)
        case .numberedItem(let viewModel):
            cell = numberedCell(for: indexPath, viewModel: viewModel)
        case .buttons(let buttons):
            cell = buttonsCell(for: indexPath, buttons: buttons)
        }
        return cell
    }
        
    // MARK: - Accessors
    
    private func announcement(for indexPath: IndexPath, viewModel: AnnouncementCardViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
    
    private func numberedCell(for indexPath: IndexPath, viewModel: BadgeNumberedItemViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(BadgeNumberedTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
    
    private func buttonsCell(for indexPath: IndexPath, buttons: [ButtonViewModel]) -> UITableViewCell {
        let cell = tableView.dequeue(ButtonsTableViewCell.self, for: indexPath)
        cell.models = buttons
        return cell
    }
}


