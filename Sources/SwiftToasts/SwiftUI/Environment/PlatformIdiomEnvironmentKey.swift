//
//  PlatformIdiomEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 9/10/24.
//

import SwiftUI

struct PlatformIdiomEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: PlatformIdiom {
        MainActor.assumeIsolated {
            return .current
        }
    }
}

extension EnvironmentValues {
    
    var platformIdiom: PlatformIdiom {
        get { self[PlatformIdiomEnvironmentKey.self] }
    }
}
