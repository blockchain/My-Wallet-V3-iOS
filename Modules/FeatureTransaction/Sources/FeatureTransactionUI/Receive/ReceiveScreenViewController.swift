// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import DIKit
import FeatureTransactionDomain
import Localization
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

final class ReceiveScreenViewController: BaseScreenViewController {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    private let assetImageView = BadgeImageView()
    private let thumbImageView = UIImageView()

    private let qrCodeImageView = UIImageView()

    private let alertCardView = UIView()
    private let domainItem = ItemView()
    private let addressItem = ItemView()
    private let memoItem = ItemView()
    private let memoNoteContainer = UIView()
    private let memoNoteTextView = InteractableTextView()
    private let copyButton = ButtonView()
    private let shareButton = ButtonView()

    private var memoNoteContainerHeightConstraint: NSLayoutConstraint!
    private var copyButtonToMemoNoteConstraint: NSLayoutConstraint!
    private var contentSizeObserver: NSKeyValueObservation?

    private var copyButtonTopOffset: CGFloat {
        switch DevicePresenter.type {
        case .superCompact:
            return 0
        case .compact,
             .regular,
             .max:
            return 32
        }
    }

    private let presenter: ReceiveScreenPresenter
    private let disposeBag = DisposeBag()

    init(presenter: ReceiveScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        unimplemented()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()

        // Prevent unnecessary rendering
        displayMemo(show: false)
        domainItem.show(false)

        setupPresenter()
    }

    private func setupPresenter() {
        domainItem.headerLabel.content = presenter.walletDomainLabelContent
        addressItem.headerLabel.content = presenter.walletAddressLabelContent
        memoItem.headerLabel.content = presenter.memoLabelContent

        presenter.domainLabelContentPresenting
            .state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.domainItem.show(!content.labelContent.text.isEmpty)
                    self?.domainItem.contentLabel.content = content.labelContent
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                case .loading:
                    self?.domainItem.contentLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.alertContentRelay
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .take(1)
            .subscribe(onNext: { [weak self] content in
                self?.installAlert(title: content.title, subtitle: content.subtitle)
            })
            .disposed(by: disposeBag)

        presenter.addressLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.addressItem.contentLabel.content = content.labelContent
                case .loading:
                    self?.addressItem.contentLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.memoLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.displayMemo(show: !content.labelContent.text.isEmpty)
                    self?.memoItem.contentLabel.content = content.labelContent
                case .loading:
                    self?.memoItem.contentLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.balanceLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.balanceLabel.content = content.labelContent
                case .loading:
                    self?.balanceLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.nameLabelContentPresenting
            .state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loaded(next: let content):
                    self?.nameLabel.content = content.labelContent
                case .loading:
                    self?.nameLabel.text = nil
                }
            })
            .disposed(by: disposeBag)

        presenter.qrCode
            .drive(qrCodeImageView.rx.image)
            .disposed(by: disposeBag)

        copyButton.viewModel = presenter.copyButton
        shareButton.viewModel = presenter.shareButton

        presenter.assetImage
            .drive(assetImageView.rx.viewModel)
            .disposed(by: disposeBag)
    }

    private func displayMemo(show: Bool) {
        memoNoteContainer.isHidden = !show
        memoItem.show(show)
        memoNoteContainerHeightConstraint.isActive = !show
        copyButtonToMemoNoteConstraint.constant = show ? 16 : copyButtonTopOffset
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setupNavigationBar() {
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
        titleViewStyle = .text(value: presenter.title)
    }

    private func installAlert(title: String, subtitle: String) {
        alertCardView.isHidden = false
        let alertCard = AlertCard(
            title: title,
            message: subtitle
        )
        let hostingController = UIHostingController(rootView: alertCard)
        hostingController.view.invalidateIntrinsicContentSize()
        addChild(hostingController)
        alertCardView.addSubview(hostingController.view)
        let insets = UIEdgeInsets(horizontal: 24, vertical: 8)
        hostingController.view.constraint(
            edgesTo: alertCardView,
            insets: insets
        )
        hostingController.didMove(toParent: self)
    }

    private func setupView() {
        view.backgroundColor = .white

        // MARK: Add Subviews

        view.addSubview(scrollView)

        // MARK: Scroll View

        scrollView.layoutToSuperview(.leading, .trailing, .top, .bottom, usesSafeAreaLayoutGuide: true)
        scrollView.addSubview(contentView)

        // MARK: Content View

        contentView.layoutToSuperview(.leading, .trailing, .top, .bottom, .width)
        contentView.layoutToSuperview(.height, relation: .greaterThanOrEqual)
        contentView.addSubview(nameLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(thumbImageView)
        contentView.addSubview(assetImageView)
        contentView.addSubview(qrCodeImageView)
        contentView.addSubview(domainItem)
        contentView.addSubview(addressItem)
        contentView.addSubview(alertCardView)
        contentView.addSubview(memoItem)
        contentView.addSubview(memoNoteContainer)
        contentView.addSubview(copyButton)
        contentView.addSubview(shareButton)

        // MARK: Wallet Name

        nameLabel.layoutToSuperview(.top, offset: 9)
        nameLabel.layoutToSuperview(.leading, offset: 24)
        nameLabel.layout(dimension: .height, to: 24)

        // MARK: Wallet Balance

        balanceLabel.layout(edge: .top, to: .bottom, of: nameLabel)
        balanceLabel.layoutToSuperview(.leading, offset: 24)
        balanceLabel.layout(dimension: .height, to: 21)

        // MARK: Receive Icon Image

        thumbImageView.layout(dimension: .width, to: 24)
        thumbImageView.layout(dimension: .height, to: 24)
        thumbImageView.layoutToSuperview(.trailing, offset: -24)
        thumbImageView.layoutToSuperview(.top, offset: 20)
        thumbImageView.set(
            ImageViewContent(imageResource: ImageAsset.iconReceiveGray.imageResource)
        )

        // MARK: Asset Image

        assetImageView.layout(dimension: .width, to: 32)
        assetImageView.layout(dimension: .height, to: 32)
        assetImageView.layout(edge: .centerY, to: .centerY, of: thumbImageView)
        assetImageView.layout(edge: .trailing, to: .leading, of: thumbImageView, offset: 4)

        // MARK: Share Button

        shareButton.layout(dimension: .height, to: ButtonSize.Standard.height)
        shareButton.layoutToSuperview(axis: .horizontal, offset: 24)
        shareButton.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -16)
        shareButton.layout(edge: .top, to: .bottom, of: copyButton, offset: 16)

        // MARK: Copy Button

        copyButton.layout(dimension: .height, to: ButtonSize.Standard.height)
        copyButton.layoutToSuperview(axis: .horizontal, offset: 24)
        copyButtonToMemoNoteConstraint = copyButton.layout(edge: .top, to: .bottom, of: memoNoteContainer, offset: copyButtonTopOffset)

        // MARK: Memo Note Container

        memoNoteContainer.backgroundColor = .mediumBackground
        memoNoteContainer.layer.cornerRadius = 8
        memoNoteContainer.layoutToSuperview(axis: .horizontal, offset: 24)
        memoNoteContainer.layout(edge: .top, to: .bottom, of: memoItem)
        memoNoteContainerHeightConstraint = memoNoteContainer.layout(dimension: .height, to: 0, activate: false)
        memoNoteContainer.addSubview(memoNoteTextView)

        // MARK: Memo Note

        memoNoteTextView.viewModel = presenter.memoNoteViewModel
        memoNoteTextView.backgroundColor = .clear
        memoNoteTextView.layoutToSuperview(axis: .horizontal, offset: 12)
        memoNoteTextView.layoutToSuperview(axis: .vertical, offset: 12)

        // MARK: Memo Item

        memoItem.layoutToSuperview(axis: .horizontal)
        memoItem.layout(edge: .top, to: .bottom, of: alertCardView)

        // MARK: Domain Item

        domainItem.layoutToSuperview(axis: .horizontal)

        // MARK: Address Item

        addressItem.layoutToSuperview(axis: .horizontal)
        addressItem.layout(edge: .top, to: .bottom, of: domainItem)

        // MARK: Alert Card View

        alertCardView.layoutToSuperview(axis: .horizontal)
        alertCardView.layout(edge: .top, to: .bottom, of: addressItem)

        // MARK: QRCode ImageView

        qrCodeImageView.layout(dimension: .width, to: 200)
        qrCodeImageView.layout(dimension: .height, to: 200)
        qrCodeImageView.layoutToSuperview(.centerX)
        qrCodeImageView.contentMode = .scaleAspectFit

        // MARK: UILayoutGuide for QRCodeImageView

        let topGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
        contentView.addLayoutGuide(topGuide)
        contentView.addLayoutGuide(bottomGuide)
        NSLayoutConstraint.activate([
            topGuide.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            topGuide.bottomAnchor.constraint(equalTo: qrCodeImageView.topAnchor),
            bottomGuide.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor),
            bottomGuide.bottomAnchor.constraint(equalTo: domainItem.topAnchor, constant: -16),
            topGuide.heightAnchor.constraint(equalTo: bottomGuide.heightAnchor)
        ])
        contentSizeObserver = scrollView.observe(\.contentSize) { scrollView, _ in
            scrollView.isScrollEnabled = scrollView.contentSize.height > scrollView.frame.height
        }
    }
}

extension ReceiveScreenViewController {
    /// A receive screen item, composed of Header, Content, and a separator.
    final class ItemView: UIView {

        let contentLabel = UILabel()
        let headerLabel = UILabel()
        let separator = UILabel()

        private var zeroHeightConstraint: NSLayoutConstraint!

        init() {
            super.init(frame: .zero)
            addSubview(contentLabel)
            addSubview(headerLabel)
            addSubview(separator)

            // MARK: Header

            headerLabel.layoutToSuperview(.top, offset: 0)
            headerLabel.layoutToSuperview(.leading, offset: 24)
            headerLabel.verticalContentHuggingPriority = .required

            // MARK: Domain Label

            contentLabel.layoutToSuperview(axis: .horizontal, offset: 24)
            contentLabel.layout(edge: .top, to: .bottom, of: separator, offset: 16)
            contentLabel.layout(edge: .bottom, to: .bottom, of: self, offset: -16)
            contentLabel.numberOfLines = 0
            contentLabel.verticalContentHuggingPriority = .required

            // MARK: Domain Separator

            separator.backgroundColor = .lightBorder
            separator.layout(dimension: .height, to: 1)
            separator.layout(edge: .leading, to: .trailing, of: headerLabel, offset: 8)
            separator.layoutToSuperview(.trailing)
            separator.layout(edge: .bottom, to: .lastBaseline, of: headerLabel)

            self.zeroHeightConstraint = layout(dimension: .height, to: 0, activate: false)
            verticalContentHuggingPriority = .required
        }

        required init?(coder: NSCoder) { nil }

        func show(_ flag: Bool) {
            zeroHeightConstraint.isActive = !flag
            isHidden = !flag
            contentLabel.isHidden = !flag
            headerLabel.isHidden = !flag
            separator.isHidden = !flag
            setNeedsLayout()
        }
    }
}
