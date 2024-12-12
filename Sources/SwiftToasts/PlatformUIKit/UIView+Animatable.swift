//
//  UIView+PlatformAnimatable.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIView: CAAnimatable {
    
    var animatableLayer: CALayer? { layer }
    
    var layerAnimationDelegate: (any CAAnimationDelegate)? {
        get {
            self[NSAssociatedProperty(\UIView.layerAnimationDelegate)]
        }
        
        set {
            self[NSAssociatedProperty(\UIView.layerAnimationDelegate)] = newValue
        }
    }
    
    public func resetPresentationAnimationProperties() {
        layer.removeAllAnimations()
        layer.opacity = 1
        layer.transform = CATransform3DIdentity
    }
}

#endif
