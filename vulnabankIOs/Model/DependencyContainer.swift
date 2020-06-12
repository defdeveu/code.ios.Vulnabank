//
//  Container.swift
//  vulnabankIOs
//

import Foundation
import Swinject

final class DependencyConteiner {
    
    static let shared = DependencyConteiner()
    
    let container = Container()
    
    private init() {
        setupDefaultContainers()
    }
    
    public static func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return shared.container.resolve(serviceType)
    }
    
    private func setupDefaultContainers() {
        container.register(DatabaseDaoProtocol.self ){ _ in DatabaseService()}.inObjectScope(.container)
        container.register(AuthServiceProtocol.self ){ _ in AuthService()}.inObjectScope(.container)
        container.register(BackendServiceProtocol.self ){ _ in BackendService()}.inObjectScope(.container)
        container.register(TransactionRepositoryProtocol.self) { _ in TransactionRepository() }.inObjectScope(.container)
    }
}
