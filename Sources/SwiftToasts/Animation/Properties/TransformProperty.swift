//
//  TransformProperty.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 8/10/24.
//

import SwiftUI

public struct TransformProperty: AnimatableProperty {
    public typealias Value = [TransformOperation]
    
    public enum RotationAxis: Hashable {
        case x
        case y
        case z
    }

    public enum TransformOperation: Hashable {
        case scale(x: CGFloat, y: CGFloat, z: CGFloat)
        case translate(x: CGFloat, y: CGFloat, z: CGFloat)
        case rotate(angle: Angle, axes: Set<RotationAxis>)
    }
    
    public let fromValue: Value
    public let toValue: Value
    
    public var name: AnimatablePropertyName {
        .transform
    }
    
    init(fromValue: Value, toValue: Value) {
        self.fromValue = fromValue
        self.toValue = toValue
    }
}
