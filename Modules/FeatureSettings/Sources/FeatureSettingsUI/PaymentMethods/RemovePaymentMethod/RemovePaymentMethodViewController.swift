// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxSwift
import ToolKit

final class RemovePaymentMethodViewController: UIViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var buttonView: ButtonView!

    // MARK: - Injected

    private let presenter: RemovePaymentMethodScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(presenter: RemovePaymentMethodScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: RemovePaymentMethodViewController.objectName, bundle: .module)
    }

    required init?(coder: NSCoder) { unimplemented() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .semantic.background

        buttonView.viewModel = presenter.removeButtonViewModel
        badgeImageView.viewModel = presenter.badgeImageViewModel
        titleLabel.content = presenter.titleLabelContent
        descriptionLabel.content = presenter.descriptionLabelContent

        presenter.dismissal
            .emit(weak: self) { (self) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        presenter.viewDidLoad()
    }
}
