//
//  ToastStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// A style that configures the presentation of a `Toast` component.
@MainActor
public protocol ToastStyle: Sendable {
    typealias Configuration = ToastConfiguration
    associatedtype Body: View
    
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}
