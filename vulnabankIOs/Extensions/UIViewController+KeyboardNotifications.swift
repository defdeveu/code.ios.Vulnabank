//
//  UIViewController+KeyboardNotifications.swift
//  vulnabankIOs
//
//  Created by feco on 2020. 06. 11..
//  Copyright © 2020. sagifer. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
 
    func regiserKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
            
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardSizeEnd = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardSizeBegin = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            UIApplication.shared.applicationState == .active else {
                return
        }
        
        var offsetY: CGFloat = 0.0
        let offsetDivider = (view.frame.height - 450 )
        let offsetMultiplier: CGFloat = 70
        
        if notification.name == UIResponder.keyboardWillHideNotification, view.frame.origin.y < 0 {
            offsetY = keyboardSizeBegin.height / offsetDivider * offsetMultiplier
        } else if notification.name == UIResponder.keyboardWillShowNotification, view.frame.origin.y >= 0 {
            offsetY = -keyboardSizeEnd.height / offsetDivider * offsetMultiplier
        }
        
        UIView.animate(withDuration: 3, animations: {
            self.view.frame = self.view.frame.insetBy(dx: 0, dy: offsetY)
            self.view.layoutIfNeeded()
        })
    
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}
