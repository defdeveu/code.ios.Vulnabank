//
//  DynamicValue.swift
//  vulnabankIOs
//

import Foundation

class DynamicValue<T> {
    
    typealias Listener = (T) -> Void

    var value : T {
        didSet {
            self.notify()
        }
    }

    fileprivate var observers = [Int: Listener]()
    fileprivate var listenerCounter: Int = 0

    init(_ value: T) {
        self.value = value
    }
    
    func addObserver(_ listener: @escaping Listener) {
        observers[listenerCounter] = listener
        listenerCounter += 1
    }
    
    func notify() {
        observers.forEach({ $0.value(value) })
    }
    
    deinit {
        observers.removeAll()
    }
}