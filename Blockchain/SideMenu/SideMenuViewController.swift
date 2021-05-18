//
//  SideMenuViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

protocol SideMenuViewControllerDelegate: AnyObject {
    func sideMenuViewController(_ viewController: SideMenuViewController, didTapOn item: SideMenuItem)
}

/// View controller displaying the side menu (hamburger menu) of the app
class SideMenuViewController: UIViewController {

    // MARK: - Types

    private enum SideMenuError: Error {
        case menuSwipeRecognizerViewNil
    }

    // MARK: - Public Properties

    weak var delegate: SideMenuViewControllerDelegate?

    // MARK: - Private Properties

    @IBOutlet private var tableViewBackgroundView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var footerView: SideMenuFooterView!
    
    private var tapToCloseGestureRecognizerVC: UITapGestureRecognizer!
    private var tapToCloseGestureRecognizerTabBar: UITapGestureRecognizer!

    private let disposeBag = DisposeBag()
    
    private lazy var presenter: SideMenuPresenter = {
        SideMenuPresenter()
    }()

    private var sideMenuItems: [SideMenuItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let recorder: ErrorRecording = CrashlyticsRecorder()
    private let analyticsRecorder: AnalyticsEventRecording = resolve()

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.NavigationBar.LightContent.background
        tableViewBackgroundView.backgroundColor = UIColor.NavigationBar.LightContent.background
        AppCoordinator.shared.slidingViewController.delegate = self
        tapToCloseGestureRecognizerTabBar = UITapGestureRecognizer(
            target: AppCoordinator.shared,
            action: #selector(AppCoordinator.shared.toggleSideMenu)
        )
        tapToCloseGestureRecognizerVC = UITapGestureRecognizer(
            target: AppCoordinator.shared,
            action: #selector(AppCoordinator.shared.toggleSideMenu)
        )
        registerCells()
        initializeTableView()
        addShadow()
        
        presenter.sideMenuItems
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.sideMenuItems = items
            })
            .disposed(by: disposeBag)

        presenter.sideMenuFooterItems
            .bind(onNext: { [weak self] items in
                self?.footerView.model = .init(top: items.top, bottom: items.bottom)
            })
            .disposed(by: disposeBag)

        footerView.itemTapped
            .emit(weak: self) { (self, item) in
                self.didTapItem(item)
            }
            .disposed(by: disposeBag)
        
        presenter.itemSelection
            .emit(weak: self) { (self, item) in
                self.didTapItem(item)
            }
            .disposed(by: disposeBag)
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
        tableView?.reloadData()
    }

    // MARK: - Private Methods

    private func didTapItem(_ item: SideMenuItem) {
        analyticsRecorder.record(event: item.analyticsEvent)
        delegate?.sideMenuViewController(self, didTapOn: item)
    }
    
    private func registerCells() {
        tableView.registerNibCell(SideMenuCell.self)
    }

    private func initializeTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func addShadow() {
        guard let view = AppCoordinator.shared.slidingViewController.topViewController.view else { return }
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
    }

    private func setSideMenuGestures() {
        guard let tabControllerManager = AppCoordinator.shared.tabControllerManager else { return }
        let tabViewController = tabControllerManager.tabViewController

        if let menuSwipeRecognizerView = tabViewController.menuSwipeRecognizerView {
            menuSwipeRecognizerView.isUserInteractionEnabled = false
        } else { // Record an error but continue - suspected crash
            recorder.error(SideMenuError.menuSwipeRecognizerViewNil)
        }
        
        // Enable Pan gesture and tap gesture to close sideMenu
        guard let slidingViewController = AppCoordinator.shared.slidingViewController else {
            return
        }
        
        if let activeViewController = tabViewController.activeViewController {
            // Disable all interactions on main view
            activeViewController.view.subviews.forEach {
                $0.isUserInteractionEnabled = false
            }
            activeViewController.view.isUserInteractionEnabled = true
            activeViewController.view.addGestureRecognizer(slidingViewController.panGesture)
            activeViewController.view.addGestureRecognizer(tapToCloseGestureRecognizerVC)
        }

        tabViewController.addTapGestureRecognizerToTabBar(tapToCloseGestureRecognizerTabBar)
    }

    private func resetSideMenuGestures() {
        guard let tabControllerManager = AppCoordinator.shared.tabControllerManager else { return }
        let tabViewController = tabControllerManager.tabViewController
        guard let slidingViewController = AppCoordinator.shared.slidingViewController else { return }
        if let activeViewController = tabViewController.activeViewController {
            activeViewController.view.removeGestureRecognizer(slidingViewController.panGesture)
            activeViewController.view.removeGestureRecognizer(tapToCloseGestureRecognizerVC)
            activeViewController.view.subviews.forEach {
                $0.isUserInteractionEnabled = true
            }
        }

        tabViewController.removeTapGestureRecognizerToTabBar(tapToCloseGestureRecognizerTabBar)

        // Enable swipe to open side menu gesture on small bar on the left of main view
        tabViewController.menuSwipeRecognizerView.isUserInteractionEnabled = true
        tabViewController.menuSwipeRecognizerView.addGestureRecognizer(slidingViewController.panGesture)
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sideMenuItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        SideMenuCell.defaultHeight
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
        presenter.onItemSelection(item)
        tableView.deselectRow(at: indexPath, animated: true)
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
