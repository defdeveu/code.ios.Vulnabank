import Foundation
import SQLite3

@MainActor
protocol DatabaseDaoProtocol: AnyObject {
    func insert(transaction: Transaction) -> Int
    func read() -> [Transaction]
    func deleteByID(id: Int) -> Bool
}

@MainActor
final class DatabaseService: DatabaseDaoProtocol {
    private var db: OpaquePointer?

    init() {
        db = openDatabase()
        createTable()
    }

    func insert(transaction: Transaction) -> Int {
        let insertStatementString = "insert into Transactions(amount, recipient, date, transaction_id, error) values ( ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(insertStatement, 1, Double(transaction.amount))
            sqlite3_bind_text(insertStatement, 2, (transaction.recipient as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(insertStatement, 3, Int64(transaction.date.timeIntervalSince1970))

            if let transactionId = transaction.transactionId {
                sqlite3_bind_text(insertStatement, 4, (transactionId as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_text(insertStatement, 4, nil, -1, nil)
            }

            if let error = transaction.error {
                sqlite3_bind_text(insertStatement, 5, (error as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_text(insertStatement, 5, nil, -1, nil)
            }

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                logger.log("Successfully inserted row.")
            } else {
                logger.log("Could not insert row.")
            }
        } else {
            logger.log("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)

        return Int(sqlite3_last_insert_rowid(db))
    }

    func read() -> [Transaction] {
        let queryStatementString = "SELECT * FROM Transactions;"
        var queryStatement: OpaquePointer?
        var transactions: [Transaction] = []

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let amount = sqlite3_column_double(queryStatement, 1)
                let recipient = String(cString: sqlite3_column_text(queryStatement, 2))
                let date = Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(queryStatement, 3)))

                let transactionIdPointer = sqlite3_column_text(queryStatement, 4)
                let transactionId = transactionIdPointer != nil ? String(cString: transactionIdPointer!) : nil

                let errorPointer = sqlite3_column_text(queryStatement, 5)
                let error = errorPointer != nil ? String(cString: errorPointer!) : nil

                transactions.append(
                    Transaction(
                        id: id,
                        transactionId: transactionId,
                        error: error,
                        amount: amount,
                        recipient: recipient,
                        date: date
                    )
                )
            }
            logger.log("Query Result: \(transactions.count) items")
        } else {
            logger.log("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return transactions
    }

    func deleteByID(id: Int) -> Bool {
        let deleteStatementString = "DELETE FROM Transactions WHERE Id = ?;"
        var deleteStatement: OpaquePointer?
        var result = false

        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                logger.log("Successfully deleted row.")
                result = true
            } else {
                logger.log("Could not delete row.")
            }
        } else {
            logger.log("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)

        return result
    }
}

extension DatabaseService {
    private func openDatabase() -> OpaquePointer? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }

        let fileURL = documentDirectory.appendingPathComponent(Constants.Values.dbFilename)
        var database: OpaquePointer?

        if sqlite3_open(fileURL.path, &database) != SQLITE_OK {
            logger.log("Error opening database")
            return nil
        }
        logger.log("Successfully opened connection to database.")
        return database
    }

    private func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Transactions(id integer primary key autoincrement,"
            + "amount real, recipient text not null, date integer, transaction_id text, error text);"

        var createTableStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                logger.log("Transaction table created.")
            } else {
                logger.log("Transaction table could not be created.")
            }
        } else {
            logger.log("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
}
