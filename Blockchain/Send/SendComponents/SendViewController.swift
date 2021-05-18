//
//  SendViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import SafariServices
import ToolKit
import UIKit

/// This class was designed to replace all current send screens
/// Should contain as little logic as possible. It's only a view
final class SendViewController: UIViewController {

    // MARK: - Types

    typealias CellIndex = SendPresenter.TableViewDataSource.CellIndex
    
    // MARK: - UI Properties
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var continueButton: PrimaryButtonContainer!

    private var keyboardInteractionController: KeyboardInteractionController!
    
    // MARK: - Injected
    
    fileprivate let alertPresenter: AlertViewPresenter
    private let modalPresenter: ModalPresenter
    private let presenter: SendPresenter
    private let recorder: Recording
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    // TODO: Remove modal presenter dependency
    init(presenter: SendPresenter,
         alertPresenter: AlertViewPresenter = .shared,
         modalPresenter: ModalPresenter = .shared,
         recorder: Recording = CrashlyticsRecorder()) {
        self.presenter = presenter
        self.alertPresenter = alertPresenter
        self.modalPresenter = modalPresenter
        self.recorder = recorder
        super.init(nibName: type(of: self).objectName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        keyboardInteractionController = KeyboardInteractionController(in: self)
        setupTableView()
        setupContinueButton()
        setupNavigationRightButton()
        setupErrorHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.clean()
    }
    
    // MARK: - Setup
    
    private func setupErrorHandling() {
        presenter.error
            .emit(to: rx.errorHandler)
            .disposed(by: disposeBag)
        presenter.alert
            .emit(to: rx.alertHandler)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationRightButton() {
        presenter.navigationRightButton
            .bind { [weak self] update in
                if let navigationController = self?.navigationController as? BaseNavigationController {
                    navigationController.update()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.separatorInset = .zero
        tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.registerNibCells(
            SendDestinationAccountTableViewCell.self,
            SendSourceAccountTableViewCell.self,
            SendFeeTableViewCell.self,
            SendAmountTableViewCell.self
        )
    }
    
    private func setupContinueButton() {
        continueButton.title = LocalizationConstants.Send.primaryButton
        continueButton.disabledButtonBackgroundColor = continueButton.disabledButtonBackgroundColor.withAlphaComponent(0.6)
        continueButton.rx.tap
            .bind { [unowned self] in
                self.continueButtonTapped()
            }
            .disposed(by: disposeBag)
        presenter.isContinueButtonEnabled
            .drive(continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    fileprivate func handle(error: SendInputState.StateError) {
        keyboardInteractionController.dismissKeyboard()
        presenter.recordShowErrorAlert()
        let alert = AlertModel(
            headline: error.title(for: presenter.asset),
            body: error.description(for: presenter.asset),
            image: presenter.asset.errorImage,
            style: .sheet
        )
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }

    // The confirmation screen should be enqeued normally into a navigation controller.
    private func continueButtonTapped() {
        presenter.recordContinueClick()
        presenter.prepareForSending()
            .subscribe(onSuccess: { [weak self] viewModel in
                guard let self = self else { return }
                let confirmView = BCConfirmPaymentView(
                    frame: self.view.frame,
                    viewModel: viewModel,
                    sendButtonFrame: self.continueButton.frame
                    )!
                confirmView.confirmDelegate = self
                self.modalPresenter.showModal(
                    withContent: confirmView,
                    closeType: ModalCloseTypeBack,
                    showHeader: true,
                    headerText: LocalizationConstants.SendAsset.confirmPayment
                )
            }, onError: { [weak self] error in
                self?.recorder.error(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func displaySuccessAlert() {
        let alert = AlertModel(
            headline: LocalizationConstants.success,
            body: LocalizationConstants.SendAsset.paymentSent,
            image: presenter.asset.successImage,
            style: .sheet
        )
        let alertView = AlertView.make(with: alert, completion: nil)
        alertView.show()
    }
}

// MARK: - ConfirmPaymentViewDelegate

extension SendViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        presenter.sendButtonTapped()
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.displaySuccessAlert()
                self.modalPresenter.closeAllModals()
                self.presenter.clean()
                }, onError: { [weak self] error in
                    self?.handle(error: SendInputState.StateError(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    // TODO: Implement or remove
    func feeInformationButtonClicked() {}
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SendPresenter.TableViewDataSource.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case CellIndex.source:
            let cell: SendSourceAccountTableViewCell = tableView.dequeue(
                SendSourceAccountTableViewCell.self,
                for: indexPath
            )
            cell.presenter = presenter.sourcePresenter
            return cell
        case CellIndex.destination:
            let cell: SendDestinationAccountTableViewCell = tableView.dequeue(
                SendDestinationAccountTableViewCell.self,
                for: indexPath
            )
            cell.presenter = presenter.destinationPresenter
            cell.prepare(using: keyboardInteractionController.toolbar!)
            return cell
        case CellIndex.amount:
            let cell: SendAmountTableViewCell = tableView.dequeue(
                SendAmountTableViewCell.self, for: indexPath
            )
            cell.presenter = presenter.amountPresenter
            cell.prepare(using: keyboardInteractionController.toolbar!)
            return cell
        case CellIndex.fee:
            let cell: SendFeeTableViewCell = tableView.dequeue(
                SendFeeTableViewCell.self,
                for: indexPath
            )
            cell.presenter = presenter.feePresenter
            return cell
        default: // Must not arrive here
            return UITableViewCell()
        }
    }
}

// MARK: - NavigatableView

extension SendViewController: NavigatableView {
    var rightNavControllerCTAType: NavigationCTAType {
        presenter.navigationRightButtonValue.indicator.button
    }
    
    var rightCTATintColor: UIColor {
        presenter.navigationRightButtonValue.color
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        presenter.navigationRightButtonTapped()
    }

    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        dismiss(animated: true, completion: nil)
    }

    var leftNavControllerCTAType: NavigationCTAType {
        .dismiss
    }
}

// MARK: - Rx

extension Reactive where Base: SendViewController {
    
    /// Binder for the error handling
    fileprivate var errorHandler: Binder<SendInputState.StateError> {
        Binder(base) { viewController, error in
            viewController.handle(error: error)
        }
    }
    
    /// Binder for any alert
    fileprivate var alertHandler: Binder<AlertViewContent> {
        Binder(base) { viewController, content in
            viewController.alertPresenter.notify(content: content)
        }
    }
}

fileprivate extension CryptoCurrency {
    var errorImage: UIImage {
        switch self {
        case .ethereum:
            return #imageLiteral(resourceName: "eth_bad")
        case .aave,
             .algorand,
             .bitcoin,
             .bitcoinCash,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .wDGLD,
             .yearnFinance:
            impossible()
        }
    }

    var successImage: UIImage {
        switch self {
        case .ethereum:
            return #imageLiteral(resourceName: "eth_good")
        case .aave,
             .algorand,
             .bitcoin,
             .bitcoinCash,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .wDGLD,
             .yearnFinance:
            impossible()
        }
    }

}
