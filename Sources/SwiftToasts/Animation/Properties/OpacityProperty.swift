//
//  OpacityProperty.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 8/10/24.
//

import SwiftUI

public struct OpacityProperty: AnimatableProperty {
    public let fromValue: CGFloat
    public let toValue: CGFloat
    
    public var name: AnimatablePropertyName {
        .opacity
    }
    
    init(fromValue: CGFloat, toValue: CGFloat) {
        self.fromValue = fromValue
        self.toValue = toValue
    }
}
