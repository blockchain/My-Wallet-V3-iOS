//
//  WalletUpgradeViewController.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class WalletUpgradeViewController: UIViewController {

    // MARK: Private Properties

    private let presenter: WalletUpgradePresenter
    private let label = UILabel()
    private let loading = UIActivityIndicatorView(style: .whiteLarge)
    private let disposeBag = DisposeBag()

    // MARK: Init

    public init(presenter: WalletUpgradePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    // MARK: Methods

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loading)
        loading.layout(edge: .bottom, to: .centerY, of: view, offset: -8)
        loading.layout(edges: .centerX, to: view)
        loading.layout(size: .edge(50))
        loading.startAnimating()
        
        view.addSubview(label)
        label.numberOfLines = 0
        label.layout(edge: .top, to: .bottom, of: loading, offset: 8)
        label.layoutToSuperview(.leading, .trailing)

        presenter.viewModel
            .map(\.loadingIndicator)
            .drive(loading.rx.visibility)
            .disposed(by: disposeBag)

        presenter.viewModel
            .map(\.labelContent)
            .drive(label.rx.content)
            .disposed(by: disposeBag)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
}
