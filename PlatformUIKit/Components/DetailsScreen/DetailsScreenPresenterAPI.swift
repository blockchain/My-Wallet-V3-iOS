//
//  DetailsScreenPresenterAPI.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

public protocol HeaderBuilder {
    var defaultHeight: CGFloat { get }
    func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView?
}

public protocol DetailsScreenPresenterAPI: AnyObject {

    var buttons: [ButtonViewModel] { get }
    var cells: [DetailsScreen.CellType] { get }

    var extendSafeAreaUnderNavigationBar: Bool { get }
    var titleView: Driver<Screen.Style.TitleView> { get }
    var titleViewRelay: BehaviorRelay<Screen.Style.TitleView> { get }
    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance { get }
    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction { get }
    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction { get }

    var reloadRelay: PublishRelay<Void> { get }
    var reload: Signal<Void> { get }

    func viewDidLoad()
    func header(for section: Int) -> HeaderBuilder?
}

public extension DetailsScreenPresenterAPI {

    var extendSafeAreaUnderNavigationBar: Bool { false }
    
    var buttons: [ButtonViewModel] { [] }

    var titleView: Driver<Screen.Style.TitleView> {
        titleViewRelay.asDriver()
    }
    
    var reload: Signal<Void> {
        reloadRelay.asSignal()
    }

    func viewDidLoad() { /* NOOP */ }
    
    func header(for section: Int) -> HeaderBuilder? { nil }
}

