//
//  Transaction.swift
//  vulnabankIOs
//

import Foundation

struct Transaction: Codable {
    var id: Int?
    var transactionId: String?
    var error: String?
    let amount : Double
    let recipient : String
    let date: Date
}

struct TransactionResponse: Decodable {
    let code : String
    let id : String
}

struct ServerResponse: Decodable {
    var resultValue: String? = nil
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self.resultValue = string
        }
    }
}

struct TransactionRequest: Codable {
    let enckey: String
    let message : String
    let signature: String
}

