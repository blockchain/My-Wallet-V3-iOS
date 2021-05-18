//
//  BaseScreenViewController.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

open class BaseScreenViewController: UIViewController {
    
    // MARK: - Types
    
    private struct Constant {
        static let titleViewHeight: CGFloat = 40
    }
    
    // MARK: - Exposed
    
    /**
     The style of the navigation bar.
     Defines the background, and the content colors.
     */
    public var barStyle: Screen.Style.Bar = .lightContent() {
        didSet {
            baseNavigationController?.navigationBar.titleTextAttributes = barStyle.titleTextAttributes
            baseNavigationController?.navigationBar.isTranslucent = barStyle.isTranslucent
            setBackground(by: barStyle)
        }
    }

    /**
     The title style of the navigation bar.
     By setting this property, the title of the navigation bar
     readjusts its content.
     Also, if the title is `.none` - it becomes hidden
     */
    public var titleViewStyle = Screen.Style.TitleView.none {
        didSet {
            set(titleViewStyle: titleViewStyle)
        }
    }

    /// Indicates if the view controller should extend safe area under the navigation bar.
    /// This is achieved by making `additionalSafeAreaInsets.top` the negative of navigation bar height.
    public var extendSafeAreaUnderNavigationBar = false {
        didSet {
            if oldValue != extendSafeAreaUnderNavigationBar {
                viewIfLoaded?.setNeedsLayout()
            }
        }
    }

    /**
     The style of the left button in the navigation bar.
     By setting this property, the left button of the navigation bar
     readjusts its color and content (image / title).
     Also, if *leftButtonStyle* is *.none*, The left button becomes hidden
     */
    public var leadingButtonStyle = Screen.Style.LeadingButton.none {
        didSet {
            let itemType: NavigationBarButtonItem.ItemType
            if let content = leadingButtonStyle.content {
                itemType = NavigationBarButtonItem.ItemType.content(content: content) { [weak self] in
                    self?.navigationBarLeadingButtonPressed()
                }
            } else {
                itemType = .none
            }
            leadingBarButtonItem = NavigationBarButtonItem(type: itemType, color: barStyle.tintColor)
        }
    }
    
    /**
     The style of the right button in the navigation bar.
     By setting this property, the right button of the navigation bar
     readjusts its color and content (image / title).
     Also, if *rightButtonStyle* is *.none*, The right button becomes hidden,
     in that case, it won't be an accessibility element.
     */
    public var trailingButtonStyle = Screen.Style.TrailingButton.none {
        didSet {
            let itemType: NavigationBarButtonItem.ItemType
            var color = barStyle.tintColor
            switch trailingButtonStyle {
            case .content(let content):
                
                itemType = .content(content: content) { [weak self] in
                    self?.navigationBarTrailingButtonPressed()
                }
            case .processing:
                itemType = .processing
            case .qrCode:
                itemType = .content(content: trailingButtonStyle.content!) { [weak self] in
                    self?.navigationBarTrailingButtonPressed()
                }
            case .close:
                itemType = .content(content: trailingButtonStyle.content!) { [weak self] in
                    self?.navigationBarTrailingButtonPressed()
                }
                color = UIColor.NavigationBar.closeButton
            case .none:
                itemType = .none
            }
            trailingBarButtonItem = NavigationBarButtonItem(type: itemType, color: color)
        }
    }
    
    // MARK: - Private
    
    /// The ancestor navigation controller
    private weak var _baseNavigationController: UINavigationController?
    private var baseNavigationController: UINavigationController? {
        if _baseNavigationController == nil {
            var result: UIViewController? = self
            while result != nil && !(result is UINavigationController) {
                result = result?.parent
            }
            _baseNavigationController = result as? UINavigationController
        }
        return _baseNavigationController
    }

    private var currentNavigationItem: UINavigationItem? {
        navigationItem
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        loadViewIfNeeded()
        return determineStatusBarStyle()
    }
    
    private var trailingBarButtonItem: UIBarButtonItem! {
        didSet {
            currentNavigationItem?.setRightBarButton(trailingBarButtonItem, animated: false)
        }
    }
    
    private(set) var leadingBarButtonItem: UIBarButtonItem! {
        didSet {
            currentNavigationItem?.setLeftBarButton(leadingBarButtonItem, animated: false)
        }
    }

    private func updateExtendSafeAreaUnderNavigationBar() {
        guard isViewLoaded else {
            // Do not trigger if view is not loaded.
            return
        }
        let navigationBarHeight: CGFloat
        if extendSafeAreaUnderNavigationBar {
            navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        } else {
            navigationBarHeight = 0
        }
        additionalSafeAreaInsets.top = -navigationBarHeight
    }

    // MARK: - Lifecycle
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackground(by: barStyle)
        if !barStyle.ignoresStatusBar {
            UIApplication.shared.statusBarStyle = determineStatusBarStyle()
        }
        currentNavigationItem?.setHidesBackButton(true, animated: false)
    }

    open override func viewWillLayoutSubviews() {
        updateExtendSafeAreaUnderNavigationBar()
        super.viewWillLayoutSubviews()
    }
        
    // MARK: - Setup
    
    private func determineStatusBarStyle() -> UIStatusBarStyle {
        if isPresentedModally {
            return .lightContent
        }
        switch barStyle {
        case .lightContent:
            return .lightContent
        case .darkContent:
            return .default
        }
    }
    
    private func setBackground(by style: Screen.Style.Bar) {
        let animation = CATransition()
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.type = .fade
        baseNavigationController?.navigationBar.layer.add(animation, forKey: nil)
        baseNavigationController?.navigationBar.setBackgroundImage(
            .image(color: style.backgroundColor, size: view.bounds.size),
            for: .default
        )
        baseNavigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func set(titleViewStyle: Screen.Style.TitleView) {
        guard let navigationItem = currentNavigationItem else {
            return
        }
        
        switch titleViewStyle {
        case .text(value: let text):
            navigationItem.titleView = nil
            navigationItem.title = text
        case .image(name: let image, width: let width):
            let view = UIImageView(image: UIImage(named: image))
            view.contentMode = .scaleAspectFit
            view.layout(size: CGSize(width: width, height: Constant.titleViewHeight))
            navigationItem.titleView = view
            navigationItem.title = nil
        case .view(value: let titleView):
            navigationItem.title = nil
            navigationItem.titleView = titleView
        case .none:
            navigationItem.titleView = nil
            navigationItem.title = nil
        }
    }
    
    // MARK: - Exposed
    
    public var standardNavigationBarButtonStyles: (leading: Screen.Style.LeadingButton, trailing: Screen.Style.TrailingButton) {
        var trailing: Screen.Style.TrailingButton = .none
        var leading: Screen.Style.LeadingButton = .none
        let viewControllersCount = navigationController?.viewControllers.count ?? 1
        if viewControllersCount > 1 {
            leading = .back
        } else {
            trailing = .close
        }
        return (leading, trailing)
    }

    public func setStandardDarkContentStyle() {
        let (leading, trailing) = standardNavigationBarButtonStyles
        set(barStyle: .darkContent(),
            leadingButtonStyle: leading,
            trailingButtonStyle: trailing)
    }

    public func setStandardLightContentStyle() {
        let (leading, trailing) = standardNavigationBarButtonStyles
        set(barStyle: .lightContent(),
            leadingButtonStyle: leading,
            trailingButtonStyle: trailing)
    }
    
    public func set(barStyle: Screen.Style.Bar,
                    leadingButtonStyle: Screen.Style.LeadingButton = .none,
                    trailingButtonStyle: Screen.Style.TrailingButton = .none) {
        self.barStyle = barStyle
        self.leadingButtonStyle = leadingButtonStyle
        self.trailingButtonStyle = trailingButtonStyle
    }
    
    public func setNavigationBar(visible: Bool) {
        baseNavigationController?.navigationBar.isHidden = !visible
        baseNavigationController?.isNavigationBarHidden = !visible
    }
    
    // MARK: - User Interaction

    open func navigationBarTrailingButtonPressed() {
        switch trailingButtonStyle {
        case .close:
            dismiss(animated: true, completion: nil)
        case .none, .processing, .qrCode, .content:
            break
        }
    }

    private lazy var drawerRouter: DrawerRouting = resolve()
    open func navigationBarLeadingButtonPressed() {
        switch leadingButtonStyle {
        case .back:
            baseNavigationController?.popViewController(animated: true)
        case .close:
            dismiss(animated: true, completion: nil)
        case .drawer:
            drawerRouter.toggleSideMenu()
        case .none,
             .text:
            break
        }
    }
    
    public func removeFromHierarchy() {
        switch (leadingButtonStyle, trailingButtonStyle) {
        case (.close, _), (_, .close):
            dismiss(animated: true, completion: nil)
        case (.back, _):
            baseNavigationController?.popViewController(animated: true)
        default:
            if isPresentedModally {
                dismiss(animated: true, completion: nil)
            } else {
                baseNavigationController?.popViewController(animated: true)
            }
        }
    }
}
