//
//  CryptoUtils.swift
//  vulnabankIOs
//

import Foundation

import SwiftyRSA
import CryptoSwift

typealias Base64 = String

protocol CryptoUtilsProtocol {
    func encryptAES(message: String) -> Array<UInt8>?
    func decryptAES(message: Array<UInt8>) -> String?
    func encryptRSA() -> Base64?
    func signRSA(message: Array<UInt8>) -> Base64?
}

final class CryptoUtils: CryptoUtilsProtocol {
    
    func encryptAES(message: String) -> Array<UInt8>? {
        guard let aes = try? AES(key: Constants.Values.AES_KEY, iv: Constants.Values.AES_IV) ,
            let cipherText = try? aes.encrypt(Array(message.utf8)) else {
                return nil
        }
        return cipherText
    }
    
    func decryptAES(message: Array<UInt8>) -> String? {
        guard let aes = try? AES(key: Constants.Values.AES_KEY, iv: Constants.Values.AES_IV) ,
            let decrypted = try? aes.decrypt(message) else {
                return nil
        }
        return String(data: Data(decrypted), encoding: .utf8)
    }
    
    func encryptRSA() -> Base64? {
        guard let publicKey = try? PublicKey(pemNamed: "server_pub"),
            let clear = try? ClearMessage(string: Constants.Values.AES_KEY + "|" + Constants.Values.AES_IV, using: .utf8),
            let encrypted = try? clear.encrypted(with: publicKey, padding: .PKCS1) else {
                return nil
        }
        return encrypted.base64String
    }
    
    func signRSA(message: Array<UInt8>) -> Base64? {
        let clear = ClearMessage(data: Data(message))
        guard let privateKey = try? PrivateKey(pemNamed: "client_priv"),
            let signature = try? clear.signed(with: privateKey, digestType: .sha1) else {
                return nil
        }
        return signature.base64String
    }

}
