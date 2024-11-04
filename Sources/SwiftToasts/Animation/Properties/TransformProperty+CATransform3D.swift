//
//  TransformProperty+CATransform3D.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 8/10/24.
//

#if (canImport(UIKit) || canImport(Cocoa)) && !os(watchOS)
import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

extension Array: IntermediateAnimatablePropertyValue where Element == TransformProperty.TransformOperation {
    
    func convertToAnimatableValue() -> Any {
        makeCATransform3D()
    }
    
    func makeCATransform3D() -> CATransform3D {
        var concatenatedTransform = CATransform3DIdentity
        
        for operation in self {
            var transform = CATransform3DIdentity
            
            switch operation {
            case .scale(x: let x, y: let y, z: let z):
                transform = CATransform3DScale(transform, x, y, z)
            case .translate(x: let x, y: let y, z: let z):
                transform = CATransform3DTranslate(transform, x, y, z)
            case .rotate(angle: let angle, axes: let axes):
                guard axes.count > 1 else {
                    continue
                }
                
                transform = CATransform3DRotate(
                    transform,
                    CGFloat(angle.radians),
                    axes.contains(.x) ? 1 : 0,
                    axes.contains(.y) ? 1 : 0,
                    axes.contains(.z) ? 1 : 0
                )
            }
            
            if isScaleTransform(transform) {
                concatenatedTransform = CATransform3DConcat(transform, concatenatedTransform)
            } else {
                concatenatedTransform = CATransform3DConcat(concatenatedTransform, transform)
            }
        }
        
        return concatenatedTransform
    }
    
    private func isScaleTransform(_ t: CATransform3D) -> Bool {
        // Scale t = [sx 0 0 0; 0 sy 0 0; 0 0 sz 0; 0 0 0 1].
        let sx = t.m11
        let sy = t.m22
        let sz = t.m33
        
        return abs(sx - 1.0) > 0 || abs(sy - 1.0) > 0 || abs(sz - 1.0) > 0
    }
}

#endif
