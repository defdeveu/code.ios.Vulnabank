//
//  NavigationViewModel.swift
//  vulnabankIOs
//

import Foundation
import UIKit

final class NavigationViewModel {

    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
    let onShowAuth: DynamicValue<()> = DynamicValue(())
    let onRemoveAuth: DynamicValue<()> = DynamicValue(())
    
    init() {
        listenOnAuthChanged()
        listenBecameActive()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NavigationViewModel {

    fileprivate func listenBecameActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc fileprivate func applicationDidBecomeActive() {
        if !authService.isAuthenticated {
            onShowAuth.notify()
        }
    }

    fileprivate func listenOnAuthChanged() {
        authService.onLoggedIn.addObserver { [ weak self ] loggedIn in
            if loggedIn {
                self?.onRemoveAuth.notify()
            }
        }
    }
    
}
