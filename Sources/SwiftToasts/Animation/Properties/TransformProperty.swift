//
//  TransformProperty.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 8/10/24.
//

import SwiftUI

/// A visual attribute property that controls an element's transform and can be animated.
public struct TransformProperty: AnimatableProperty {
    public typealias Value = [TransformOperation]
    
    /// A set of axes that can used for rotating a visual elements transform.
    public struct RotationAxis: OptionSet, Hashable, Sendable, CustomStringConvertible {
        public let rawValue: Int
        
        public var description: String {
            var axesStrings: [String] = []
            
            if contains(.x) {
                axesStrings.append("x")
            }
            
            if contains(.y) {
                axesStrings.append("y")
            }
            
            if contains(.z) {
                axesStrings.append("z")
            }
            
            return "[" + axesStrings.joined(separator: ", ") + "]"
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// An empty set of axes.
        public static let none: RotationAxis = []
        
        /// A set with the X axis.
        public static let x = RotationAxis(rawValue: 1 << 0)
        
        /// A set with the Y axis.
        public static let y = RotationAxis(rawValue: 1 << 1)
        
        /// A set with the Z axis.
        public static let z = RotationAxis(rawValue: 1 << 2)
    }
    
    /// An operation that can be used to modify the transform of a visual element.
    public enum TransformOperation: Hashable {
        case scale(x: CGFloat, y: CGFloat, z: CGFloat)
        case translate(x: CGFloat, y: CGFloat, z: CGFloat)
        case rotate(angle: Angle, axes: RotationAxis)
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
