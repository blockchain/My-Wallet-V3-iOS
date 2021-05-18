//
//  SideMenuFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 2/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

struct SideMenuFooterViewModel {
    let top: SideMenuItem
    let bottom: SideMenuItem
}

/// `SideMenuFooterView` is shown at the base of `SideMenuViewController`. It's not
/// really a footer view (though it could be used as one). But it's only supposed to be shown at the bottom
/// of said screen (per the designs).
class SideMenuFooterView: NibBasedView {

    var itemTapped: Signal<SideMenuItem> {
        itemRelay.asSignal()
    }
    var model: SideMenuFooterViewModel! {
        didSet {
            topButton.setTitle(model.top.title, for: .normal)
            topButton.setImage(model.top.image, for: .normal)
            bottomButton.setTitle(model.bottom.title, for: .normal)
            bottomButton.setImage(model.bottom.image, for: .normal)
        }
    }

    @IBOutlet private var topButton: UIButton!
    @IBOutlet private var bottomButton: UIButton!
    @IBOutlet private var buttonHeightConstraints: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    private let itemRelay: PublishRelay<SideMenuItem> = .init()

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonHeightConstraints.constant = SideMenuCell.defaultHeight

        let font = UIFont.main(.medium, DevicePresenter.type == .superCompact ? 14 : 17)
        topButton.titleLabel?.font = font
        bottomButton.titleLabel?.font = font

        topButton.rx.tap
            .compactMap { [weak self] _ in
                self?.model?.top
            }
            .bind(to: itemRelay)
            .disposed(by: disposeBag)

        bottomButton.rx.tap
            .compactMap { [weak self] _ in
                self?.model?.bottom
            }
            .bind(to: itemRelay)
            .disposed(by: disposeBag)
    }
}
