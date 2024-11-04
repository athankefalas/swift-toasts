//
//  AnyAnimationProperty.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 8/10/24.
//

import Foundation

public struct AnyAnimationProperty: AnimatableProperty {
    public let name: AnimatablePropertyName
    public let fromValue: Any
    public let toValue: Any
    
    init<Property: AnimatableProperty>(_ property: Property) {
        self.name = property.name
        self.fromValue = property.fromValue
        self.toValue = property.toValue
    }
}

public extension AnimatableProperty {
    
    func erased() -> AnyAnimationProperty {
        AnyAnimationProperty(self)
    }
}
