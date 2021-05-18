//
//  FiatBalanceCollectionView.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import UIKit

final class FiatBalanceCollectionView: UICollectionView {

    // MARK: - Injected
   
    public var presenter: FiatBalanceCollectionViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            presenter.presenters
                .drive(rx.items(
                    cellIdentifier: FiatCustodialBalanceCollectionViewCell.objectName,
                    cellType: FiatCustodialBalanceCollectionViewCell.self),
                       curriedArgument: { _, presenter, cell in
                        cell.presenter = presenter
                    }
                )
                .disposed(by: disposeBag)

            rx.modelSelected(FiatCustodialBalanceViewPresenter.self)
                .subscribe(onNext: {
                    presenter.selected(currencyType: $0.currencyType)
                })
                .disposed(by: disposeBag)
        }
    }

    public let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = CGSize(width: 300, height: 70)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.scrollDirection = .horizontal
        flow.sectionInset = .zero
        return flow
    }()
    
    // MARK: - Private Properties
    
    private var disposeBag = DisposeBag()
   
    // MARK: - Lifecycle

    public init() {
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: collectionViewFlowLayout)
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        register(FiatCustodialBalanceCollectionViewCell.self)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }
}
