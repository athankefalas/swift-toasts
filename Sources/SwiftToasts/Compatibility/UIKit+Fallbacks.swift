//
//  UIKit+Fallbacks.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 31/10/24.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIWindowScene {
    
    var fallbackKeyWindow: UIWindow? {
        if #available(iOS 15.0, tvOS 15.0, *) {
            self.keyWindow
        } else {  // Fallback on earlier versions
            self.windows.first(where: { $0.isKeyWindow })
        }
    }
}

#endif
