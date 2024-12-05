//
//  UIToastHostingOrnament.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 4/12/24.
//

#if canImport(UIKit) && os(visionOS)
import UIKit
import SwiftUI

@MainActor
class UIToastHostingOrnament: NSObject {
    
    class UIToastContentView: UIView {
        private var _intrinsicContentSize: CGSize?
        
        override var intrinsicContentSize: CGSize {
            get {
                _intrinsicContentSize ?? super.intrinsicContentSize
            }
            
            set {
                _intrinsicContentSize = newValue
            }
        }
        
        func clearIntrinsicContentSize() {
            _intrinsicContentSize = nil
        }
    }
    
    private struct OrnamentHostedToastRoot: UIViewRepresentable {
        let contentView: UIToastContentView
        
        func makeUIView(
            context: Context
        ) -> UIToastContentView {
            contentView
        }
        
        func updateUIView(
            _ uiView: UIToastContentView,
            context: Context
        ) {}
        
        func sizeThatFits(
            _ proposal: ProposedViewSize,
            uiView: UIToastContentView,
            context: Context
        ) -> CGSize? {
            contentView.setNeedsLayout()
            contentView.invalidateIntrinsicContentSize()
            contentView.layoutIfNeeded()
            
            var intrinsicContentSize = contentView.intrinsicContentSize
            intrinsicContentSize.width = max(intrinsicContentSize.width, 10)
            intrinsicContentSize.height = max(intrinsicContentSize.height, 10)
            
            return proposal.replacingUnspecifiedDimensions(
                by: intrinsicContentSize
            )
        }
    }
    
    let contentView: UIToastContentView
    let hostingOrnament: UIHostingOrnament<AnyView>
    
    var size: CGSize? {
        didSet {
            guard let size else {
                return contentView.clearIntrinsicContentSize()
            }
            
            contentView.intrinsicContentSize = size
        }
    }
    
    var toastOrnament: ToastOrnament {
        didSet {
            hostingOrnament.contentAlignment = toastOrnament.contentAlignment
        }
    }
    
    init(
        toastOrnament: ToastOrnament
    ) {
        let contentView = UIToastContentView()
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = true
        contentView.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.contentView = contentView
        self.toastOrnament = toastOrnament
        self.hostingOrnament = UIHostingOrnament(
            sceneAnchor: .center,
            contentAlignment: toastOrnament.contentAlignment,
            content: { AnyView(Color.clear) }
        )
        
        super.init()
        updateOrnamentContentView()
    }
    
    private func updateOrnamentContentView() {
        self.hostingOrnament.rootView = AnyView(
            OrnamentHostedToastRoot(contentView: contentView)
                .environment(\.toastOrnamentPresentationEnabled, true)
        )
    }
}
#endif
