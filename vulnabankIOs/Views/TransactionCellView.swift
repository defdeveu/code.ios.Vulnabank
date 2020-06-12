//
//  TransactionCellView.swift
//  vulnabankIOs
//
//  Created by feco on 2020. 06. 04..
//  Copyright © 2020. sagifer. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCellView: UITableViewCell {
    
   
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var transactionView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    
    func setTransaction(transaction: Transaction, inEditingMode: Bool) {
        
        if inEditingMode {
            accessoryType = .checkmark
            accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            accessoryView?.backgroundColor = UIColor.blue
        } else {
            accessoryType = .none
            accessoryView = nil
        }
        
        amountLabel.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        
        if let id = transaction.transactionId {
            errorView.isHidden = true
            transactionView.isHidden = false
            recipientLabel.text = transaction.recipient
            amountLabel.text = "Amount: " + String(transaction.amount)
            transactionIdLabel.text = "Id: \(id)"
        } else {
            transactionView.isHidden = true
            if let error = transaction.error {
                errorMessageLabel.text = error
                errorView.isHidden = false
            }
        }
        
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .short
        formatter2.dateStyle = .medium
        
        dateLabel.text = formatter2.string(from: transaction.date)
        
        layoutSubviews()
    }
}
