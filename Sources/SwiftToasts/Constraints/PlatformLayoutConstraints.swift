//
//  PlatformLayoutConstraints.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 9/10/24.
//

import SwiftUI

#if (canImport(UIKit) || canImport(Cocoa)) && !os(watchOS)

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@MainActor
enum PlatformLayoutConstraints {
    
    @MainActor
    struct Center {
        let x: NSLayoutXAxisAnchor
        let y: NSLayoutYAxisAnchor
    }
    
    @MainActor
    struct Anchors {
        let top: NSLayoutYAxisAnchor
        let trailing: NSLayoutXAxisAnchor
        let bottom: NSLayoutYAxisAnchor
        let leading: NSLayoutXAxisAnchor
        let center: Center
    }
    
    static func placing(
        anchors: Anchors,
        inside containerAnchors: Anchors,
        alignment: ToastAlignment,
        insets: EdgeInsets? = nil
    ) -> [NSLayoutConstraint] {
        let stickyEdges = alignment.rawValue
        var constraints: [NSLayoutConstraint] = [
            // Leading Constraint
            constraint(
                anchors.leading,
                containerAnchors.leading,
                sticky: stickyEdges.contains(.leading),
                inset: insets?.leading
            ),
            
            // Top Constraint
            constraint(
                anchors.top,
                containerAnchors.top,
                sticky: stickyEdges.contains(.top),
                inset: insets?.top
            ),
            
            // Trailing Constraint
            constraint(
                containerAnchors.trailing,
                anchors.trailing,
                sticky: stickyEdges.contains(.trailing),
                inset: insets?.trailing
            ),
            
            // Bottom Constraint
            constraint(
                containerAnchors.bottom,
                anchors.bottom,
                sticky: stickyEdges.contains(.bottom),
                inset: insets?.bottom
            )
        ]
        
        if !stickyEdges.contains(.leading) && !stickyEdges.contains(.trailing) {
            // CenterX
            constraints.append(
                constraint(
                    anchors.center.x,
                    containerAnchors.center.x
                )
            )
        }
        
        if !stickyEdges.contains(.top) && !stickyEdges.contains(.bottom) {
            // CenterY
            constraints.append(
                constraint(
                    anchors.center.y,
                    containerAnchors.center.y
                )
            )
        }
        
        return constraints
    }
    
    private static func constraint(
        _ one: NSLayoutXAxisAnchor,
        _ other: NSLayoutXAxisAnchor,
        sticky: Bool = true,
        inset: CGFloat? = nil
    ) -> NSLayoutConstraint {
        
        guard let inset else {
            return constraint(one, other, sticky: sticky)
        }
        
        if sticky {
            return one.constraint(equalTo: other, constant: inset)
        } else {
            return one.constraint(greaterThanOrEqualTo: other, constant: inset)
        }
    }
    
    private static func constraint(
        _ one: NSLayoutXAxisAnchor,
        _ other: NSLayoutXAxisAnchor,
        sticky: Bool
    ) -> NSLayoutConstraint {
        
        if sticky {
            return one.constraint(equalTo: other)
        } else {
            return one.constraint(greaterThanOrEqualTo: other)
        }
    }
    
    private static func constraint(
        _ one: NSLayoutYAxisAnchor,
        _ other: NSLayoutYAxisAnchor,
        sticky: Bool = true,
        inset: CGFloat? = nil
    ) -> NSLayoutConstraint {
        
        guard let inset else {
            return constraint(one, other, sticky: sticky)
        }
        
        if sticky {
            return one.constraint(equalTo: other, constant: inset)
        } else {
            return one.constraint(greaterThanOrEqualTo: other, constant: inset)
        }
    }
    
    private static func constraint(
        _ one: NSLayoutYAxisAnchor,
        _ other: NSLayoutYAxisAnchor,
        sticky: Bool
    ) -> NSLayoutConstraint {
        
        if sticky {
            return one.constraint(equalTo: other)
        } else {
            return one.constraint(greaterThanOrEqualTo: other)
        }
    }
}

#if canImport(UIKit)

extension PlatformLayoutConstraints {
    
    static func placing(
        view: UIView,
        inside container: UIView,
        alignment: ToastAlignment,
        insets: EdgeInsets? = nil
    ) -> [NSLayoutConstraint] {
        return placing(
            anchors: Anchors(of: view),
            inside: Anchors.containerAnchorsOf(container: container),
            alignment: alignment,
            insets: insets
        )
    }
}

extension PlatformLayoutConstraints.Center {
    
    init(of view: UIView) {
        self.init(
            x: view.centerXAnchor,
            y: view.centerYAnchor
        )
    }
}

extension PlatformLayoutConstraints.Anchors {
    
    static func containerAnchorsOf(
        container: UIView,
        ignoringSafeArea: Bool = false
    ) -> PlatformLayoutConstraints.Anchors {
#if !os(tvOS)
        if #available(iOS 15, *) {
            return PlatformLayoutConstraints.Anchors(
                top: ignoringSafeArea ? container.topAnchor : container.safeAreaLayoutGuide.topAnchor,
                trailing: ignoringSafeArea ? container.trailingAnchor : container.safeAreaLayoutGuide.trailingAnchor,
                bottom: ignoringSafeArea ? container.bottomAnchor : container.keyboardLayoutGuide.topAnchor,
                leading: ignoringSafeArea ? container.leadingAnchor : container.safeAreaLayoutGuide.leadingAnchor,
                center: PlatformLayoutConstraints.Center(
                    of: container
                )
            )
        }
        
        return PlatformLayoutConstraints.Anchors(
            top: ignoringSafeArea ? container.topAnchor : container.safeAreaLayoutGuide.topAnchor,
            trailing: ignoringSafeArea ? container.trailingAnchor : container.safeAreaLayoutGuide.trailingAnchor,
            bottom: ignoringSafeArea ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor,
            leading: ignoringSafeArea ? container.leadingAnchor : container.safeAreaLayoutGuide.leadingAnchor,
            center: PlatformLayoutConstraints.Center(
                of: container
            )
        )
#else
        PlatformLayoutConstraints.Anchors(
            top: ignoringSafeArea ? container.topAnchor : container.safeAreaLayoutGuide.topAnchor,
            trailing: ignoringSafeArea ? container.trailingAnchor : container.safeAreaLayoutGuide.trailingAnchor,
            bottom: ignoringSafeArea ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor,
            leading: ignoringSafeArea ? container.leadingAnchor : container.safeAreaLayoutGuide.leadingAnchor,
            center: PlatformLayoutConstraints.Center(
                of: container
            )
        )
#endif
    }
    
    init(of view: UIView) {
        self.init(
            top: view.topAnchor,
            trailing: view.trailingAnchor,
            bottom: view.bottomAnchor,
            leading: view.leadingAnchor,
            center: PlatformLayoutConstraints.Center(
                of: view
            )
        )
    }
}

#endif

#if canImport(Cocoa)

extension PlatformLayoutConstraints {
    
    static func placing(
        view: NSView,
        inside container: NSView,
        alignment: ToastAlignment,
        insets: EdgeInsets? = nil
    ) -> [NSLayoutConstraint] {
        return placing(
            anchors: Anchors(of: view),
            inside: Anchors.containerAnchorsOf(container: container),
            alignment: alignment,
            insets: insets
        )
    }
}


extension PlatformLayoutConstraints.Center {
    
    init(of view: NSView) {
        self.init(
            x: view.centerXAnchor,
            y: view.centerYAnchor
        )
    }
}

extension PlatformLayoutConstraints.Anchors {
    
    static func containerAnchorsOf(
        container: NSView,
        ignoringSafeArea: Bool = false
    ) -> PlatformLayoutConstraints.Anchors {
        if #available(macOS 11, *) {
            return PlatformLayoutConstraints.Anchors(
                top: ignoringSafeArea ? container.topAnchor : container.safeAreaLayoutGuide.topAnchor,
                trailing: ignoringSafeArea ? container.trailingAnchor : container.safeAreaLayoutGuide.trailingAnchor,
                bottom: ignoringSafeArea ? container.bottomAnchor : container.safeAreaLayoutGuide.bottomAnchor,
                leading: ignoringSafeArea ? container.leadingAnchor : container.safeAreaLayoutGuide.leadingAnchor,
                center: PlatformLayoutConstraints.Center(
                    of: container
                )
            )
        } else {
            return PlatformLayoutConstraints.Anchors(
                top: container.topAnchor,
                trailing: container.trailingAnchor,
                bottom: container.bottomAnchor,
                leading: container.leadingAnchor,
                center: PlatformLayoutConstraints.Center(
                    of: container
                )
            )
        }
    }
    
    init(of view: NSView) {
        self.init(
            top: view.topAnchor,
            trailing: view.trailingAnchor,
            bottom: view.bottomAnchor,
            leading: view.leadingAnchor,
            center: PlatformLayoutConstraints.Center(
                of: view
            )
        )
    }
}

#endif

#endif
