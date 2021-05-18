//
//  CustodyWithdrawalSummaryPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

/// The status of the withdrawal after submission
enum CustodyWithdrawalStatus: Equatable {
    /// Default state
    case unknown
    
    /// The withdrawal was successful
    case successful
    
    /// The withdrawal failed
    case failed(WithdrawalError)
}

final class CustodyWithdrawalSummaryPresenter {
    
    typealias Status = CustodyWithdrawalStatus
    
    // MARK: - Localization
    
    typealias LocalizationSuccessIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummarySuccess
    typealias LocalizationFailureIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummaryFailure
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon"), accessibility: nil))
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .none
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: "\(LocalizationConstants.SimpleBuy.Withdrawal.title) \(currency.name) \(LocalizationConstants.wallet)")
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    // MARK: - Public Properties
    
    let actionViewModel: ButtonViewModel
    
    var imageDriver: Driver<UIImage> {
        imageRelay.asDriver()
    }
    
    var titleLabelDriver: Driver<LabelContent> {
        titleLabelRelay.asDriver()
    }
    
    var descriptionLabelDriver: Driver<InteractableTextViewModel> {
        descriptionLabelRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let currency: CryptoCurrency
    private let imageRelay = BehaviorRelay<UIImage>(value: #imageLiteral(resourceName: "success_icon"))
    private let titleLabelRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let descriptionLabelRelay = BehaviorRelay<InteractableTextViewModel>(value: .empty)
    private unowned let stateService: CustodyWithdrawalStateServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(status: Status, currency: CryptoCurrency, stateService: CustodyWithdrawalStateServiceAPI) {
        self.currency = currency
        self.stateService = stateService
        
        switch status {
        case .unknown:
            fatalError("This state should never occur")
        case .failed(let error):
            let model = CustodyWithdrawalSummaryErrorViewModel(error: error)
            actionViewModel = .primary(with: LocalizationFailureIDs.action)
            titleLabelRelay.accept(model.title ?? .empty)
            descriptionLabelRelay.accept(model.description)
            imageRelay.accept(model.image)

            model.description
                .tap
                .bindAndCatch(weak: self) { (self, data) in
                    self.stateService.webviewRelay.accept(data.url)
                }
                .disposed(by: disposeBag)

        case .successful:
            let title: LabelContent = .init(
                text: "\(LocalizationSuccessIDs.title) \(currency.displayCode) \(LocalizationSuccessIDs.sent).",
                font: .main(.semibold, 20.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .none
            )
            
            let description = InteractableTextViewModel(
                inputs: [.text(string: LocalizationSuccessIDs.description)],
                textStyle: .init(color: .textFieldText, font: .main(.medium, 14.0)),
                linkStyle: .init(color: .linkableText, font: .main(.bold, 14.0))
            )

            actionViewModel = .primary(with: LocalizationSuccessIDs.action)
            
            imageRelay.accept(#imageLiteral(resourceName: "success_icon"))
            titleLabelRelay.accept(title)
            descriptionLabelRelay.accept(description)
        }

        actionViewModel.tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.nextRelay.accept(())
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}

fileprivate struct CustodyWithdrawalSummaryErrorViewModel {
    let title: LabelContent?
    let description: InteractableTextViewModel
    let image: UIImage

    init(error: WithdrawalError) {
        title = LabelContent(
            text: error.localizedTitle,
            font: .main(.semibold, 20.0),
            color: .textFieldText,
            alignment: .center,
            accessibility: .none
        )
        switch error {
        case WithdrawalError.withdrawalLocked:
            description = CustodyWithdrawalSummaryErrorViewModel.descriptionInteractableModel(
                inputs: [
                    .text(string: error.localizedDescription),
                    .text(string: " "),
                    .url(string: LocalizationConstants.learnMore,
                         url: Constants.Url.withdrawalLockArticle)
                ]
            )
            image = #imageLiteral(resourceName: "icon_clock_filled")
        case .unknown:
            description = CustodyWithdrawalSummaryErrorViewModel.descriptionInteractableModel(
                inputs: [.text(string: error.localizedDescription)]
            )
            image = #imageLiteral(resourceName: "Icon-Close-Circle-Red")
        }
    }

    private static func descriptionInteractableModel(inputs: [InteractableTextViewModel.Input]) -> InteractableTextViewModel {
        InteractableTextViewModel(
            inputs: inputs,
            textStyle: .init(color: .textFieldText, font: .main(.medium, 14.0)),
            linkStyle: .init(color: .linkableText, font: .main(.bold, 14.0)),
            alignment: .center
        )
    }
}
