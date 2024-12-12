//
//  EnvironmentReaderModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/11/24.
//

import SwiftUI

private struct EnvironmentReaderModifier<Value: Equatable>: ViewModifier {
    
    @Environment
    private var environmentValue: Value
    
    @Binding
    var value: Value
    
    init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        value: Binding<Value>
    ) {
        self._environmentValue = Environment(keyPath)
        self._value = value
    }
    
    func body(content: Content) -> some View {
        content
            .fallbackOnChange(of: environmentValue) { newValue in
                value = environmentValue
            }
            .onAppear {
                value = environmentValue
            }
    }
}

extension View {
    
    func assignEnvironment<Value: Equatable>(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        to binding: Binding<Value>
    ) -> some View {
        self.modifier(
            EnvironmentReaderModifier(
                keyPath,
                value: binding
            )
        )
    }
}
