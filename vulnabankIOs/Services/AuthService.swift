//
//  AuthService.swift
//  vulnabankIOs
//

import Foundation

protocol AuthServiceProtocol {
    var isAuthenticated: Bool { get }
    var isRegistered: Bool { get }
    var onLoggedIn: DynamicValue<Bool> { get }

    func register(authentication: Authentication)
    func login(authentication: Authentication) -> Bool
    func logout()
}

final class AuthService: AuthServiceProtocol {

    let onLoggedIn: DynamicValue<Bool> = DynamicValue(false)

    var isAuthenticated: Bool {
        get {
            return onLoggedIn.value
        }
    }

    var isRegistered: Bool {
        get {
            if let _ = defaults.object(forKey: Constants.Values.userDefaultAuthPin) {
                return true
            }
            return false
        }
    }

    fileprivate let defaults = UserDefaults.standard

    func register( authentication: Authentication) {
        saveAuthToUserDefaults(authentication: authentication)
        onLoggedIn.value = true
        print("Logged In", to: &logger)

    }

    func login(authentication: Authentication) -> Bool {
        if let loadedAuthentication = loadAuthFormUserDefaults(),
            loadedAuthentication.pin == authentication.pin {
            onLoggedIn.value = true;
            print("Logged In", to: &logger)
            return true
        }
        return false
    }

    func logout() {
        onLoggedIn.value = false;
        print("Logged Out", to: &logger)
    }

}

extension AuthService {

    fileprivate func saveAuthToUserDefaults( authentication: Authentication){
        defaults.set(authentication.pin, forKey: Constants.Values.userDefaultAuthPin)
        backupPinToICloud()
        backupPinToLocalFile()
    }

    fileprivate func loadAuthFormUserDefaults() -> Authentication? {
        if let pin = defaults.string(forKey: Constants.Values.userDefaultAuthPin) {
            return Authentication(pin: pin)
        }
        return nil
    }

    fileprivate func backupPinToICloud() {
        let cloudStore = NSUbiquitousKeyValueStore.default
        cloudStore.set(defaults.string(forKey: Constants.Values.userDefaultAuthPin), forKey: Constants.Values.userDefaultAuthPin)
        cloudStore.synchronize()
    }

    fileprivate func backupPinToLocalFile() {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = documentDirectory.appendingPathComponent(Constants.Values.pinBackupFilename)
            if let pin = defaults.string(forKey: Constants.Values.userDefaultAuthPin),
               let pinData = pin.data(using: .utf8) {
                try? pinData.write(to:fileURL)
            }
        }
    }
}