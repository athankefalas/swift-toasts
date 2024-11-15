//
//  AnyTransition+ToastTransition.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 4/11/24.
//

import SwiftUI

private enum BridgedToastTransitionPhase {
    case inserting
    case removing
    case identity
}

private struct BridgedToastTransitionModifier: ViewModifier {
    
    @MainActor
    struct AnimationValues {
        typealias RotationAxis = (x: CGFloat, y: CGFloat, z: CGFloat)
        
        let curve: ToastTransition.AnimationCurve
        let delay: TimeInterval
        let duration: TimeInterval
        let properties: [AnyAnimationProperty]
        
        let opacity: CGFloat
        let offset: CGSize
        let scale: CGSize
        let rotationAngle: Angle
        let rotationAxes: RotationAxis
        
        var animation: Animation {
            switch curve {
            case .default:
                if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                    return .interactiveSpring(duration: duration)
                        .delay(delay)
                } else {
                    return .easeInOut(duration: duration)
                        .delay(delay)
                }
            case .linear:
                return .linear(duration: duration)
                    .delay(delay)
            case .easeIn:
                return .easeIn(duration: duration)
                    .delay(delay)
            case .easeOut:
                return.easeOut(duration: duration)
                    .delay(delay)
            case .easeInOut:
                return .easeInOut(duration: duration).delay(delay)
            case .spring(let mass, let stiffness, let damping, let initialVelocity, _):
                return .interpolatingSpring(
                    mass: mass,
                    stiffness: stiffness,
                    damping: damping,
                    initialVelocity: initialVelocity
                )
                .delay(delay)
            }
        }
        
        init(
            phase: BridgedToastTransitionPhase,
            presentation: ToastPresentation,
            context: ToastTransition.Context
        ) {
            let transition = presentation.toastTransition
            let properties: [AnyAnimationProperty] = .reduceByMerging(
                animationProperties: transition.animationProperties(context)
            )
            
            self.curve = transition.curve(context)
            self.delay = transition.delay(context)
            self.duration = transition.duration(context)
            self.properties = properties
            self.opacity = Self.opacityValue(
                phase: phase,
                properties: properties
            )
            
            let transformValues = Self.transformValues(
                phase: phase,
                properties: properties
            )
            
            self.offset = transformValues.offset
            self.scale = transformValues.scale
            self.rotationAngle = transformValues.angle
            self.rotationAxes = transformValues.axes
        }
        
        private static func opacityValue(
            phase: BridgedToastTransitionPhase,
            properties: [AnyAnimationProperty]
        ) -> CGFloat {
            guard phase != .identity else {
                return 1
            }
            
            guard let opacityProperty = properties.first(where: { $0.name == .opacity }),
                  let fromValue = opacityProperty.fromValue as? CGFloat,
                  let toValue = opacityProperty.toValue as? CGFloat else {
                return 1
            }
            
            return phase == .inserting ? fromValue : toValue
        }
        
        private static func transformValues(
            phase: BridgedToastTransitionPhase,
            properties: [AnyAnimationProperty]
        ) -> (offset: CGSize, scale: CGSize, angle: Angle, axes: RotationAxis) {
           
            let defaultScale = CGSize(width: 1, height: 1)
            
            guard phase != .identity else {
                return (.zero, defaultScale, .zero, (0, 0, 0))
            }
            
            guard let transformProperty = properties.first(where: { $0.name == .transform }),
                  let fromValue = transformProperty.fromValue as? TransformProperty.Value,
                  let toValue = transformProperty.toValue as? TransformProperty.Value else {
                return (.zero, defaultScale, .zero, (0, 0, 0))
            }
            
            var fromOffsetValue = CGSize.zero
            var fromScaleValue = defaultScale
            var fromAngle = Angle.zero
            var fromAxes: RotationAxis = (0, 0, 0)
            
            for value in fromValue {
                switch value {
                case .translate(x: let x, y: let y, z: _):
                    fromOffsetValue.width = x
                    fromOffsetValue.height = y
                case .scale(x: let x, y: let y, z: _):
                    fromScaleValue.width = x
                    fromScaleValue.height = y
                case .rotate(angle: let angle, axes: let axes):
                    fromAngle = angle
                    fromAxes = (
                        x: axes.contains(.x) ? 1 : fromAxes.x,
                        y: axes.contains(.y) ? 1 : fromAxes.y,
                        z: axes.contains(.z) ? 1 : fromAxes.z
                    )
                }
            }
            
            var toOffsetValue = CGSize.zero
            var toScaleValue = defaultScale
            var toAngle = Angle.zero
            var toAxes: RotationAxis = (0, 0, 0)
            
            for value in toValue {
                switch value {
                case .translate(x: let x, y: let y, z: _):
                    toOffsetValue.width = x
                    toOffsetValue.height = y
                case .scale(x: let x, y: let y, z: _):
                    toScaleValue.width = x
                    toScaleValue.height = y
                case .rotate(angle: let angle, axes: let axes):
                    toAngle = angle
                    toAxes = (
                        x: axes.contains(.x) ? 1 : toAxes.x,
                        y: axes.contains(.y) ? 1 : toAxes.y,
                        z: axes.contains(.z) ? 1 : toAxes.z
                    )
                }
            }
            
            if phase == .inserting {
                return (fromOffsetValue, fromScaleValue, fromAngle, fromAxes)
            } else {
                return (toOffsetValue, toScaleValue, toAngle, toAxes)
            }
        }
    }
    
    @Environment(\.toastPresentingLayoutGeometry)
    private var toastPresentingLayoutGeometry
    
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion
    
    @Environment(\.accessibilityReduceTransparency)
    private var accessibilityReduceTransparency
    
    let phase: BridgedToastTransitionPhase
    let presentation: ToastPresentation
    
    private var context: ToastTransition.Context {
        ToastTransition.Context(
            phase: phase == .inserting ? .toastInsertion : .toastRemoval,
            geometry: toastPresentingLayoutGeometry?.frame ?? .zero,
            windowGeometry: toastPresentingLayoutGeometry?.windowFrame ?? .zero,
            platformIdiom: .current,
            isReduceMotionEnabled: accessibilityReduceMotion,
            isReduceTransparencyEnabled: accessibilityReduceTransparency,
            presentation: presentation
        )
    }
    
    func body(content: Content) -> some View {
        let animationValues = AnimationValues(
            phase: phase,
            presentation: presentation,
            context: context
        )
        
        content
            .compositingGroup()
            .opacity(animationValues.opacity)
            .offset(animationValues.offset)
            .rotation3DEffect(
                animationValues.rotationAngle,
                axis: animationValues.rotationAxes
            )
            .scaleEffect(animationValues.scale)
            .animation(animationValues.animation, value: phase)
    }
}

extension AnyTransition {
    
    static func bridgedToastTransition(
        _ presentation: ToastPresentation
    ) -> AnyTransition {
        return .asymmetric(
            insertion: .modifier(
                active: BridgedToastTransitionModifier(
                    phase: .inserting,
                    presentation: presentation
                ),
                identity: BridgedToastTransitionModifier(
                    phase: .identity,
                    presentation: presentation
                )
            ),
            removal: .modifier(
                active: BridgedToastTransitionModifier(
                    phase: .removing,
                    presentation: presentation
                ),
                identity: BridgedToastTransitionModifier(
                    phase: .identity,
                    presentation: presentation
                )
            )
        )
    }
}
