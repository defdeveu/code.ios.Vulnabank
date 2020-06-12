//
//  NewTrasactionViewMode.swift
//  vulnabankIOs
//

import Foundation

final class NewTransactionViewModel: BaseViewModel {

    let onFinishedTransaction: DynamicValue<()> = DynamicValue(())
    let transactionRepository = DependencyConteiner.resolve(TransactionRepositoryProtocol.self)!
    
    var enabledSendButton = false
    var showRecipientError = false
    var showAmountError = false
    
    var recipientText: String? {
        didSet {
            validate()
        }
    }
    
    var amount: Double? {
        didSet {
            validate()
        }
    }
    
    var validRecipient: Bool {
        get {
            if let recipientText = recipientText {
                return recipientText.count > 0
            }
            return false
        }
    }
    
    var validAmount: Bool {
        get {
            if let amount = amount {
                return amount > 0
            }
            return false
        }
    }

    func sendTransaction() {
        if let recipient = recipientText, let amount = amount {
            transactionRepository.create(transaction: Transaction(amount: amount, recipient: recipient, date: Date())){ [weak self] () in
                DispatchQueue.main.async {
                    self?.onFinishedTransaction.notify()
                }
            }
        }
    }
}

extension NewTransactionViewModel {

    fileprivate func validate() {
        enabledSendButton = validRecipient && validAmount
        onRefreshUi.notify()
    }
}
