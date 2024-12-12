//
//  AnimatablePropertiesBuilder.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/10/24.
//

import Foundation

@resultBuilder
public struct AnimatablePropertiesBuilder {
    
    public static func buildBlock(_ components: [AnyAnimationProperty]...) -> [AnyAnimationProperty] {
        components.flatMap({ $0 })
    }
    
    public static func buildOptional(_ component: [AnyAnimationProperty]?) -> [AnyAnimationProperty] {
        component ?? []
    }
    
    public static func buildEither(first component: [AnyAnimationProperty]) -> [AnyAnimationProperty] {
        component
    }
    
    public static func buildEither(second component: [AnyAnimationProperty]) -> [AnyAnimationProperty] {
        component
    }
    
    public static func buildArray(_ components: [[AnyAnimationProperty]]) -> [AnyAnimationProperty] {
        components.flatMap({ $0 })
    }
    
    public static func buildExpression(_ expression: [AnyAnimationProperty]) -> [AnyAnimationProperty] {
        expression
    }
    
    public static func buildExpression<Property: AnimatableProperty>(_ expression: Property) -> [AnyAnimationProperty] {
        [expression.erased()]
    }
}
