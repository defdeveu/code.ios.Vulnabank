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
    
    private let viewModel:NewTransactionViewModel = NewTransactionViewModel()
    
    override func viewDidLoad() {
        
        viewModel.onRefreshUi.addObserver { [weak self] _ in
            self?.refreshUI()
        }
        
        viewModel.onFinishedTransaction.addObserver { [weak self] _ in
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
        viewModel.sendTransaction()
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        dismiss(animated: true)
    }
        
    fileprivate func refreshUI() {
        recipientErrorLabel.isHidden = !viewModel.showRecipientError
        amountErrorLabel.isHidden = !viewModel.showAmountError
        sendButton.isEnabled = viewModel.enabledSendButton
    }
}

