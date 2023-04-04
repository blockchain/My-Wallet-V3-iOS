// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import UIKit

/// A container for `AddressViewController`s and `PinScreenViewController` instances
final class LoginContainerViewController: UIViewController {

    // MARK: Types

    enum Input {
        case view(UIView)
        case viewController(UIViewController)

        var view: UIView {
            switch self {
            case .view(let view):
                return view
            case .viewController(let viewController):
                return viewController.view
            }
        }

        var viewController: UIViewController? {
            switch self {
            case .viewController(let vc):
                return vc
            case .view:
                return nil
            }
        }

        var navigationItem: UINavigationItem? {
            switch self {
            case .viewController(let vc):
                return vc.navigationItem
            case .view:
                return nil
            }
        }
    }

    /// The flow layout of the collection view
    private class CollectionViewFlowLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
            itemSize = UIScreen.main.bounds.size
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            scrollDirection = .horizontal
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            unimplemented()
        }
    }

    // MARK: - Properties

    private lazy var collectionViewFlowLayout = CollectionViewFlowLayout()
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var pageControl: UIPageControl!

    private var isPageControlCurrentlyInteracted = false

    private let inputs: [Input]
    private let translationAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)

    // MARK: - Lifecycle

    init(using inputs: [Input]) {
        self.inputs = inputs
        super.init(nibName: String(describing: LoginContainerViewController.self), bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    override var navigationItem: UINavigationItem {
        let input = inputs.first(where: { input in
            if case .viewController = input {
                return true
            }
            return false
        })
        return input?.navigationItem ?? UINavigationItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = collectionViewFlowLayout
        collectionView.delegate = self
        collectionView.registerNibCell(LoginContainerCollectionViewCell.self, in: .module)
        pageControl.pageIndicatorTintColor = .addressPageIndicator
        pageControl.currentPageIndicatorTintColor = .tertiary
        pageControl.currentPage = 0
        pageControl.numberOfPages = inputs.count - 1
        pageControl.alpha = 0
        pageControl.accessibility = .id(AccessibilityIdentifiers.Address.pageControl)
        translationAnimator.pausesOnCompletion = true
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Following an issue that occurred only on iPhone 5 + iOS 10, that the PIN gets stretched,
        // need to refresh the collection view layout when the view appears
        prepareCollectionViewLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        translationAnimator.stopAnimation(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareCollectionViewLayout()
    }

    private func prepareCollectionViewLayout() {
        collectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width,
            height: pageControl.frame.minY - view.layoutMargins.top
        )
        collectionViewFlowLayout.invalidateLayout()
    }

    private func didFinishScrolling() {
        let isNavigationEnabled = collectionView.contentOffset.x == 0
        navigationItem.leftBarButtonItem?.isEnabled = isNavigationEnabled
        navigationItem.rightBarButtonItem?.isEnabled = isNavigationEnabled
        isPageControlCurrentlyInteracted = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    /// Returns the currently displayed item index
    private var currentItemIndex: Int {
        let offset = collectionView.contentOffset.x + collectionView.bounds.width * 0.5
        let contentWidth = collectionView.contentSize.width * CGFloat(inputs.count)
        if contentWidth == 0 {
            return 0
        }
        return Int(offset / contentWidth)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension LoginContainerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        inputs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: LoginContainerCollectionViewCell.self),
            for: indexPath
        ) as! LoginContainerCollectionViewCell

        let input = inputs[indexPath.row]
        if let viewController = input.viewController {
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
        cell.input = input
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension LoginContainerViewController {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        var firstTouch = true
        translationAnimator.addAnimations { [weak self] in
            guard let self else { return }
            guard firstTouch else {
                return
            }
            firstTouch = false
            view.backgroundColor = .white
            pageControl.alpha = 1
            navigationItem.titleView?.alpha = 0
            navigationItem.leftBarButtonItem?.tintColor = .clear
            navigationItem.rightBarButtonItem?.tintColor = .clear
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didFinishScrolling()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        didFinishScrolling()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let visibleRect = scrollView.bounds
        let expectedRect = CGRect(
            x: CGFloat(pageControl.currentPage + 1) * scrollView.contentOffset.x,
            y: scrollView.bounds.minY,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )
        guard visibleRect == expectedRect else { return }
        didFinishScrolling()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.bounds.width
        let normalizedOffset = max(min(scrollView.contentOffset.x, maxOffset), 0)
        let fraction = min(normalizedOffset / maxOffset, 0.99)
        translationAnimator.fractionComplete = fraction

        if !isPageControlCurrentlyInteracted, scrollView.contentSize.width > 0 {
            let offset = scrollView.contentOffset.x - scrollView.bounds.width * 0.5
            let page = Int(offset / scrollView.contentSize.width * CGFloat(inputs.count))
            pageControl.currentPage = max(page, 0)
        }
    }
}

// MARK: - User Actions

extension LoginContainerViewController {
    @IBAction private func didSelectPage(pageControl: UIPageControl) {
        isPageControlCurrentlyInteracted = true
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
