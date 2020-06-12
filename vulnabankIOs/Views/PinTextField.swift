//
//  UIPin.swift
//  vulnabankIOs
//
//  Created by feco on 2020. 06. 01..
//  Copyright © 2020. sagifer. All rights reserved.
//

import Foundation
import UIKit

final class PinTextField: UITextField {
    
    let viewModel:PinTextFieldViewModel = PinTextFieldViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.text = textField.text
    }
}

extension PinTextField: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        viewModel.touched = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        viewModel.dirty = true;
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= Constants.Values.pinLength
    }
}
