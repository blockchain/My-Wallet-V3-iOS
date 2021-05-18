//
//  MultiActionViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// `MultiActionViewPresenting` represents a `MultiActionView`.
/// There are two types, `primary` as well as `default`.
/// They both use different `SegmentedViewModel` stylings.
public protocol MultiActionViewPresenting {
    /// The view model for the `SegmentedView`
    var segmentedViewModel: SegmentedViewModel { get }
}

public final class PlainActionViewPresenter: MultiActionViewPresenting {
    
    public var segmentedViewModel: SegmentedViewModel

    // MARK: - Setup
    
    public init(using items: [SegmentedViewModel.Item]) {
        self.segmentedViewModel = .plain(items: items, isMomentary: true)
    }
}

public final class DefaultActionViewPresenter: MultiActionViewPresenting {
    
    public var segmentedViewModel: SegmentedViewModel

    // MARK: - Setup
    
    public init(using items: [SegmentedViewModel.Item]) {
        segmentedViewModel = .default(items: items, isMomentary: false)
    }
}
