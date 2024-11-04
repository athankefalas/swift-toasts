//
//  NSAssociatedProperty.swift
//  ToastPlayground
//
//  Created by Sakis Kefalas on 5/10/24.
//

import Foundation
import ObjectiveC

nonisolated(unsafe) private var associationKey: Void?

private extension NSObject {
    
    var _associatedObjectStorage: [AnyHashable: Any] {
        get {
            guard let anyValue = objc_getAssociatedObject(self, &associationKey),
                  let value = anyValue as? [AnyHashable: Any] else {
                return [:]
            }
            
            return value
        }
        
        set {
            objc_setAssociatedObject(self, &associationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

struct NSAssociatedProperty<Value> {
    private let key: AnyHashable
    
    init<Instance: NSObject>(_ keyPath: KeyPath<Instance, Value?>) {
        self.key = keyPath
    }
    
    func getValue(of instance: NSObject) -> Value? {
        guard let value = instance._associatedObjectStorage[key] as? Value else {
            return nil
        }
        
        return value
    }
    
    func set(value: Value?, of instance: NSObject) {
        instance._associatedObjectStorage[key] = value
    }
}

extension NSObject {
    
    subscript<Value>(property: NSAssociatedProperty<Value>) -> Value? {
        get {
            property.getValue(of: self)
        }
        
        set {
            property.set(value: newValue, of: self)
        }
    }
}
