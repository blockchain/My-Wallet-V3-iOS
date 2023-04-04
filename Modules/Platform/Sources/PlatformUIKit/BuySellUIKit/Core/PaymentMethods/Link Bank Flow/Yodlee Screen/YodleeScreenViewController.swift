// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RIBs
import RxCocoa
import RxSwift
import UIKit
import WebKit

final class YodleeScreenViewController: BaseScreenViewController,
    YodleeScreenPresentable,
    YodleeScreenViewControllable
{

    private let disposeBag = DisposeBag()
    private let closeTriggerred = PublishSubject<Bool>()
    private let backTriggerred = PublishSubject<Void>()

    private let webview: WKWebView
    private let pendingView: YodleePendingView

    init(webConfiguration: WKWebViewConfiguration) {
        self.webview = WKWebView(frame: .zero, configuration: webConfiguration)
        self.pendingView = YodleePendingView()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    override func navigationBarLeadingButtonPressed() {
        backTriggerred.onNext(())
    }

    // MARK: - YodleeScreenPresentable

    func connect(action: Driver<YodleeScreen.Action>) -> Driver<YodleeScreen.Effect> {

        let requestAction = action
            .compactMap(\.request)

        let contentAction = action
            .compactMap(\.content)
            .distinctUntilChanged()

        requestAction
            .drive(weak: self) { (self, request) in
                self.webview.load(request)
            }
            .disposed(by: disposeBag)

        contentAction
            .drive(pendingView.rx.content)
            .disposed(by: disposeBag)

        contentAction
            .drive(weak: self) { (self, _) in
                self.toggle(visibility: true, of: self.pendingView)
                self.toggle(visibility: false, of: self.webview)
            }
            .disposed(by: disposeBag)

        webview.rx.observeWeakly(Bool.self, "loading", options: [.new])
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] loading in
                guard let self else { return }
                toggle(visibility: loading, of: pendingView)
                toggle(visibility: !loading, of: webview)
            })
            .disposed(by: disposeBag)

        let closeTapped = closeTriggerred
            .map { isInteractive in YodleeScreen.Effect.closeFlow(isInteractive) }
            .asDriverCatchError()

        let backTapped = backTriggerred
            .map { _ in YodleeScreen.Effect.back }
            .asDriverCatchError()

        let linkTapped = contentAction
            .flatMap { content -> Driver<TitledLink> in
                content.subtitleLinkTap
                    .asDriver(onErrorDriveWith: .empty())
            }
            .map { link -> YodleeScreen.Effect in
                .link(url: link.url)
            }

        return .merge(closeTapped, backTapped, linkTapped)
    }

    // MARK: - Private

    private func setupUI() {
        titleViewStyle = .text(value: LocalizationConstants.SimpleBuy.YodleeWebScreen.title)
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .back,
            trailingButtonStyle: .close
        )

        view.addSubview(webview)
        view.addSubview(pendingView)

        webview.layoutToSuperview(axis: .vertical)
        webview.layoutToSuperview(axis: .horizontal)
        pendingView.layoutToSuperview(.top)
        pendingView.layoutToSuperview(.leading)
        pendingView.layoutToSuperview(.trailing)
        pendingView.layoutToSuperview(.bottom)
    }

    private func toggle(visibility: Bool, of view: UIView) {
        let alpha: CGFloat = visibility ? 1.0 : 0.0
        let hidden = !visibility
        UIView.animate(
            withDuration: 0.2,
            animations: {
                view.alpha = alpha
            },
            completion: { _ in
                view.isHidden = hidden
            }
        )
    }
}

extension YodleeScreenViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when a pull-down dismissal happens
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeTriggerred.onNext(true)
    }
}
