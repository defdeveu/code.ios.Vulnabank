//
//  PinViewModel.swift
//  vulnabankIOs
//

import Foundation

final class PinTextFieldViewModel {

    let onPinChanged: DynamicValue<String> = DynamicValue("")

    var touched = false
    var dirty = false
    
    var text: String? {
        didSet {
            if let text = text {
                onPinChanged.value = text
            }
        }
    }
    
    var valid: Bool {
        get {
            if let textLength = text?.count {
                if dirty && textLength < Constants.Values.pinLength {
                    return false
                }
            }
            return true
        }
    }
    
    var validLength: Bool {
        get {
            return text?.count == Constants.Values.pinLength
        }
    }

}
