import CommonCrypto
import Foundation
import Security

enum MessageCrypto {
    static func rsaEncrypt(_ data: Data, publicKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let encrypted = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1,
            data as CFData,
            &error
        ) else {
            _ = error?.takeRetainedValue()
            throw MessageEncryptionError.encryptionFailed
        }
        return encrypted as Data
    }

    static func rsaSignatureSHA1(of data: Data, privateKey: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA1,
            data as CFData,
            &error
        ) else {
            _ = error?.takeRetainedValue()
            throw MessageEncryptionError.signingFailed
        }
        return signature as Data
    }

    static func aesCBCEncrypt(_ data: Data, key: [UInt8], iv: [UInt8]) throws -> Data {
        try aesCrypt(data, key: key, iv: iv, operation: CCOperation(kCCEncrypt))
    }

    static func aesCBCDecrypt(_ data: Data, key: [UInt8], iv: [UInt8]) throws -> Data {
        try aesCrypt(data, key: key, iv: iv, operation: CCOperation(kCCDecrypt))
    }

    private static func aesCrypt(
        _ data: Data,
        key: [UInt8],
        iv: [UInt8],
        operation: CCOperation
    ) throws -> Data {
        guard !data.isEmpty, !key.isEmpty, iv.count == kCCBlockSizeAES128 else {
            throw operation == CCOperation(kCCEncrypt)
                ? MessageEncryptionError.encryptionFailed
                : MessageEncryptionError.decryptionFailed
        }
        var output = Data(count: data.count + kCCBlockSizeAES128)
        var moved = 0
        let status = output.withUnsafeMutableBytes { outputBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            operation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            data.count,
                            outputBytes.baseAddress,
                            outputBytes.count,
                            &moved
                        )
                    }
                }
            }
        }
        guard status == kCCSuccess else {
            throw operation == CCOperation(kCCEncrypt)
                ? MessageEncryptionError.encryptionFailed
                : MessageEncryptionError.decryptionFailed
        }
        return output.prefix(moved)
    }
}
