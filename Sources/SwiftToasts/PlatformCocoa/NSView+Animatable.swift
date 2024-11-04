//
//  NSView+PlatformAnimatable.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

#if canImport(Cocoa)
import Cocoa
import AppKit
import QuartzCore
import ObjectiveC

@MainActor
private var _enabledLayerTransformAnimations = false

extension NSView: CAAnimatable {
    
    var animatableLayer: CALayer? { layer }
    
    var layerAnimationDelegate: (any CAAnimationDelegate)? {
        get {
            self[NSAssociatedProperty(\NSView.layerAnimationDelegate)]
        }
        
        set {
            self[NSAssociatedProperty(\NSView.layerAnimationDelegate)] = newValue
        }
    }
    
    func willStartAnimation() {
        layer?._isPerformingLayerAnimation = true
    }
    
    func didCompleteAnimation() {
        layer?._isPerformingLayerAnimation = false
    }
    
    public func resetPresentationAnimationProperties() {
        layer?.removeAllAnimations()
        layer?.opacity = 1
        layer?.transform = CATransform3DIdentity
    }
    
    /// Swizzles the backing `CALayer` class of an `NSView` to enable the animation of the `transform` property.
    /// This method should ideally be invoked only once, on an `NSView` instance that has a backing layer after enabling
    /// the backing layer, by setting the `wantsLayer` property to true.
    ///
    /// - Warning: This method may not be necessary in newer macOS versions, and should be invoked
    /// by macOS clients _**only**_ if layer-based transform animations are not working in a platform version they support.
    public func _cocoaPlatformEnableLayerTransformAnimations() {
        guard let backingLayer = layer,
              !_enabledLayerTransformAnimations else {
            return
        }
        
        CALayer.swizzle(layer: backingLayer)
        _enabledLayerTransformAnimations = true
    }
}

extension CALayer {
    
    var _isPerformingLayerAnimation: Bool? {
        get {
            self[NSAssociatedProperty(\CALayer._isPerformingLayerAnimation)] ?? false
        }
        
        set {
            self[NSAssociatedProperty(\CALayer._isPerformingLayerAnimation)] = newValue
        }
    }
    
    @objc
    private func _modified_setAnchorPoint(_ point: CGPoint) {
        let isPerformingLayerAnimation = _isPerformingLayerAnimation ?? false
        
        guard !isPerformingLayerAnimation else {
            return
        }
        
        _modified_setAnchorPoint(point)
    }
    
    @objc
    private func _modified_setAffineTransform(_ transform: CGAffineTransform) {
        let isPerformingLayerAnimation = _isPerformingLayerAnimation ?? false
        
        guard !isPerformingLayerAnimation else {
            return
        }
        
        _modified_setAffineTransform(transform)
    }
    
    /// Swizles the backing layer of an NSView to allow for transform animations. This may not be needed in recent versions of macOS.
    /// - Parameter layer: An instance of `CALayer` such as `_NSBackingLayer` that is used by AppKit to back an NSView.
    static func swizzle<Layer: CALayer>(layer: Layer) {
        let setAnchorPointSelector = Selector(("setAnchorPoint:"))
        let modified_setAnchorPointSelector = #selector(self._modified_setAnchorPoint(_:))
        
        if let setAnchorPointSelectorMethod = class_getInstanceMethod(Layer.self, setAnchorPointSelector),
           let modified_setAnchorPointSelectorMethod = class_getInstanceMethod(Layer.self, modified_setAnchorPointSelector) {
            
            method_exchangeImplementations(
                setAnchorPointSelectorMethod,
                modified_setAnchorPointSelectorMethod
            )
        }
        
        let setAffineTransformSelector = #selector(self.setAffineTransform(_:))
        let modified_setAffineTransformSelector = #selector(self._modified_setAffineTransform(_:))
        
        if let setAffineTransformSelectorMethod = class_getInstanceMethod(Layer.self, setAffineTransformSelector),
           let modified_setAffineTransformSelectorMethod = class_getInstanceMethod(Layer.self, modified_setAffineTransformSelector) {
            
            method_exchangeImplementations(
                setAffineTransformSelectorMethod,
                modified_setAffineTransformSelectorMethod
            )
        }
    }
}

#endif
