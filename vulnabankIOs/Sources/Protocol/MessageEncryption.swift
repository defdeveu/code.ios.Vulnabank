import Foundation

enum MessageEncryptionConstants {
    static let aesKey = Constants.Values.aesKey
    static let aesIV = Constants.Values.aesIV
    static let keyMaterial = aesKey + "|" + aesIV
}

struct SymmetricMaterial: Sendable {
    let key: [UInt8]
    let iv: [UInt8]

    static let classroom = SymmetricMaterial(
        key: Array(MessageEncryptionConstants.aesKey.utf8),
        iv: Array(MessageEncryptionConstants.aesIV.utf8)
    )
}

struct SealedMessage: Sendable {
    let body: Data
    let material: SymmetricMaterial
}

protocol MessageEncryptionProtocol: Sendable {
    func seal(message: String) throws -> SealedMessage
    func openResponse(_ body: Data, material: SymmetricMaterial) throws -> String
}

enum MessageEncryptionError: LocalizedError, Equatable {
    case keyLoading(String)
    case encryptionFailed
    case signingFailed
    case responseShape
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case let .keyLoading(label):
            "The bundled \(label) is missing or unreadable."
        case .encryptionFailed:
            "The message could not be encrypted."
        case .signingFailed:
            "The message could not be signed."
        case .responseShape:
            "The server response has an unexpected shape."
        case .decryptionFailed:
            "The server response could not be decrypted."
        }
    }
}

final class MessageEncryption: MessageEncryptionProtocol, @unchecked Sendable {
    private let keys: ApplicationKeys

    init(keys: ApplicationKeys) {
        self.keys = keys
    }

    func seal(message: String) throws -> SealedMessage {
        let material = SymmetricMaterial.classroom
        let wrappedKey = try MessageCrypto.rsaEncrypt(
            Data(MessageEncryptionConstants.keyMaterial.utf8),
            publicKey: keys.serverPublicKey
        )
        let ciphertext = try MessageCrypto.aesCBCEncrypt(
            Data(message.utf8),
            key: material.key,
            iv: material.iv
        )
        let signature = try MessageCrypto.rsaSignatureSHA1(of: ciphertext, privateKey: keys.clientPrivateKey)
        let xml = "<request><enckey>\(wrappedKey.base64EncodedString())</enckey>"
            + "<message>\(ciphertext.base64EncodedString())</message>"
            + "<signature>\(signature.base64EncodedString())</signature></request>"
        return SealedMessage(body: Data(xml.utf8), material: material)
    }

    func openResponse(_ body: Data, material: SymmetricMaterial) throws -> String {
        guard let text = String(data: body, encoding: .utf8),
              let opening = text.range(of: "<response>"),
              let closing = text.range(of: "</response>"),
              opening.upperBound <= closing.lowerBound,
              let ciphertext = Data(base64Encoded: String(text[opening.upperBound..<closing.lowerBound]))
        else {
            throw MessageEncryptionError.responseShape
        }
        let plaintext = try MessageCrypto.aesCBCDecrypt(ciphertext, key: material.key, iv: material.iv)
        guard let acknowledgment = String(data: plaintext, encoding: .utf8) else {
            throw MessageEncryptionError.decryptionFailed
        }
        return acknowledgment
    }
}

final class UnavailableMessageEncryption: MessageEncryptionProtocol, @unchecked Sendable {
    private let message: String

    init(message: String) {
        self.message = message
    }

    func seal(message _: String) throws -> SealedMessage {
        throw UnavailableMessageEncryptionError(message: message)
    }

    func openResponse(_: Data, material _: SymmetricMaterial) throws -> String {
        throw UnavailableMessageEncryptionError(message: message)
    }
}

struct UnavailableMessageEncryptionError: LocalizedError, Sendable {
    let message: String

    var errorDescription: String? {
        message
    }
}
