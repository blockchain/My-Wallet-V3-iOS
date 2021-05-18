//
//  TransactionFlowViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 25/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs
import RxSwift
import ToolKit
import UIKit

protocol TransactionFlowPresentableListener: AnyObject {
    func closeFlow()
}

protocol TransactionFlowPresentable: Presentable {
    var listener: TransactionFlowPresentableListener? { get set }
}

final class TransactionFlowInitialViewController: BaseScreenViewController {}

final class TransactionFlowViewController: UINavigationController, TransactionFlowPresentable, TransactionFlowViewControllable {

    weak var listener: TransactionFlowPresentableListener?

    init() {
        let root = TransactionFlowInitialViewController()
        root.barStyle = .darkContent()
        super.init(nibName: nil, bundle: nil)
        viewControllers = [root]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // so that we'll be able to listen for system dismissal methods
        presentationController?.delegate = self
    }

    func replaceRoot(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: animated)
    }

    func push(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        pushViewController(viewController.uiviewController, animated: true)
    }

    func pop() {
        popViewController(animated: true)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension TransactionFlowViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when a pull-down dismissal happens
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        listener?.closeFlow()
    }
}
