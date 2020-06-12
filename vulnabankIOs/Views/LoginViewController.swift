//
//  LoginViewController.swift
//  vulnabankIOs
//

import Foundation
import UIKit

final class LoginViewController: UIViewController {
    
    fileprivate let viewModel:LoginViewModel = LoginViewModel()
    
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        regiserKeyboardNotifications()
        
        viewModel.pinViewModel = pinTextField.viewModel
        
        viewModel.onRefreshUi.addObserver { [weak self] _ in
            self?.refreshUI()
        }
        
        refreshUI()
    }
    
    @IBAction func loginTouch(_ sender: Any) {
        viewModel.login()
    }
    
    deinit {
        removeKeyboardNotifications()
    }

}

extension  LoginViewController {

    fileprivate func refreshUI() {
        errorLabel.isHidden = !viewModel.showError
        loginButton.isEnabled = viewModel.loginEnabled
    }
}

