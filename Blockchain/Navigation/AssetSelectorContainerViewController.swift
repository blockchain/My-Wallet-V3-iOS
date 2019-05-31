//
//  AssetSelectorContainerViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol AssetSelectorContainerDelegate: class {
    func assetSelectorContainer(_ viewController: AssetSelectorContainerViewController, selectedAsset: LegacyAssetType)
    func assetSelectorContainer(_ viewController: AssetSelectorContainerViewController, tappedQRReaderFor assetType: LegacyAssetType)
}

/// `AssetSelectorContainerViewController` is used on `Send`, `Request`, and `Activity`
/// screens. You add a `UIViewController` to display a screen within a container that shows
/// a `AssetSelectorView` on top. This VC is shared across `Send`, `Request`, and `Activity`.
class AssetSelectorContainerViewController: UIViewController {
    
    // MARK: Public Properties
    
    @objc weak var delegate: AssetSelectorContainerDelegate?
    
    @objc var currentAsset: LegacyAssetType = .bitcoin {
        didSet {
            if assetSelector != nil {
                assetSelector.selectedAsset = currentAsset
                assetSelector.reload()
            }
        }
    }
    
    // MARK: Private IBOutlets
    
    @IBOutlet var assetSelector: AssetSelectorView!
    @IBOutlet var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assetSelector.selectedAsset = currentAsset
        assetSelector.reload()
        assetSelector.delegate = self
        assetSelector.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Public
    
    func hideSelector() {
        assetSelector.close()
    }
    
    func showSelector() {
        assetSelector.open()
    }
    
    @objc func insert(viewController: UIViewController) {
        children.forEach({ $0.willMove(toParent: nil) })
        children.forEach({ $0.view.removeFromSuperview() })
        children.forEach({ $0.removeFromParent() })
        addChild(viewController)
        containerView.addConstrainedSubview(viewController.view)
        viewController.didMove(toParent: self)
        setupTitle()
    }
    
    fileprivate func setupTitle() {
        let index = Int(AppCoordinator.shared.tabControllerManager.tabViewController.selectedIndex())
        switch index {
        case Constants.Navigation.tabTransactions:
            title = LocalizationConstants.Dashboard.activity
        case Constants.Navigation.tabSend:
            title = LocalizationConstants.Dashboard.send
        case Constants.Navigation.tabReceive:
            title = LocalizationConstants.Dashboard.request
        default:
            title = nil
        }
    }
}

extension AssetSelectorContainerViewController: AssetSelectorViewDelegate {
    func didSelect(_ assetType: LegacyAssetType) {
        delegate?.assetSelectorContainer(self, selectedAsset: assetType)
    }
    
    func didOpenSelector() {
        // TODO: Likely not needed. We are no longer shifting the view down
        // when the selector opens. 
    }
}

extension AssetSelectorContainerViewController: NavigatableView {
    
    var rightNavControllerCTAType: NavigationCTAType {
        if let child = children.first as? NavigatableView {
            return child.rightNavControllerCTAType
        }
        
        return .qrCode
    }
    
    var rightCTATintColor: UIColor {
        if let child = children.first as? NavigatableView {
            return child.rightCTATintColor
        }
        
        return .white
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        if let child = children.first as? NavigatableView {
            return child.navControllerRightBarButtonTapped(navController)
        }
        
        delegate?.assetSelectorContainer(self, tappedQRReaderFor: currentAsset)
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        AppCoordinator.shared.toggleSideMenu()
    }
}
