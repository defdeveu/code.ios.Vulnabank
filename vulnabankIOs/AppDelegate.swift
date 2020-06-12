//
//  AppDelegate.swift
//  vulnabankIOs
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    let mainStoryboard: UIStoryboard = UIStoryboard( name: Constants.StoryBoarsIds.main, bundle: nil )
    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
      
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Application Start", to: &logger)
 
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = self.mainStoryboard.instantiateViewController( withIdentifier: Constants.StoryBoarsIds.navigationController )
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        DeepLink().doAction(withUrl: url)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        authService.logout()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        authService.logout()
        print("Application Did Become Active", to: &logger)
    }
}

