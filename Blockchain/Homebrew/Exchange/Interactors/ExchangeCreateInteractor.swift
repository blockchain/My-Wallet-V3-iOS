//
//  ExchangeCreateInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class ExchangeCreateInteractor {
    var disposable: Disposable?
    weak var output: ExchangeCreateOutput?
    fileprivate let inputs: ExchangeInputsAPI
    fileprivate var markets: ExchangeMarketsAPI
    private let inputsState: InputsState
    private var model: MarketsModel? {
        didSet {
            if markets.hasAuthenticated {
                updateConversion()
            }
        }
    }

    init(dependencies: ExchangeDependencies,
         model: MarketsModel,
         inputsState: InputsState = InputsState()
    ) {
        self.inputsState = inputsState
        self.markets = dependencies.markets
        self.inputs = dependencies.inputs
        self.model = model
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension ExchangeCreateInteractor: ExchangeCreateInput {
    func viewLoaded() {
        markets.setup()

        // Authenticate, then listen for conversions
        markets.authenticate(completion: { [unowned self] in
            self.subscribeToConversions()
            self.updateConversion()
        })
    }

    func subscribeToConversions() {
        disposable = markets.conversions.subscribe(onNext: { [unowned self] conversion in
            // do something with the converison
        }, onError: { error in
            Logger.shared.error("Error subscribing to quote with trading pair")
        })
    }

    func updateConversion() {
        guard let model = model else {
            Logger.shared.error("Updating conversion with no model")
            return
        }
        markets.updateConversion(model: model)
    }

    func updateInput() {
        if inputsState.isUsingFiat {
            let components = inputs.inputComponents
            output?.updatedInput(
                primary: components.integer,
                primaryDecimal: components.fractional,
                secondary: inputs.lastOutput
            )
        } else {
            output?.updatedInput(
                primary: inputs.activeInput.input,
                primaryDecimal: nil,
                secondary: inputs.lastOutput
            )
        }
    }

    func displayInputTypeTapped() {
        inputsState.isUsingFiat = !inputsState.isUsingFiat
        inputs.toggleInput()
        updateInput()
    }
    
    func ratesViewTapped() {
        
    }
    
    func useMinimumAmount() {
        
    }
    
    func useMaximumAmount() {
        
    }
    
    func onBackspaceTapped() {
        inputs.backspace()
        updateInput()
    }
    
    func onAddInputTapped(value: String) {
        inputs.add(character: value)
        updateInput()
    }
}
