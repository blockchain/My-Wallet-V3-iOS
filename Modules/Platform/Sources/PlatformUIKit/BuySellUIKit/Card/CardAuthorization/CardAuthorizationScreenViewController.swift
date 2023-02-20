// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import WebKit

public final class CardAuthorizationScreenViewController: BaseScreenViewController {

    // MARK: - UI Properties

    private lazy var webView: WKWebView = {
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        return WKWebView(frame: view.bounds, configuration: config)
    }()

    // MARK: - Injected

    private let presenter: CardAuthorizationScreenPresenter
    private var exitUrl: URL!

    // MARK: - Setup

    public init(presenter: CardAuthorizationScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavigationBar()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        switch presenter.authorizationState {
        case .required(let params):
            guard let url = params.paymentLink else {
                return
            }
            exitUrl = params.exitLink
            view.addSubview(webView)
            webView.fillSuperview()
            webView.navigationDelegate = self
            webView.load(URLRequest(url: url))
        case .none, .confirmed:
            break
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch presenter.authorizationState {
        case .none, .confirmed:
            close()
        case .required(let params):
            guard params.paymentLink == nil else {
                return
            }
            close()
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    private func setupNavigationBar() {
        set(barStyle: .darkContent())
        titleViewStyle = .text(value: presenter.title)
    }

    private func close() {
        dismiss(animated: true) { [presenter] in
            presenter.redirect()
        }
    }
}

// MARK: WKNavigationDelegate

extension CardAuthorizationScreenViewController: WKNavigationDelegate {

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void
    ) {
        if navigationAction.request.url?.host == exitUrl.host {
            close()
        }
        decisionHandler(.allow)
    }
}
