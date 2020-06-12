//
//  Constants.swift
//  vulnabankIOs
//

import Foundation

struct Constants {
    
    struct Errors {
        static let pinLength = "PIN length has to be 4"
        static let pinMismatch = "PIN mismatch"
    }
    
    struct Values {
        static let pinLength = 4
        static let logFilename = "debug.log"
        static let dbFilename = "db.sqlite"
        static let pinBackupFilename = "pinBackup.txt"
        static let serverEndpoint = "http://127.0.0.1:9999/request"
        static let userDefaultAuthPin = "Pin"
        static let AES_KEY = "00112233445566778899aabbccddeeff"
        static let AES_IV = "1111111111111111"
    }
    
    struct StoryBoarsIds {
        static let main = "Main"
        static let loginViewController = "loginViewController"
        static let registrationViewController = "registrationViewController"
        static let transactionsViewController = "transactionsViewController"
        static let navigationController = "navigationController"
        static let newTransactionViewController = "newTransactionViewController"
        static let cellReuseIdentifier = "transactionCell"
    }
}
