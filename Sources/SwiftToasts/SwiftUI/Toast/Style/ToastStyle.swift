//
//  ToastStyle.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI
import Combine

@MainActor
public protocol ToastStyle: Sendable {
    typealias Configuration = ToastConfiguration
    associatedtype Body: View
    
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}
