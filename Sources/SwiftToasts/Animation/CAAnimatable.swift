//
//  CAAnimatable.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 8/10/24.
//

#if (canImport(UIKit) || canImport(Cocoa)) && !os(watchOS)

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#endif

protocol CAAnimatable: Animatable, AnyObject {
    
    @MainActor
    var animatableLayer: CALayer? { get }
    
    @MainActor
    var layerAnimationDelegate: (any CAAnimationDelegate)? { get set }
    
    @MainActor
    func willStartAnimation()
    
    @MainActor
    func didCompleteAnimation()
}

extension CAAnimatable {
    
    func willStartAnimation() {}
    
    func didCompleteAnimation() {}
}

class ClosureAnimationDelegate: NSObject, CAAnimationDelegate {
    private let onStarted: () -> Void
    private let onCompleted: (Bool) -> Void
    
    init(
        onStarted: @escaping () -> Void = {},
        onCompleted: @escaping (Bool) -> Void
    ) {
        self.onStarted = onStarted
        self.onCompleted = onCompleted
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        onStarted()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        onCompleted(flag)
    }
}

extension CAAnimatable {
    
    @MainActor
    func animate(
        transition: ToastTransition,
        in context: ToastTransition.Context,
        completion: @escaping @MainActor (Bool) -> Void
    ) {
        
        let properties: [AnyAnimationProperty] = .reduceByMerging(animationProperties: transition.animationProperties(context))
        let animations = properties
            .compactMap({ makeCAAnimation(from: $0, for: transition, in: context) })
        
        guard let animatableLayer, !animations.isEmpty else {
            return completion(false)
        }
        
        // Reset layer and prepare animatable properties
        animatableLayer.removeAllAnimations()
        properties.forEach({ setValue(\.fromValue, of: $0, to: animatableLayer) })
        
        let delay = transition.delay(context)
        let duration = transition.duration(context)
        let animationGroup = CAAnimationGroup()
        let delegate = ClosureAnimationDelegate { [weak animationGroup, weak self] finished in
            animationGroup?.delegate = nil
            self?.layerAnimationDelegate = nil
            self?.didCompleteAnimation()
            completion(finished)
        }
        
        layerAnimationDelegate = delegate
        animationGroup.delegate = delegate
        animationGroup.animations = animations
        animationGroup.animations?.forEach({ $0.beginTime = 0 })
        animationGroup.beginTime = CACurrentMediaTime() + delay
        animationGroup.fillMode = .both
        animationGroup.duration = animations.map(\.duration).max() ?? duration
        
#if DEBUG
        if isSlowAnimationsFlagEnabled() {
            animationGroup.speed = 0.1
        }
#endif
        
        // Animation
        willStartAnimation()
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        // Set animatable properties to their final value and add animation
        properties.forEach({ setValue(\.toValue, of: $0, to: animatableLayer) })
        animatableLayer.add(animationGroup, forKey: "toastTransition")
        
        CATransaction.commit()
    }
    
    // MARK: AnimationProperty + CALayer
    
    func setValue(
        _ valueKeyPath: KeyPath<AnyAnimationProperty, Any>,
        of property: AnyAnimationProperty,
        to layer: CALayer
    ) {
        switch property.name {
        case .opacity:
            guard let value = property[keyPath: valueKeyPath] as? CGFloat else { preconditionFailure() }
            layer.opacity = Float(value)
        case .transform:
            guard let value = property[keyPath: valueKeyPath] as? TransformProperty.Value else { preconditionFailure() }
            layer.transform = value.makeCATransform3D()
        }
    }
    
    // MARK: AnimationProperty + CAAnimation
    
    @MainActor
    func makeCAAnimation(
        from propertyAnimation: AnyAnimationProperty,
        for transition: ToastTransition,
        in context: ToastTransition.Context
    ) -> CAAnimation? {
        
        let keyPath = propertyAnimation.name.rawValue
        var fromValue = propertyAnimation.fromValue
        var toValue = propertyAnimation.toValue
        
        if let intermediateFromValue = fromValue as? IntermediateAnimatablePropertyValue {
            fromValue = intermediateFromValue.convertToAnimatableValue()
        }
        
        if let intermediateToValue = toValue as? IntermediateAnimatablePropertyValue {
            toValue = intermediateToValue.convertToAnimatableValue()
        }
        
        let transitionCAAnimation: CAAnimation
        
        switch transition.curve(context) {
        case .spring(
            mass: let mass,
            stiffness: let stiffness,
            damping: let damping,
            initialVelocity: let initialVelocity,
            allowOverDamping: let allowOverDamping
        ):
            let springAnimation = CASpringAnimation(keyPath: keyPath)
            springAnimation.mass = mass
            springAnimation.stiffness = stiffness
            springAnimation.damping = damping
            springAnimation.initialVelocity = initialVelocity
            springAnimation.fromValue = fromValue
            springAnimation.toValue = toValue
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
                springAnimation.allowsOverdamping = allowOverDamping
            }
            
            transitionCAAnimation = springAnimation
        default:
            let basicAnimation = CABasicAnimation(keyPath: keyPath)
            basicAnimation.fromValue = fromValue
            basicAnimation.toValue = toValue
            basicAnimation.duration = transition.duration(context)
            basicAnimation.timingFunction = CAMediaTimingFunction(
                name: timingFunction(of: transition.curve(context))
            )
            
            transitionCAAnimation = basicAnimation
        }
        
        transitionCAAnimation.beginTime = CACurrentMediaTime() + transition.delay(context)
        transitionCAAnimation.duration = transition.duration(context)
        transitionCAAnimation.fillMode = .both
        
        return transitionCAAnimation
    }
    
    private func timingFunction(
        of curve: ToastTransition.AnimationCurve
    ) -> CAMediaTimingFunctionName {
        switch curve {
        case .default:
            return .default
        case .linear:
            return .linear
        case .easeIn:
            return .easeIn
        case .easeOut:
            return .easeOut
        case .easeInOut:
            return .easeInEaseOut
        default:
            preconditionFailure("Spring animation curves are handled elsewhere.")
        }
    }
}

// MARK: Animation Debug Tools

#if canImport(UIKit) && targetEnvironment(simulator)
@_silgen_name("UIAnimationDragCoefficient") func UIAnimationDragCoefficient() -> Float

func isSlowAnimationsFlagEnabled() -> Bool {
    return UIAnimationDragCoefficient() != 1.0
}
#else
func isSlowAnimationsFlagEnabled() -> Bool {
    return false
}
#endif

#endif
