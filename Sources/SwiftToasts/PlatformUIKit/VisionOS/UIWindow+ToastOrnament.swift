//
//  UIWindow+ToastOrnament.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 3/12/24.
//

#if canImport(UIKit) && canImport(SwiftUI) && os(visionOS)
import UIKit
import SwiftUI

extension UIWindow {
    
    private var toastOrnament: UIToastHostingOrnament? {
        get {
            let property = NSAssociatedProperty(\UIWindow.toastOrnament)
            return self[property]
        }
        
        set {
            let property = NSAssociatedProperty(\UIWindow.toastOrnament)
            self[property] = newValue
        }
    }
    
    func ornamentEmbeddedPresentation(
        of toast: ToastPresentation,
        in toastOrnament: ToastOrnament
    ) -> (adaptedToast: ToastPresentation, contentView: UIView)? {
        
        guard let rootViewController else {
            return nil
        }
        
        let toastHostingOrnament = toastHostingOrnament()
        toastHostingOrnament.toastOrnament = toastOrnament
        toastHostingOrnament.size = intrinsicContentSize(
            of: toast,
            boundIn: rootViewController.view.frame.size
        )
        toastHostingOrnament.hostingOrnament.sceneAnchor = makeSceneAnchor(
            for: toast
        )
        
        rootViewController.ornaments.append(toastHostingOrnament.hostingOrnament)
        let adaptedToast = toast.onDismiss { [weak rootViewController] in
            rootViewController?.ornaments
                .removeAll(where: { $0 === toastHostingOrnament.hostingOrnament })
        }
        
        return (adaptedToast: adaptedToast, contentView: toastHostingOrnament.contentView)
    }
    
    private func toastHostingOrnament() -> UIToastHostingOrnament {
        if let toastOrnament = toastOrnament {
            return toastOrnament
        } else {
            let toastOrnament = UIToastHostingOrnament(
                toastOrnament: ToastOrnament(
                    contentAlignment: .center
                )
            )
            
            self.toastOrnament = toastOrnament
            return toastOrnament
        }
    }
    
    private func intrinsicContentSize(
        of toast: ToastPresentation,
        boundIn size: CGSize
    ) -> CGSize {
        let hostContainer = UIView(
            frame: CGRect(
                origin: .zero,
                size: size
            )
        )
        
        let host = UIHostingController(
            rootView: HostedToastContent(
                id: ObjectIdentifier(hostContainer),
                hosting: toast,
                dismissAction: {}
            )
            .frame(maxWidth: size.width, maxHeight: size.height)
            .fixedSize()
        )
        
        host.view.translatesAutoresizingMaskIntoConstraints = false
        hostContainer.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(
                greaterThanOrEqualTo: hostContainer.leadingAnchor
            ),
            host.view.topAnchor.constraint(
                greaterThanOrEqualTo: hostContainer.topAnchor
            ),
            hostContainer.trailingAnchor.constraint(
                greaterThanOrEqualTo: hostContainer.trailingAnchor
            ),
            host.view.bottomAnchor.constraint(
                greaterThanOrEqualTo: hostContainer.bottomAnchor
            )
        ])
        
        host.view.invalidateIntrinsicContentSize()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        return host.view.frame.size
    }
    
    private func makeSceneAnchor(
        for toast: ToastPresentation
    ) -> UnitPoint {
        let alignedEdges = toast.toastAlignment.rawValue
        
        if alignedEdges.isEmpty || alignedEdges.contains(.all) {
            return .center
        }
        
        var unitX: CGFloat = 0.5
        var unitY: CGFloat = 0.5
        
        if alignedEdges.contains(.leading) {
            unitX = 0
        } else if alignedEdges.contains(.trailing) {
            unitX = 1
        }
        
        if alignedEdges.contains(.top) {
            unitY = 0
        } else if alignedEdges.contains(.bottom) {
            unitY = 1
        }
        
        return UnitPoint(x: unitX, y: unitY)
    }
}

#endif
