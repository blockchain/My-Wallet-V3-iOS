// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RIBs
import RxCocoa
import RxSwift
import UIKit

final class LinkBankSplashScreenViewController: BaseScreenViewController,
    LinkBankSplashScreenPresentable,
    LinkBankSplashScreenViewControllable
{

    private let disposeBag = DisposeBag()

    /// Stream `true` in case the close was triggered from `UIAdaptivePresentationControllerDelegate` otherwise false
    private let closeTriggerred = PublishSubject<Bool>()

    private lazy var topBackgroundImageView = UIImageView()
    private lazy var topImageView = UIImageView()
    private lazy var topTitleLabel = UILabel()
    private lazy var topSubtitleLabel = UILabel()

    private lazy var linkBankViaPartnerStackView = LinkBankViaPartnerView()
    private lazy var secureConnectionTitleLabel = UILabel()
    private lazy var secureConnectionLabel = InteractableTextView()

    private lazy var continueButton = ButtonView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // so that we'll be able to listen for system dismissal methods
        navigationController?.presentationController?.delegate = self
        setupUI()
    }

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        set(
            barStyle: .darkContent(ignoresStatusBar: true, background: .clear),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
    }

    // MARK: - LinkBankSplashScreenPresentable

    func connect(state: Driver<LinkBankSplashScreenInteractor.State>) -> Driver<LinkBankSplashScreenEffects> {
        state.map(\.topTitle)
            .drive(topTitleLabel.rx.content)
            .disposed(by: disposeBag)

        state.map(\.topSubtitle)
            .drive(topSubtitleLabel.rx.content)
            .disposed(by: disposeBag)

        state.map(\.partnerLogoImageContent)
            .drive(linkBankViaPartnerStackView.rx.partnerImageViewContent)
            .disposed(by: disposeBag)

        state.map(\.detailsTitle)
            .drive(secureConnectionTitleLabel.rx.content)
            .disposed(by: disposeBag)

        state.map(\.detailsInteractiveTextModel)
            .drive(secureConnectionLabel.rx.viewModel)
            .disposed(by: disposeBag)

        state.map(\.continueButtonModel)
            .drive(onNext: { [continueButton] viewModel in
                continueButton.viewModel = viewModel
            })
            .disposed(by: disposeBag)

        let linkTapped = state.map(\.detailsInteractiveTextModel)
            .asObservable()
            .flatMapLatest { viewModel -> Observable<TitledLink> in
                viewModel.tap
            }
            .map(LinkBankSplashScreenEffects.linkTapped)
            .asDriverCatchError()

        let continueTapped = state
            .map(\.continueButtonModel)
            .flatMap { viewModel -> Signal<Void> in
                viewModel.tap
            }
            .asObservable()
            .map { _ in LinkBankSplashScreenEffects.continueTapped }
            .asDriverCatchError()

        let closeTapped = closeTriggerred
            .map { isInteractive in LinkBankSplashScreenEffects.closeFlow(isInteractive) }
            .asDriverCatchError()

        return .merge(continueTapped, closeTapped, linkTapped)
    }

    // MARK: - Private

    func setupUI() {
        set(
            barStyle: .darkContent(ignoresStatusBar: true, background: .clear),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
        // static content
        topBackgroundImageView.image = UIImage(named: "link-bank-splash-top-bg", in: .module, compatibleWith: nil)
        topImageView.image = UIImage(named: "splash-screen-bank-icon", in: .module, compatibleWith: nil)

        view.addSubview(topBackgroundImageView)

        topBackgroundImageView.contentMode = .scaleToFill
        topBackgroundImageView.layoutToSuperview(.top, .leading, .trailing)

        topImageView.contentMode = .center
        topImageView.translatesAutoresizingMaskIntoConstraints = false

        topTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        let topStackView = UIStackView(arrangedSubviews: [topImageView, topTitleLabel, topSubtitleLabel])
        topStackView.axis = .vertical
        topStackView.alignment = .leading
        topStackView.distribution = .fill
        topStackView.spacing = Spacing.standard
        topStackView.setCustomSpacing(Spacing.inner, after: topImageView)

        topTitleLabel.numberOfLines = 1
        topSubtitleLabel.numberOfLines = 0

        linkBankViaPartnerStackView.translatesAutoresizingMaskIntoConstraints = false
        secureConnectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        secureConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        let detailsStackView = UIStackView(arrangedSubviews: [secureConnectionTitleLabel, secureConnectionLabel])
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.axis = .vertical
        detailsStackView.isLayoutMarginsRelativeArrangement = true
        detailsStackView.directionalLayoutMargins = .init(
            top: 0,
            leading: Spacing.inner,
            bottom: 0,
            trailing: Spacing.inner
        )

        let middleStackView = UIStackView(arrangedSubviews: [linkBankViaPartnerStackView, detailsStackView])
        middleStackView.axis = .vertical
        middleStackView.spacing = Spacing.outer
        middleStackView.setCustomSpacing(Spacing.outer, after: linkBankViaPartnerStackView)

        view.addSubview(topStackView)
        view.addSubview(middleStackView)
        view.addSubview(continueButton)

        topStackView.layoutToSuperview(.top, offset: Spacing.inner)
        topStackView.layoutToSuperview(.leading, offset: Spacing.inner)
        topStackView.layoutToSuperview(.trailing, offset: -Spacing.inner)

        middleStackView.layout(edge: .top, to: .bottom, of: topStackView, relation: .greaterThanOrEqual, offset: Spacing.outer)
        middleStackView.layoutToSuperview(.centerY, offset: -Spacing.outer)
        middleStackView.layoutToSuperview(.leading, offset: Spacing.inner)
        middleStackView.layoutToSuperview(.trailing, offset: -Spacing.inner)

        continueButton.layout(edge: .top, to: .bottom, of: middleStackView, relation: .greaterThanOrEqual, offset: Spacing.outer)
        continueButton.layout(dimension: .height, to: ButtonSize.Standard.height, relation: .equal)
        continueButton.layoutToSuperview(.leading, offset: Spacing.inner)
        continueButton.layoutToSuperview(.trailing, offset: -Spacing.inner)
        continueButton.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.outer)
    }
}

extension LinkBankSplashScreenViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when a pull-down dismissal happens
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeTriggerred.onNext(true)
    }
}
