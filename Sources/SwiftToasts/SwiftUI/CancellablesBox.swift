//
//  CancellablesBox.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 10/10/24.
//

import SwiftUI
import Combine

@MainActor
final class CancellablesBox: ObservableObject {
    final var cancellables: Set<AnyCancellable>
    
    init() {
        cancellables = []
    }
    
    deinit {
        MainActor.assumeIsolated {
            cancellables.forEach({ $0.cancel() })
            cancellables.removeAll()
        }
    }
}
