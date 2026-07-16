//
//  ToastContentStyle.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

/// A style that configures the presentation of a `ToastContentView` component.
@MainActor
public protocol ToastContentStyle: Sendable {
    typealias Configuration = ToastContentConfiguration
    associatedtype Body: View
    
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}
