//
//  InterestAccountDetailsViewController.swift
//  InterestUIKit
//
//  Created by Alex McGregor on 8/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources
import RxSwift

public final class InterestAccountDetailsViewController: BaseScreenViewController {
    
    // MARK: - Types
    
    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<DetailSectionViewModel>
    
    // MARK: - Private Properties
    
    private let tableView: SelfSizingTableView
    private let presenter: InterestAccountDetailsScreenPresenter
    private let disposeBag = DisposeBag()
    
    public init(presenter: InterestAccountDetailsScreenPresenter) {
        self.presenter = presenter
        self.tableView = SelfSizingTableView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview(usesSafeAreaLayoutGuide: true)
        tableView.separatorColor = .background
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(LineItemTableViewCell.self)
        tableView.register(FooterTableViewCell.self)
        
        let dataSource = RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .currentBalance(let presenter):
                cell = self.balanceCell(for: indexPath, presenter: presenter)
            case .footer(let presenter):
                cell = self.footerCell(for: indexPath, presenter: presenter)
            case .lineItem(let type):
                switch type {
                case .default(let presenter):
                    cell = self.lineItemCell(for: indexPath, presenter: presenter)
                }
            }
            cell.selectionStyle = .none
            return cell
        })
        
        presenter.sectionObservable
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        set(barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton)
        titleViewStyle = presenter.titleView
    }
}

extension InterestAccountDetailsViewController {
    
    private func balanceCell(for indexPath: IndexPath, presenter: CurrentBalanceCellPresenter) -> CurrentBalanceTableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func footerCell(for indexPath: IndexPath, presenter: FooterTableViewCellPresenter) -> FooterTableViewCell {
        let cell = tableView.dequeue(FooterTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func lineItemCell(for indexPath: IndexPath, presenter: LineItemCellPresenting) -> LineItemTableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
