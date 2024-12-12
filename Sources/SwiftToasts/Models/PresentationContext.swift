//
//  PresentationContext.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 23/10/24.
//

import Foundation

/// A platform agnostic representation of a single node in the currently presented view hierarchy.
@MainActor
public final class PresentationContext {
    
    /// An attribute that provides some semantic context to a platform component that is displayed in a view hierarchy.
    public enum Attribute: String, Hashable, CustomStringConvertible {
        /// This attribute indicates that this node is a view.
        case view
        
        /// This attribute indicates that this node is a menu modal.
        case menu
        /// This attribute indicates that this node is a sheet modal.
        case sheet
        /// This attribute indicates that this node is an aler modalt.
        case alert
        /// This attribute indicates that this node is a popover modal.
        case popover
        /// This attribute indicates that this node is a modal.
        case modal
        
        /// This attribute indicates that this node is a window that manages one or more containers.
        case window
        /// This attribute indicates that this node is a container that manages the presentation of a view.
        case container
        /// This attribute indicates that this node is part of the system view hierarchy and can be discarded.
        case discardable
        
        /// This attribute indicates that this node is a semantic placeholder that is not part of the view hierarchy and is specially handled.
        case semantic
        
        public var description: String {
            rawValue
        }
    }
    
    /// The platform specific owner of this node.
    final public private(set) weak var owner: AnyObject?
    
    /// Any semantic attributes that describe the this node.
    final public private(set) var attributes: Set<Attribute>
    
    /// A collection of sibling nodes.
    final public private(set) var siblings: [PresentationContext]
    
    /// A collection of children nodes.
    final public private(set) var children: [PresentationContext]
    
    private let _parent: @MainActor () -> PresentationContext?
    
    /// The parent node or `nil` if this node is the root node.
    /// - Note: This property is lazily computed and it may produce inconsistent results
    ///  if the owner has been released.
    final public var parent: PresentationContext? {
        _parent()
    }
    
    init(
        owner: AnyObject,
        attributes: Set<Attribute>,
        parent: @escaping @MainActor () -> PresentationContext?,
        siblings: [PresentationContext],
        children: [PresentationContext]
    ) {
        self.owner = owner
        self.attributes = attributes
        self._parent = parent
        self.siblings = siblings
        self.children = children
    }
    
    final func findRoot() -> PresentationContext {
        if let parent = parent,
           !parent.attributes.contains(.discardable) {
            return parent.findRoot()
        }
        
        return self
    }
    
    final func _printHierarchy(prefix: String = "") {
        print("\(prefix)Node (\(ownerClassName())): \(attributes)")
        print("\(prefix)Children: \(children.isEmpty ? "None." : "")")
        
        for child in children {
            child._printHierarchy(prefix: prefix + "\t")
        }
    }
    
    private final func ownerClassName() -> String {
        guard let owner else {
            return "nil"
        }
        
        guard let nsObject = owner as? NSObject else {
            return "\(type(of: owner))"
        }
        
        return NSStringFromClass(type(of: nsObject))
    }
}

// MARK: Platform UIKit

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension PresentationContext {
    
    convenience init(_ window: UIWindow) {
        self.init(
            owner: window,
            attributes: [.window, .container],
            parent: { nil },
            siblings: [],
            children: [PresentationContext(window.rootViewController)].compactMap({ $0 })
        )
    }
    
    convenience init?(_ viewController: UIViewController?) {
        
        guard let viewController else {
            return nil
        }
        
        self.init(
            owner: viewController,
            attributes: Self.findAttributes(of: viewController),
            parent: { [weak viewController] in
                guard let viewController else {
                    return nil
                }
                
                if let parent = viewController.presentingViewController {
                    return PresentationContext(parent)
                }
                
                if let window = viewController.view.window {
                    return PresentationContext(window)
                }
                
                return nil
            },
            siblings: [],
            children: Self.findChildren(of: viewController)
        )
    }
    
    convenience init?(_ view: UIView?) {
        
        guard let view else {
            return nil
        }
        
        self.init(
            owner: view,
            attributes: [.view],
            parent: { nil },
            siblings: [],
            children: []
        )
    }
    
    private static func findAttributes(
        of viewController: UIViewController
    ) -> Set<Attribute> {
        let className = "\(type(of: viewController))"
        var attributes: Set<Attribute> = [.container]
        
        if viewController is UIAlertController {
            attributes.insert(.alert)
        }
        
#if !os(tvOS)
        if viewController is UIActivityViewController {
            attributes.insert(.menu)
            attributes.insert(.sheet)
        }
#endif
        
        if viewController.presentingViewController != nil {
            attributes.insert(.modal)
            
#if !os(tvOS)
            if viewController.modalPresentationStyle == .popover {
                attributes.insert(.popover)
            }

            if #available(iOS 15, *) {
                if viewController.sheetPresentationController != nil {
                    attributes.insert(.sheet)
                }
            } else { // Fallback by checking modalPresentationStyle
                if viewController.modalPresentationStyle == .pageSheet || viewController.modalPresentationStyle == .formSheet {
                    attributes.insert(.sheet)
                }
            }
#endif
            
            if className.hasPrefix("_UI") && className.contains("ContextMenu") {
                attributes.insert(.menu)
            }
        }
        
        return attributes
    }
    
    private static func findChildren(
        of viewController: UIViewController
    ) -> [PresentationContext] {
        var children = [PresentationContext(viewController.view)]
        
        if let child = viewController.presentedViewController {
            children.append(PresentationContext(child))
        }
        
        return children.compactMap({ $0 })
    }
}

#endif

// MARK: Platform Cocoa

#if canImport(Cocoa)
import Cocoa

public extension PresentationContext {
    
    convenience init(_ window: NSWindow) {
        self.init(
            owner: window,
            attributes: Self.findAttributes(of: window),
            parent: { [weak window] in
                guard let window,
                      let parent = window.parent else {
                    return nil
                }
                
                return PresentationContext(parent)
            },
            siblings: Self.findSiblings(of: window),
            children: Self.findChildren(of: window)
        )
    }
    
    private static func findAttributes(
        of window: NSWindow
    ) -> Set<Attribute> {
        var attributes: Set<Attribute> = [.window, .container]
        
        if window.isSheet {
            attributes.insert(.modal)
            attributes.insert(.sheet)
        }
                
        if window.delegate is NSPopover || window.className.contains("NSPopover") {
            attributes.insert(.popover)
        }
        
        if window.delegate is NSAlert || window.className.contains("NSAlert") {
            attributes.insert(.alert)
        }
        
        switch window.level {
        case .floating:
            attributes.insert(.menu)
        case .submenu:
            attributes.insert(.menu)
        case .tornOffMenu:
            attributes.insert(.menu)
        case .mainMenu:
            attributes.insert(.menu)
        case .statusBar:
            attributes.insert(.discardable)
        case .modalPanel:
            attributes.insert(.modal)
        case .popUpMenu:
            attributes.insert(.menu)
        case .screenSaver:
            attributes.insert(.discardable)
        case .dock:
            attributes.insert(.discardable)
        default:
            break
        }
        
        return attributes
    }
    
    private static func findSiblings(
        of window: NSWindow
    ) -> [PresentationContext] {
        
        guard let parent = window.parent else {
            return []
        }
        
        return NSApplication.shared
            .windows
            .filter({ $0 !== window && $0.parent === parent })
            .map({ PresentationContext($0) })
    }
    
    private static func findChildren(
        of window: NSWindow
    ) -> [PresentationContext] {
        let windows = NSApplication.shared
            .windows
            .filter({ $0 !== window && $0.parent === window })
        
        var childWindows: [NSWindow] = []
        
        for window in windows {
            if !childWindows.contains(window) {
                childWindows.append(window)
            }
        }
        
        for window in window.sheets {
            if !childWindows.contains(window) {
                childWindows.append(window)
            }
        }
        
        for window in window.childWindows ?? [] {
            if !childWindows.contains(window) {
                childWindows.append(window)
            }
        }
        
        var childrenContexts: [PresentationContext] = []
        
        if let childContext = PresentationContext(window.contentViewController) ?? PresentationContext(window.contentView) {
            childrenContexts.append(childContext)
        }
        
        return childWindows.map({ PresentationContext($0) }) + childrenContexts
    }
    
    convenience init?(_ viewController: NSViewController?) {
        
        guard let viewController else {
            return nil
        }
        
        self.init(
            owner: viewController,
            attributes: Self.findAttributes(of: viewController),
            parent: { [weak viewController] in
                guard let viewController else {
                    return nil
                }
                
                if let parent = viewController.presentingViewController {
                    return PresentationContext(parent)
                }
                
                if let window = viewController.view.window {
                    return PresentationContext(window)
                }
                
                return nil
            },
            siblings: [],
            children: Self.findChildren(of: viewController)
        )
    }
    
    private static func findAttributes(
        of viewController: NSViewController
    ) -> Set<Attribute> {
        var attributes: Set<Attribute> = [.container]
        
        if viewController.presentingViewController != nil {
            attributes.insert(.modal)
        }
        
        return attributes
    }
    
    private static func findChildren(
        of viewController: NSViewController
    ) -> [PresentationContext] {
        var children = [PresentationContext(viewController.view)]
        
        for child in viewController.presentedViewControllers ?? [] {
            children.append(PresentationContext(child))
        }
        
        return children.compactMap({ $0 })
    }
    
    convenience init?(_ view: NSView?) {
        
        guard let view else {
            return nil
        }
        
        self.init(
            owner: view,
            attributes: [.view],
            parent: { nil },
            siblings: [],
            children: []
        )
    }
}

#endif

// MARK: Platform VisionOS UIKit

#if canImport(UIKit) && os(visionOS)
import UIKit
import SwiftUI

public extension PresentationContext {
    
    convenience init(ornament: ToastOrnament) {
        self.init(
            owner: ornament,
            attributes: [.semantic],
            parent: { nil },
            siblings: [],
            children: []
        )
    }
}
#endif
