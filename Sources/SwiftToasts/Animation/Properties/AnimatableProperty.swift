//
//  AnimatableProperty.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

import SwiftUI

/// The name of a visual attribute property that can be animated.
public enum AnimatablePropertyName: String {
    case opacity
    case transform
}

/// A visual attribute property that can be animated.
public protocol AnimatableProperty {
    associatedtype Value
    
    var name: AnimatablePropertyName { get }
    var fromValue: Value { get }
    var toValue: Value { get }
}

protocol IntermediateAnimatablePropertyValue {
    
    func convertToAnimatableValue() -> Any
}
