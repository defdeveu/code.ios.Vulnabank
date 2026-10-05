import Foundation

@MainActor
protocol TransactionRepositoryProtocol: AnyObject {
    func getAll() -> [Transaction]
    func create(_ transaction: Transaction) async -> Transaction
    func delete(_ transaction: Transaction) -> Bool
}

@MainActor
final class TransactionRepository: TransactionRepositoryProtocol {
    private let backend: any BackendServiceProtocol
    private let database: any DatabaseDaoProtocol
    private let encryption: any MessageEncryptionProtocol

    init(
        backend: any BackendServiceProtocol,
        database: any DatabaseDaoProtocol,
        encryption: any MessageEncryptionProtocol
    ) {
        self.backend = backend
        self.database = database
        self.encryption = encryption
    }

    func getAll() -> [Transaction] {
        database.read()
    }

    func create(_ transaction: Transaction) async -> Transaction {
        var stored = transaction

        do {
            let json = try JSONEncoder().encode(transaction)
            let sealed = try encryption.seal(message: String(decoding: json, as: UTF8.self))
            let payload = try await backend.send(sealedBody: sealed.body)
            let plaintext = try MessageCrypto.aesCBCDecrypt(
                payload,
                key: sealed.material.key,
                iv: sealed.material.iv
            )
            let response = try TransactionXML.decodeResponse(
                "<response>\(String(decoding: plaintext, as: UTF8.self))</response>"
            )
            logger.log("Transaction response: \(response)")
            stored.transactionId = response.id
        } catch let error as BackendError {
            logger.log("Transaction request error: \(error)")
            stored.error = error.localizedDescription
        } catch {
            logger.log("Transaction request error: \(error)")
        }

        stored.id = database.insert(transaction: stored)
        return stored
    }

    func delete(_ transaction: Transaction) -> Bool {
        guard let id = transaction.id else {
            return false
        }
        return database.deleteByID(id: id)
    }
}
