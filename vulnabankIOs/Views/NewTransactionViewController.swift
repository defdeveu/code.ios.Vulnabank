//
//  NewTransactionViewController.swift
//  vulnabankIOs
//

import Foundation
import UIKit

final class NewTransactionViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recipientErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var contentView: UIStackView!
    
    var activityIndicator: UIActivityIndicatorView?
    
    private let viewModel:NewTransactionViewModel = NewTransactionViewModel()
    
    override func viewDidLoad() {
        viewModel.onRefreshUi.addObserver { [weak self] _ in
            self?.refreshUI()
        }
        
        viewModel.onFinishedTransaction.addObserver { [weak self] _ in
            self?.removeActivityIndictor()
            self?.dismiss(animated: true)
        }
        
        refreshUI()
    }
    
    @IBAction func recipientEditChanged( _ sender: Any) {
        viewModel.recipientText = recipientTextField.text
    }
    
    @IBAction func amountEditChanged(_ sender: Any) {
        if let text = amountTextField.text, let amount = Double(text) {
            viewModel.amount = amount
        }
    }
    
    @IBAction func sendButtonTouched(_ sender: Any) {
        addActivityIndictor()
        contentView.isUserInteractionEnabled = false;
        viewModel.sendTransaction()
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        dismiss(animated: true)
    }
     
}

fileprivate extension NewTransactionViewController{
    
     func refreshUI() {
         recipientErrorLabel.isHidden = !viewModel.showRecipientError
         amountErrorLabel.isHidden = !viewModel.showAmountError
         sendButton.isEnabled = viewModel.enabledSendButton
     }

    func removeActivityIndictor() {
        activityIndicator?.removeFromSuperview()
    }
    
    func addActivityIndictor() {
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()

        if let indicator = activityIndicator {
            view.addSubview(indicator)
        }
    }
}
