//
//  NavigationViewController.swift
//  vulnabankIOs
//


import Foundation
import UIKit

final class NavigationViewController: UINavigationController {

    let authService = DependencyConteiner.resolve(AuthServiceProtocol.self)!
    
    fileprivate let mainStoryboard: UIStoryboard = UIStoryboard( name: Constants.StoryBoarsIds.main, bundle: nil )
    fileprivate var popOverView: UIViewController?
    fileprivate let viewModel: NavigationViewModel = NavigationViewModel()

    override func viewDidLoad() {
        viewModel.onShowAuth.addObserver() { [weak self] _ in
            self?.showAuthView()
        }
        viewModel.onRemoveAuth.addObserver() { [weak self] _ in
            self?.removeAuthPopup()
        }
    }
    
}

extension NavigationViewController {

    fileprivate func showAuthView() {
        if let _ = popOverView {
            return
        }

        popOverView = authService.isRegistered ?
                mainStoryboard.instantiateViewController( withIdentifier: Constants.StoryBoarsIds.loginViewController ) :
                mainStoryboard.instantiateViewController( withIdentifier: Constants.StoryBoarsIds.registrationViewController )

        if let popOver = popOverView {
            popOver.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            popOver.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            present( popOver, animated: true )
        }

    }

    fileprivate func removeAuthPopup() {
        if let popOver = popOverView {
            popOver.dismiss( animated: true )
            popOverView = nil
        }
    }

}
