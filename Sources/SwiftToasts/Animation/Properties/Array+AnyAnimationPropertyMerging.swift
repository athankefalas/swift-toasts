//
//  Array+AnyAnimationPropertyMerging.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 3/11/24.
//

import Foundation

extension Array where Element == AnyAnimationProperty {
    
    static func reduceByMerging(
        animationProperties: [AnyAnimationProperty]
    ) -> [AnyAnimationProperty] {
        
        var propertyAnimations: [AnimatablePropertyName : [AnyAnimationProperty]] = [
            .opacity : [],
            .transform : []
        ]
        
        for element in animationProperties {
            propertyAnimations[element.name]?.append(element)
        }
        
        let opacityAnimations = reduceOpacityAnimations(
            animationProperties: propertyAnimations[.opacity] ?? []
        )
        
        let transformAnimations = reduceTransformAnimations(
            animationProperties: propertyAnimations[.transform] ?? []
        )
        
        return opacityAnimations + transformAnimations
    }

    private static func reduceOpacityAnimations(
        animationProperties: [AnyAnimationProperty]
    ) -> [AnyAnimationProperty] {
        
        guard animationProperties.count > 1 else {
            return animationProperties
        }
        
        let opacityProperties = animationProperties
            .compactMap { element -> OpacityProperty? in
                guard let fromValue = element.fromValue as? CGFloat,
                      let toValue = element.toValue as? CGFloat else {
                    return nil
                }
                
                return OpacityProperty(
                    fromValue: fromValue,
                    toValue: toValue
                )
            }

        guard !opacityProperties.isEmpty else {
            return []
        }

        let count = CGFloat(opacityProperties.count)
        let averageFromValue = opacityProperties.reduce(0) { $0 + $1.fromValue } / count
        let averageToValue = opacityProperties.reduce(0) { $0 + $1.toValue } / count

        return [
            OpacityProperty(
                fromValue: averageFromValue,
                toValue: averageToValue
            ).erased()
        ]
    }

    private static func reduceTransformAnimations(
        animationProperties: [AnyAnimationProperty]
    ) -> [AnyAnimationProperty] {
        
        guard animationProperties.count > 1 else {
            return animationProperties
        }
        
        return animationProperties
            .compactMap { element in
                guard let fromValue = element.fromValue as? TransformProperty.Value,
                      let toValue = element.toValue as? TransformProperty.Value else {
                    return TransformProperty?.none
                }
                
                return TransformProperty(fromValue: fromValue, toValue: toValue)
            }
            .reduce(into: TransformProperty?.none) { partialResult, animation in
                guard let result = partialResult else {
                    partialResult = animation
                    return
                }
                
                partialResult = TransformProperty(
                    fromValue: result.fromValue + animation.fromValue,
                    toValue: result.toValue + animation.toValue
                )
            }
            .map { transformProperty in
                [transformProperty.erased()]
            } ?? []
    }
}
