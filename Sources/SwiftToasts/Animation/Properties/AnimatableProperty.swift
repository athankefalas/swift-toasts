//
//  AnimatableProperty.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

import SwiftUI

public enum AnimatablePropertyName: String {
    case opacity
    case transform
}

public protocol AnimatableProperty {
    associatedtype Value
    
    var name: AnimatablePropertyName { get }
    var fromValue: Value { get }
    var toValue: Value { get }
}

protocol IntermediateAnimatablePropertyValue {
    
    func convertToAnimatableValue() -> Any
}
