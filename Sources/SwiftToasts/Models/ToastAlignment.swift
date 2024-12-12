//
//  ToastAlignment.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// A type that represents the alignment of a toast.
public struct ToastAlignment: Hashable, CustomStringConvertible, Sendable {
    let rawValue: Edge.Set
    
    public var description: String {
        switch self {
        case .topLeading:
            return "topLeading"
        case .top:
            return "top"
        case .topTrailing:
            return "topTrailing"
        case .leading:
            return "leading"
        case .center:
            return "center"
        case .trailing:
            return "trailing"
        case .bottomLeading:
            return "bottomLeading"
        case .bottom:
            return "bottom"
        case .bottomTrailing:
            return "bottomTrailing"
        default:
            return "custom(\(rawValue)"
        }
    }
    
    init(rawValue: Edge.Set) {
        self.rawValue = rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.contains(.top))
        hasher.combine(rawValue.contains(.trailing))
        hasher.combine(rawValue.contains(.bottom))
        hasher.combine(rawValue.contains(.leading))
    }
    
    /// The presented toast will be aligned to the top leading edge.
    public static let topLeading = ToastAlignment(rawValue: [.top, .leading])
    
    /// The presented toast will be aligned to the top edge.
    public static let top = ToastAlignment(rawValue: .top)
    
    /// The presented toast will be aligned to the top trailing edge.
    public static let topTrailing = ToastAlignment(rawValue: [.top, .trailing])
    
    /// The presented toast will be aligned to the leading edge.
    public static let leading = ToastAlignment(rawValue: [.leading])
    
    /// The presented toast will be aligned to the center.
    public static let center = ToastAlignment(rawValue: [])
    
    /// The presented toast will be aligned to the trailing edge.
    public static let trailing = ToastAlignment(rawValue: [.trailing])
    
    /// The presented toast will be aligned to the bottom leading edge.
    public static let bottomLeading = ToastAlignment(rawValue: [.bottom, .leading])
    
    /// The presented toast will be aligned to the bottom edge.
    public static let bottom = ToastAlignment(rawValue: .bottom)
    
    /// The presented toast will be aligned to the bottom trailing edge.
    public static let bottomTrailing = ToastAlignment(rawValue: [.bottom, .trailing])
    
    public static var defaultAlignment: ToastAlignment {
#if os(macOS)
        return .topTrailing
#else
        return .top
#endif
    }
}
