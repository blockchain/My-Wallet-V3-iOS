//
//  CustodyWithdrawalScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class CustodyWithdrawalScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizationID = LocalizationConstants.SimpleBuy.Withdrawal
    private typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet.Withdrawal
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon").withTintColor(.red), accessibility: nil))
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .none
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: "\(LocalizationID.title) \(currency.name) \(LocalizationConstants.wallet)")
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    var activityIndicatorVisibility: Driver<Visibility> {
        activityIndicatorVisibilityRelay.asDriver()
    }
    
    var balanceViewVisibility: Driver<Visibility> {
        balanceViewVisibilityRelay.asDriver()
    }

    var descriptionTextView: Driver<InteractableTextViewModel> {
        descriptionTextViewRelay.asDriver()
    }

    let descriptionLabel: LabelContent
    let sendButtonViewModel: ButtonViewModel
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
    
    // MARK: - Private Properties

    private let descriptionTextViewRelay = BehaviorRelay<InteractableTextViewModel>(value: .empty)
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let activityIndicatorVisibilityRelay = BehaviorRelay<Visibility>(value: .visible)
    private let balanceViewVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let interactor: CustodyWithdrawalScreenInteractor
    private let currency: CryptoCurrency
    private let loadingPresenter: LoadingViewPresenting
    private unowned let stateService: CustodyWithdrawalStateServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(interactor: CustodyWithdrawalScreenInteractor,
         currency: CryptoCurrency,
         stateService: CustodyWithdrawalStateServiceAPI,
         loadingPresenter: LoadingViewPresenting = resolve(),
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        self.loadingPresenter = loadingPresenter
        self.interactor = interactor
        self.currency = currency
        self.stateService = stateService
        self.sendButtonViewModel = .primary(with: LocalizationID.action)
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: .center,
            interactor: interactor.assetBalanceInteractor,
            descriptors: .init(
                fiatFont: .main(.medium, 48.0),
                fiatTextColor: .textFieldText,
                fiatAccessibility: .id(AccessibilityId.fiatValue),
                cryptoFont: .main(.medium, 14.0),
                cryptoTextColor: .textFieldText,
                cryptoAccessibility: .id(AccessibilityId.cryptoValue)
            )
        )
        self.descriptionLabel = LabelContent(
            text: "\(LocalizationID.Description.Top.prefix) \(currency.displayCode) \(LocalizationID.Description.Top.suffix)",
            font: .main(.medium, 12.0),
            color: .titleText,
            alignment: .center,
            accessibility: .none
        )
        
        let stateObservable = interactor.state

        stateObservable
            .map { state -> CustodyWithdrawalSetupInteractor.Value? in
                switch state {
                case .error,
                     .submitted,
                     .settingUp,
                     .submitting:
                    return nil
                case .insufficientFunds(let value),
                     .loaded(let value):
                    return value
                }
            }
            .compactMap { $0 }
            .filter { value in
                // Only display message if user has any totalBalance.
                value.totalBalance.isPositive
            }
            .map { value -> [InteractableTextViewModel.Input] in
                let withdrawable = String(format: LocalizationID.Description.Bottom.withdrawable,
                                          value.withdrawableBalance.toDisplayString(includeSymbol: true))
                var inputs: [InteractableTextViewModel.Input] = [
                    .text(string: withdrawable)
                ]
                if value.remaining.isPositive {
                    let remaining = String(format: LocalizationID.Description.Bottom.remaining,
                                           value.remaining.toDisplayString(includeSymbol: true))
                    inputs += [
                        .text(string: " \(remaining) \n"),
                        .url(string: LocalizationConstants.learnMore,
                             url: Constants.Url.withdrawalLockArticle)
                    ]

                }
                return inputs
            }
            .map(weak: self) { (self, inputs) -> InteractableTextViewModel in
                let model = InteractableTextViewModel(
                    inputs: inputs,
                    textStyle: .init(color: .textFieldText, font: .main(.medium, 12.0)),
                    linkStyle: .init(color: .linkableText, font: .main(.bold, 12.0)),
                    alignment: .center
                )

                model.tap
                    .bindAndCatch(weak: self) { (self, data) in
                        self.stateService.webviewRelay.accept(data.url)
                    }
                    .disposed(by: self.disposeBag)
                return model
            }
            .bindAndCatch(to: descriptionTextViewRelay)
            .disposed(by: disposeBag)

        stateObservable
            .map { $0 == .settingUp ? .visible : .hidden }
            .bindAndCatch(to: activityIndicatorVisibilityRelay)
            .disposed(by: disposeBag)

        stateObservable
            .map { $0 != .settingUp ? .visible : .hidden }
            .bindAndCatch(to: balanceViewVisibilityRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0.isReady }
            .bindAndCatch(to: self.sendButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0.isSubmitting }
            .bindAndCatch(weak: self, onNext: { (self, value) in
                switch value {
                case true:
                    self.loadingPresenter.show(with: .circle, text: nil)
                case false:
                    self.loadingPresenter.hide()
                }
            })
            .disposed(by: disposeBag)

        stateObservable
            .filter { state in
                switch state {
                case .error,
                    .submitted:
                    return true
                case .insufficientFunds,
                     .loaded,
                     .settingUp,
                     .submitting:
                    return false
                }
            }
            .do(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .submitted:
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenSuccess)
                case .error:
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenFailure)
                case .loaded, .settingUp, .submitting, .insufficientFunds:
                    break
                }
            })
            .map { value -> CustodyWithdrawalStatus in
                switch value {
                case .submitted:
                    return .successful
                case .error(let error):
                    return .failed(error)
                case .loaded, .settingUp, .submitting, .insufficientFunds:
                    return .unknown
                }
            }
            .bindAndCatch(to: self.stateService.completionRelay)
            .disposed(by: disposeBag)
        
        self.sendButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.analyticsRecorder.record(
                    event: AnalyticsEvent.sbWithdrawalScreenClicked(asset: self.currency)
                )
                interactor.withdrawalRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func viewDidLoad() {
        analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenShown(asset: currency))
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.previousRelay.accept(())
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
