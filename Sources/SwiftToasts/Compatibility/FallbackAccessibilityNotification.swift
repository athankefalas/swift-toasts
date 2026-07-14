//
//  AccessibilityAnnouncement.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 14/7/26.
//

import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit

@MainActor
func platformAccessibilityAnnouncement(_ content: FallbackAccessibilityNotification.Announcement.Content) {
    UIAccessibility.post(notification: .announcement, argument: content.erasedContent)
}

@MainActor
func platformAccessibilityLayoutChanged(_ content: FallbackAccessibilityNotification.LayoutChanged.Content?) {
    UIAccessibility.post(notification: .layoutChanged, argument: content?.rawElement)
}

@MainActor
func platformAccessibilityScreenChanged(_ content: FallbackAccessibilityNotification.ScreenChanged.Content?) {
    UIAccessibility.post(notification: .screenChanged, argument: content?.rawElement)
}

@MainActor
func platformFindElementWithTag(_ tag: Int) -> Any? {
    return UIApplication.shared.connectedScenes
        .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
        .compactMap({ findElementWithTag(tag, inWindow: $0) })
        .first
}

@MainActor
private func findElementWithTag(_ tag: Int, inWindow window: UIWindow) -> Any? {
    if let result = findElementWithTag(tag, in: window) {
        return result
    }
    
    return findElementWithTag(tag, in: window.rootViewController)
}

@MainActor
private func findElementWithTag(_ tag: Int, in viewController: UIViewController?) -> Any? {
    guard let viewController else {
        return nil
    }
    
    if let result = findElementWithTag(tag, in: viewController.view) {
        return result
    }
    
    for childViewController in viewController.children {
        if let result = findElementWithTag(tag, in: childViewController) {
            return result
        }
    }
    
    var modalViewController: UIViewController? = viewController.presentedViewController
    while modalViewController != nil {
        if let result = findElementWithTag(tag, in: modalViewController) {
            return result
        }
        modalViewController = modalViewController?.presentedViewController
    }
    
    return nil
}

@MainActor
private func findElementWithTag(_ tag: Int, in view: UIView?) -> Any? {
    guard let view else { return nil }
    if view.tag == tag {
        return view
    }
    
    for subview in view.subviews {
        if let result = findElementWithTag(tag, in: subview) {
            return result
        }
    }
    
    return nil
}

#elseif canImport(AppKit)
import AppKit

@MainActor
func platformAccessibilityAnnouncement(_ content: FallbackAccessibilityNotification.Announcement.Content) {
    NSAccessibility.post(element: content.erasedContent, notification: .announcementRequested)
}

@MainActor
func platformAccessibilityLayoutChanged(_ content: FallbackAccessibilityNotification.LayoutChanged.Content?) {
    NSAccessibility.post(element: content?.rawElement as Any, notification: .layoutChanged)
}

@MainActor
func platformAccessibilityScreenChanged(_ content: FallbackAccessibilityNotification.ScreenChanged.Content?) {
    NSAccessibility.post(element: content?.rawElement as Any, notification: .focusedWindowChanged)
}

@MainActor
func platformFindElementWithTag(_ tag: Int) -> Any? {
    return NSApplication.shared.windows.flatMap({ [$0] + $0.sheets })
        .compactMap({ findElementWithTag(tag, in: $0) })
        .first
}

@MainActor
private func findElementWithTag(_ tag: Int, in window: NSWindow) -> Any? {
    if let result = findElementWithTag(tag, in: window.contentView) {
        return result
    }
    
    return findElementWithTag(tag, in: window.contentViewController)
}

@MainActor
private func findElementWithTag(_ tag: Int, in viewController: NSViewController?) -> Any? {
    guard let viewController else {
        return nil
    }
    
    if let result = findElementWithTag(tag, in: viewController.view) {
        return result
    }
    
    for childViewController in viewController.children {
        if let result = findElementWithTag(tag, in: childViewController) {
            return result
        }
    }
    
    for presentedViewController in viewController.presentedViewControllers ?? [] {
        if let result = findElementWithTag(tag, in: presentedViewController) {
            return result
        }
    }
    
    return nil
}

@MainActor
private func findElementWithTag(_ tag: Int, in view: NSView?) -> Any? {
    guard let view else { return nil }
    if view.identifier == NSUserInterfaceItemIdentifier(tag.description) {
        return view
    }
    
    for subview in view.subviews {
        if let result = findElementWithTag(tag, in: subview) {
            return result
        }
    }
    
    return nil
}

#else

@MainActor
func platformAccessibilityAnnouncement(_ content: FallbackAccessibilityNotification.Announcement.Content) {}

@MainActor
func platformAccessibilityLayoutChanged(_ content: FallbackAccessibilityNotification.LayoutChanged.Content?) {}

@MainActor
func platformAccessibilityScreenChanged(_ content: FallbackAccessibilityNotification.ScreenChanged.Content?) {}

@MainActor
func platformFindElementWithTag(_ tag: Int) -> Any? { nil }

#endif

enum FallbackAccessibilityNotification {
    
    enum Announcement {
        struct Content {
            let erasedContent: Any
            
            init(string: String) {
                self.erasedContent = string
            }
            
            init(attributedString: NSAttributedString) {
                self.erasedContent = attributedString
            }
            
            @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
            init(attributedString: AttributedString) {
                self.erasedContent = attributedString
            }
        }
        
        @MainActor
        static func post(_ string: String) {
            self.post(Content(string: string))
        }
        
        @MainActor
        static func post(_ attributedString: NSAttributedString) {
            self.post(Content(attributedString: attributedString))
        }
        
        @MainActor
        @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
        static func post(_ attributedString: AttributedString) {
            self.post(Content(attributedString: attributedString))
        }
        
        @MainActor
        static func post(_ content: Content) {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                AccessibilityNotification.Announcement(content).post()
            } else {
                platformAccessibilityAnnouncement(content)
            }
        }
    }
    
    enum LayoutChanged {
        enum Content {
            case toastView
            case element(Any)
            case elementWithTag(Int)
            
            @MainActor
            var rawElement: Any? {
                switch self {
                case .toastView:
                    let tag = SwiftToastsConfiguration.current.toastRootViewTag.hashValue
                    return platformFindElementWithTag(tag)
                case .element(let element):
                    return element
                case .elementWithTag(let tag):
                    return platformFindElementWithTag(tag)
                }
            }
        }
        
        @MainActor
        static func post(_ content: Content?) {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                AccessibilityNotification.LayoutChanged(content).post()
            } else {
                platformAccessibilityLayoutChanged(content)
            }
        }
    }
    
    enum ScreenChanged {
        enum Content {
            case toastView
            case element(Any)
            case elementWithTag(Int)
            
            @MainActor
            var rawElement: Any? {
                switch self {
                case .toastView:
                    let tag = SwiftToastsConfiguration.current.toastRootViewTag.hashValue
                    return platformFindElementWithTag(tag)
                case .element(let element):
                    return element
                case .elementWithTag(let tag):
                    return platformFindElementWithTag(tag)
                }
            }
        }
        
        @MainActor
        static func post(_ content: Content?) {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                AccessibilityNotification.ScreenChanged(content).post()
            } else {
                platformAccessibilityScreenChanged(content)
            }
        }
    }
}

// MARK: AccessibilityNotification + Bridging Initializers

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AccessibilityNotification.Announcement {
    
    @MainActor
    init(_ content: FallbackAccessibilityNotification.Announcement.Content) {
        if let attributedString = content.erasedContent as? AttributedString {
            self = .init(attributedString)
        } else if let attributedString = content.erasedContent as? NSAttributedString {
            self = .init(attributedString)
        } else if let string = content.erasedContent as? String {
            self = .init(string)
        } else {
            self = .init("")
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AccessibilityNotification.LayoutChanged {
    
    @MainActor
    init(_ content: FallbackAccessibilityNotification.LayoutChanged.Content?) {
        self = .init(content?.rawElement)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AccessibilityNotification.ScreenChanged {
    
    @MainActor
    init(_ content: FallbackAccessibilityNotification.ScreenChanged.Content?) {
        self = .init(content?.rawElement)
    }
}
