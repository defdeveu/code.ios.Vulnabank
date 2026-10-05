import Foundation

enum AppRepository {
    @MainActor
    static func makeAppModel(bundle: Bundle = .main) -> AppModel {
        let config = AppConfig.load(from: bundle)
        let database = DatabaseService()
        let backend = BackendService(endpoint: config.endpoint)

        do {
            let keys = try BundleKeyRepository(bundle: bundle).loadKeys()
            let repository = TransactionRepository(
                backend: backend,
                database: database,
                encryption: MessageEncryption(keys: keys)
            )
            return AppModel(authService: AuthService(), repository: repository)
        } catch {
            let message = "Configuration error: \(error.localizedDescription)"
            logger.log(message)
            let repository = TransactionRepository(
                backend: backend,
                database: database,
                encryption: UnavailableMessageEncryption(message: message)
            )
            return AppModel(authService: AuthService(), repository: repository, initialError: message)
        }
    }
}
