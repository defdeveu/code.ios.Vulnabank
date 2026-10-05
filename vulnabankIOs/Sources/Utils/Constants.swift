import Foundation

enum Constants {
    enum Errors {
        static let pinLength = "PIN length has to be 4"
        static let pinMismatch = "PIN mismatch"
    }

    enum Values {
        static let pinLength = 4
        static let logFilename = "debug.log"
        static let dbFilename = "db.sqlite"
        static let pinBackupFilename = "pinBackup.txt"
        static let userDefaultAuthPin = "Pin"
        static let aesKey = "00112233445566778899aabbccddeeff"
        static let aesIV = "1111111111111111"
    }
}
