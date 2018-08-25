//
//  KYC+Onfido.swift
//  Blockchain
//  
//
//  Created by Justin on 8/8/18.
//

import Onfido

protocol OnfidoControllerDelegate: class {
    func onOnfidoControllerCancelled(_ onfidoController: OnfidoController)

    func onOnfidoControllerErrored(_ onfidoController: OnfidoController, error: Error)

    func onOnfidoControllerSuccess(_ onfidoController: OnfidoController)
}

class OnfidoController: UIViewController {
    static let shared = OnfidoController()
    weak var delegate: OnfidoControllerDelegate?
    private var config: OnfidoConfig?

    convenience init() {
        //swiftlint:disable next force_try
        let config = try! OnfidoConfig.builder().build()
        self.init(config: config)
    }
    
    init(config: OnfidoConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        view.isOpaque = false
        guard let configured = self.config else {
            return
        }
        begin(configured)
    }

    // MARK: - Private Methods
    private func showErrorMessage(forError error: Error) {
        let alert = UIAlertController(title: "Errored", message: "Sorry an error occured, please try again", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }

    func begin(_ config: OnfidoConfig) {
        let responseHandler: (OnfidoResponse) -> Void = { response in
            if case let OnfidoResponse.error(innerError) = response {
                DispatchQueue.main.async {
                    self.delegate?.onOnfidoControllerErrored(self, error: innerError)
                }
            } else if case OnfidoResponse.success = response {
                UIView.animate(withDuration: 0.24, animations: {
                    self.view.alpha = 0
                }, completion: { _ in
                    DispatchQueue.main.async {
                        self.delegate?.onOnfidoControllerSuccess(self)
                    }
                })
            } else if case OnfidoResponse.cancel = response {
                UIView.animate(withDuration: 0.24, animations: {
                    self.view.alpha = 0
                }, completion: { _ in
                    DispatchQueue.main.async {
                        self.delegate?.onOnfidoControllerCancelled(self)
                    }
                })
            }
        }

        let onfidoFlow = OnfidoFlow(withConfiguration: config)
            .with(responseHandler: responseHandler)
        do {
            let onfidoRun = try onfidoFlow.run()

            DispatchQueue.main.async {
                onfidoRun.modalPresentationStyle = .formSheet
                self.present(onfidoRun, animated: false)
            }
        } catch let error {
            // cannot execute the flow
            // check CameraPermissions
            self.showErrorMessage(forError: error)
        }
    }
}
