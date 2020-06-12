//
//  LoginViewModel.swift
//  vulnabankIOs
//

import Foundation

final class LoginViewModel: BaseViewModel {
    
    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
    
    var showError = false
    var loginEnabled = false
    
    var pinViewModel: PinTextFieldViewModel? {
        didSet {
            pinViewModel?.onPinChanged.addObserver { [weak self] _ in
                if let self = self,
                    let pinViewModel = self.pinViewModel {
                 
                    self.loginEnabled = pinViewModel.valid
                    self.showError = false
                    self.onRefreshUi.notify()
                }
            }
        }
    }
    
    func login() {
        guard let pin = pinViewModel?.text else {
            return
        }
    
        let loggedIn = authService.login(authentication: Authentication(pin: pin));
        
        if !loggedIn {
            showError = true
            loginEnabled = false
            onRefreshUi.notify()
        }
    }
}
