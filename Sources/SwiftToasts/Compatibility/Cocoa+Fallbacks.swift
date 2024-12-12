//
//  Cocoa+Fallbacks.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 2/11/24.
//

#if canImport(Cocoa)
import Cocoa

extension NSViewController {
    
    func fallbackLoadViewIfNeeded() {
        if #available(macOS 14.0, *) {
            self.loadViewIfNeeded()
        } else { // Fallback on earlier versions
            guard !self.isViewLoaded else {
                return
            }
            
            self.loadView()
        }
    }
}

#endif
