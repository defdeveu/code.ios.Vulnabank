//
//  RegisterViewModel.swift
//  vulnabankIOs
//

import Foundation

final class RegistrationViewModel: BaseViewModel {
    
    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
    
    var showError = false
    var registerEnabled = false
    var error: String?
    
    var pinViewModel: PinTextFieldViewModel? {
        didSet {
            pinViewModel?.onPinChanged.addObserver { [weak self] _ in
                self?.validate()
            }
        }
    }
    
    var pinConfirmationViewModel: PinTextFieldViewModel? {
        didSet {
            pinConfirmationViewModel?.onPinChanged.addObserver { [weak self] _ in
                self?.validate()
            }
        }
    }
    
    func register(pin: String?) {
        if let pin = pin {
            authService.register(authentication: Authentication(pin: pin));
        }
    }

}

extension RegistrationViewModel {

    fileprivate func validate() {
        guard let pinViewModel = pinViewModel, let pinConfirmationViewModel = pinConfirmationViewModel else {
            return
        }
        let validPins = pinViewModel.valid && pinConfirmationViewModel.valid
        let validPinsLength = pinViewModel.validLength && pinConfirmationViewModel.validLength

        if !validPins && pinViewModel.touched {
            showError = true
            registerEnabled = false
            error = Constants.Errors.pinLength
        } else if validPinsLength && pinViewModel.text != pinConfirmationViewModel.text {
            showError = true
            registerEnabled = false
            error = Constants.Errors.pinMismatch
        } else if !validPinsLength || !pinViewModel.validLength {
            registerEnabled = false
        } else {
            showError = false
            registerEnabled = true
        }
        onRefreshUi.notify()
    }

}
