//
//  TransactionRepository.swift
//  vulnabankIOs
//

import Foundation
import XMLCoder

protocol TransactionRepositoryProtocol {
    var onNewItem: DynamicValue<Transaction?> { get }
    func getAll() -> [ Transaction ]
    func create( transaction: Transaction, completion: @escaping () -> Void )
    func delete( transaction: Transaction ) -> Bool
}

class TransactionRepository: TransactionRepositoryProtocol {

    let backendService = DependencyConteiner.resolve(BackendServiceProtocol.self)!
    let database = DependencyConteiner.resolve(DatabaseDaoProtocol.self)!
    
    let onNewItem: DynamicValue<Transaction?> = DynamicValue(nil)
      
    func getAll() -> [ Transaction ] {
        return database.read()
    }

    func create( transaction: Transaction, completion: @escaping () -> Void ) {
        
        guard let json = try? JSONEncoder().encode( transaction ),
            let message = CryptoUtils().encryptAES( message: String( decoding: json, as: UTF8.self ) ),
            let encKey = CryptoUtils().encryptRSA(),
            let signature = CryptoUtils().signRSA( message: message ) else {
                return completion()
        }
        
        let base64Message = message.toBase64()

        let transactionRequest = TransactionRequest( enckey: encKey, message: base64Message, signature: signature )

        backendService.sendTransaction( transactionRequest: transactionRequest ) { [ weak self ] result in
            guard let self = self else {
                return
            }
            
            var evaluatedTransaction = transaction
            
            switch result {
            case .failure( let error ):
                print( "Transaction request error: ", "\(error)", to: &logger )
                    switch error {
                    case .parser(let errorMessage), .network(let errorMessage), .custom(let errorMessage):
                        evaluatedTransaction.error = errorMessage
                    }
                break

            case .success( let data ):
                if let decryptedData = CryptoUtils().decryptAES( message: Array( data ) ),
                    let transactionResponse = try? XMLDecoder().decode( TransactionResponse.self, from: Data( "<response>\(decryptedData)</response>".utf8 ) ) {
                    print( "Transaction response: ", "\(transactionResponse)", to: &logger )
                    
                    evaluatedTransaction.transactionId = transactionResponse.id
                }
                break
            }
            
            evaluatedTransaction.id = self.database.insert( transaction: evaluatedTransaction )
            self.onNewItem.value = evaluatedTransaction
           
            completion()
        }
    }

    func delete( transaction: Transaction ) -> Bool {
        if let id = transaction.id {
            return database.deleteByID(id: id)
        }
        return false
    }
}
