//
//  TransactionsViewModel.swift
//  vulnabankIOs
//

import Foundation

final class TransactionsViewModel: BaseViewModel {
 
    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
    let transactionRepository = DependencyConteiner.resolve(TransactionRepositoryProtocol.self)!
    var transactions: [Transaction] = []
    
    override init() {
        super.init()
        
        authService.onLoggedIn.addObserver { [weak self] loggedIn in
            if loggedIn {
                self?.getAllTransaction()
            } else {
                self?.transactions = []
                self?.onRefreshUi.notify()
            }
        }
        
        transactionRepository.onNewItem.addObserver { [weak self] newTransaction in
            if let transaction = newTransaction {
                self?.transactions.append(transaction)
                
                DispatchQueue.main.async {
                    self?.onRefreshUi.notify()
                }
            }
        }
    }
    
    func deleteTransaction(transaction: Transaction) {
        if transactionRepository.delete(transaction: transaction) {
            transactions = transactions.filter() { $0.id != transaction.id }
        }
    }
    
    func deleteTransactions(byIndexes indexes: [Int]) {
        let selectedTransactions = indexes.map({transactions[$0]})
        selectedTransactions.forEach({deleteTransaction(transaction: $0)})
    }
    
    func getAllTransaction() {
        transactions = transactionRepository.getAll()
        onRefreshUi.notify()
    }
    
}
