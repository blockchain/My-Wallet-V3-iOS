//
//  RadioLineItemCellPresenter.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/23/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

public final class RadioLineItemCellPresenter: IdentifiableType {
    
    // MARK: - Public Properties
    
    /// The image corresponding to `imageName`
    public let image: Driver<UIImage?>
    
    // MARK: - RxDataSources
    
    public let identity: AnyHashable
    
    /// Selection relay
    public let selectedRelay = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Internal
    
    /// The `viewModel` for the `LineItemView`
    let viewModel: Driver<LineItemViewViewModel>
    
    /// Name for radio image
    let imageName = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Init
    
    public init(title: String,
                subtitle: String,
                selected: Bool = false) {
        let model: LineItemViewViewModel = .init(
            title: title,
            subtitle: subtitle
        )
        viewModel = .just(model)
        identity = model.identifier
        image = Observable
            .merge(selectedRelay.asObservable(), Observable.just(selected))
            .map { $0 ? "checkbox-selected" : "checkbox-empty" }
            .asDriver(onErrorJustReturn: nil)
            .map { name in
                if let name = name {
                    return UIImage(named: name, in: .platformUIKit, compatibleWith: nil)
                }
                return nil
            }
    }
}

extension RadioLineItemCellPresenter: Equatable {
    public static func == (lhs: RadioLineItemCellPresenter, rhs: RadioLineItemCellPresenter) -> Bool {
        lhs.identity == rhs.identity &&
        lhs.selectedRelay.value == rhs.selectedRelay.value
    }
}