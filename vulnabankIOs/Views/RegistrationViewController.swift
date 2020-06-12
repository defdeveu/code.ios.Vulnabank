//
//  ViewController.swift
//  vulnabankIOs
//

import UIKit


final class RegistrationViewController: UIViewController {
    
    var viewModel: RegistrationViewModel = RegistrationViewModel()
    
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var confirmPinTextField: PinTextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        regiserKeyboardNotifications()
        
        viewModel.pinViewModel = pinTextField.viewModel
        viewModel.pinConfirmationViewModel = confirmPinTextField.viewModel
        
        viewModel.onRefreshUi.addObserver { [weak self] _ in
            self?.refreshUI()
        }
        refreshUI()
    }
    
    @IBAction func registerTouch(_ sender: Any) {
        viewModel.register(pin: pinTextField.text)
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
}

fileprivate extension RegistrationViewController {
    
    func refreshUI() {
        errorLabel.isHidden = !viewModel.showError
        errorLabel.text = viewModel.error
        registerButton.isEnabled = viewModel.registerEnabled
    }
}
