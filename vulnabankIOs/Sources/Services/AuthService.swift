import Foundation

@MainActor
protocol AuthServiceProtocol: AnyObject {
    var isRegistered: Bool { get }
    var isAuthenticated: Bool { get }

    func register(pin: String)
    func login(pin: String) -> Bool
    func logout()
}

@MainActor
final class AuthService: AuthServiceProtocol {
    private(set) var isAuthenticated = false

    private let defaults = UserDefaults.standard

    var isRegistered: Bool {
        defaults.object(forKey: Constants.Values.userDefaultAuthPin) != nil
    }

    func register(pin: String) {
        defaults.set(pin, forKey: Constants.Values.userDefaultAuthPin)
        backupPinToICloud(pin)
        backupPinToLocalFile(pin)
        isAuthenticated = true
        logger.log("Logged In")
    }

    func login(pin: String) -> Bool {
        guard let storedPin = defaults.string(forKey: Constants.Values.userDefaultAuthPin),
              storedPin == pin
        else {
            return false
        }
        isAuthenticated = true
        logger.log("Logged In")
        return true
    }

    func logout() {
        isAuthenticated = false
        logger.log("Logged Out")
    }
}

extension AuthService {
    private func backupPinToICloud(_ pin: String) {
        let cloudStore = NSUbiquitousKeyValueStore.default
        cloudStore.set(pin, forKey: Constants.Values.userDefaultAuthPin)
        cloudStore.synchronize()
    }

    private func backupPinToLocalFile(_ pin: String) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        let fileURL = documentDirectory.appendingPathComponent(Constants.Values.pinBackupFilename)
        try? Data(pin.utf8).write(to: fileURL)
    }
}
