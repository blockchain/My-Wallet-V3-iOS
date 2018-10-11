//
//  SideMenuViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SideMenuViewControllerDelegate: class {
    func sideMenuViewController(_ viewController: SideMenuViewController, didTapOn item: SideMenuItem)
}

/// View controller displaying the side menu (hamburger menu) of the app
class SideMenuViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: SideMenuViewControllerDelegate?

    // MARK: - Private Properties

    @IBOutlet private var tableView: UITableView!

    private var tapToCloseGestureRecognizerVC: UITapGestureRecognizer!
    private var tapToCloseGestureRecognizerTabBar: UITapGestureRecognizer!

    private lazy var presenter: SideMenuPresenter = {
        return SideMenuPresenter(view: self)
    }()

    private var sideMenuItems: [SideMenuItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        AppCoordinator.shared.slidingViewController.delegate = self
        tapToCloseGestureRecognizerTabBar = UITapGestureRecognizer(
            target: AppCoordinator.shared,
            action: #selector(AppCoordinator.toggleSideMenu)
        )
        tapToCloseGestureRecognizerVC = UITapGestureRecognizer(
            target: AppCoordinator.shared,
            action: #selector(AppCoordinator.toggleSideMenu)
        )
        registerCells()
        initializeTableView()
        addShadow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadSideMenu()
        setSideMenuGestures()
        addShadow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        resetSideMenuGestures()
        super.viewWillDisappear(animated)
    }

    // MARK: - Public Methods

    func reload() {
        tableView.reloadData()
    }

    // MARK: - Private Methods
    
    private func registerCells() {
        let nib = UINib(nibName: SideMenuCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SideMenuCell.identifier)
    }

    private func initializeTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }

    private func addShadow() {
        guard let view = AppCoordinator.shared.slidingViewController.topViewController.view else { return }
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
    }

    private func setSideMenuGestures() {
        guard let tabViewController = AppCoordinator.shared.tabControllerManager.tabViewController else { return }

        // Disable all interactions on main view
        tabViewController.activeViewController.view.subviews.forEach {
            $0.isUserInteractionEnabled = false
        }
        tabViewController.menuSwipeRecognizerView.isUserInteractionEnabled = false

        // Enable Pan gesture and tap gesture to close sideMenu
        let slidingViewController = AppCoordinator.shared.slidingViewController
        tabViewController.activeViewController.view.isUserInteractionEnabled = true
        tabViewController.activeViewController.view.addGestureRecognizer(slidingViewController.panGesture)
        tabViewController.activeViewController.view.addGestureRecognizer(tapToCloseGestureRecognizerVC)
        tabViewController.addTapGestureRecognizer(toTabBar: tapToCloseGestureRecognizerTabBar)
    }

    private func resetSideMenuGestures() {
        guard let tabViewController = AppCoordinator.shared.tabControllerManager.tabViewController else { return }

        // Disable Pan and Tap gesture on main view
        let slidingViewController = AppCoordinator.shared.slidingViewController
        tabViewController.activeViewController.view.removeGestureRecognizer(slidingViewController.panGesture)
        tabViewController.activeViewController.view.removeGestureRecognizer(tapToCloseGestureRecognizerVC)
        tabViewController.removeTapGestureRecognizer(fromTabBar: tapToCloseGestureRecognizerTabBar)

        // Enable interaction on main view
        tabViewController.activeViewController.view.subviews.forEach {
            $0.isUserInteractionEnabled = true
        }

        // Enable swipe to open side menu gesture on small bar on the left of main view
        tabViewController.menuSwipeRecognizerView.isUserInteractionEnabled = true
        tabViewController.menuSwipeRecognizerView.addGestureRecognizer(slidingViewController.panGesture)
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SideMenuCell.defaultHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sideMenuCell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier) as? SideMenuCell else {
            Logger.shared.debug("Could not get SideMenuCell")
            return UITableViewCell()
        }
        sideMenuCell.item = sideMenuItems[indexPath.row]
        return sideMenuCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sideMenuItems[indexPath.row]
        delegate?.sideMenuViewController(self, didTapOn: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SideMenuViewController: SideMenuView {
    func setMenu(items: [SideMenuItem]) {
        self.sideMenuItems = items
    }
}

extension SideMenuViewController: ECSlidingViewControllerDelegate {
    func slidingViewController(
        _ slidingViewController: ECSlidingViewController!,
        animationControllerFor operation: ECSlidingViewControllerOperation,
        topViewController: UIViewController!
    ) -> UIViewControllerAnimatedTransitioning? {
        // SideMenu will slide in
        if operation == .anchorRight {
            setSideMenuGestures()
        }
        return nil
    }
}
