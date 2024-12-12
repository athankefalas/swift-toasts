//
//  ToastBuilder.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 11/10/24.
//

import SwiftUI

@resultBuilder
public struct ToastBuilder {
    
    public typealias BuiltResult = Optional<Toast>
    
    public enum IntermediateResult {
        case empty
        case toast(Toast)
        
        var value: BuiltResult {
            switch self {
            case .empty:
                return nil
            case .toast(let toast):
                return toast
            }
        }
        
        fileprivate init(_ toast: Toast?) {
            if let toast {
                self = .toast(toast)
            } else {
                self = .empty
            }
        }
    }
    
    public static func buildBlock(_ components: Toast) -> IntermediateResult {
        IntermediateResult(components)
    }
    
    public static func buildBlock(_ components: IntermediateResult) -> IntermediateResult {
        components
    }
    
    @available(*, unavailable, message: "Only a single toast element can be built at a time.")
    public static func buildBlock(_ components: IntermediateResult...) -> IntermediateResult {
        components.last ?? .empty
    }
    
    public static func buildExpression(_ expression: Toast) -> IntermediateResult {
        IntermediateResult(expression)
    }
    
    public static func buildExpression(_ expression: IntermediateResult) -> IntermediateResult {
        expression
    }
    
    public static func buildOptional(_ component: IntermediateResult?) -> IntermediateResult {
        component ?? .empty
    }

    public static func buildEither(first: IntermediateResult) -> IntermediateResult {
        first
    }

    public static func buildEither(second: IntermediateResult) -> IntermediateResult {
        second
    }
    
    public static func buildFinalResult(_ component: IntermediateResult) -> BuiltResult {
        component.value
    }
}
