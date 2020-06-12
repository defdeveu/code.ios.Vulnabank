//
//  DeepLink.swift
//  vulnabankIOs
//

import Foundation

final class DeepLink {
    
    let transactionRepository = DependencyConteiner.resolve(TransactionRepositoryProtocol.self)!
    
    func doAction( withUrl url: URL ) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let command = components.host,
            let params = components.queryItems else {
                print("DeepLink: Invalid URL or missing command", to: &logger)
                return
        }
        
        if let amountString = params.first(where: { $0.name == "amount" })?.value,
            let amount = Double(amountString),
            let recipient = params.first(where: { $0.name == "recipient" })?.value{
            
            print("DeepLink: command=\(command) amount = \(amount) recipient = \(recipient)", to: &logger)
            
            executeTransaction(command: command, recipient: recipient, amount: amount)
        } else {
            print("DeepLink: amount or recipient param missing or invalid", to: &logger)
        }
    }
    
}

extension DeepLink {
    
    fileprivate func executeTransaction(command: String, recipient: String, amount: Double) {
           switch command.lowercased() {
           case "add":
               transactionRepository.create(transaction: Transaction(amount: amount, recipient: recipient, date: Date())) { }
               break
           default:
               break
           }
       }
    
}
