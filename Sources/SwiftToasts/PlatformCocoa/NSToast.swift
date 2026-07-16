//
//  NSToast.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

#if canImport(Cocoa) && canImport(SwiftUI)

import AppKit
import SwiftUI

@MainActor
public class NSToast: NSObject {
    
    public enum InferredContentType {
        case invalid
        case standardContent
        case customContent
    }
    
    public struct Configuration {
        public var toastStyle: any ToastStyle
        public var toastAlignment: ToastAlignment
        public var toastTransition: ToastTransition
        public var toastInteractiveDismissEnabled: Bool
        public var toastAccessibilityOptions: ToastAccessibilityOptions
        
        public init(
            toastStyle: any ToastStyle = .automatic,
            toastAlignment: ToastAlignment = .defaultAlignment,
            toastTransition: ToastTransition = .defaultTransition,
            toastInteractiveDismissEnabled: Bool = true,
            toastAccessibilityOptions: ToastAccessibilityOptions = .hidden
        ) {
            self.toastStyle = toastStyle
            self.toastAlignment = toastAlignment
            self.toastTransition = toastTransition
            self.toastInteractiveDismissEnabled = toastInteractiveDismissEnabled
            self.toastAccessibilityOptions = toastAccessibilityOptions
        }
    }
    
    public struct ContentConfiguration {
        public var icon: NSImage?
        public var title: String?
        public var valueSubtitle: String?
        
        public var contentView: NSView?
        public var backgroundView: NSView?
        
        public init(
            icon: NSImage? = nil,
            title: String,
            valueSubtitle: String? = nil
        ) {
            self.icon = icon
            self.title = title
            self.valueSubtitle = valueSubtitle
        }
        
        public init(
            contentView: NSView,
            backgroundView: NSView? = nil
        ) {
            self.contentView = contentView
            self.backgroundView = backgroundView
        }
    }
    
    public var role: ToastRole = .defaultRole
    public var duration: ToastDuration = .defaultDuration
    public var configuration: Configuration
    public var contentConfiguration: ContentConfiguration
    
    public fileprivate(set) var isPresented: Bool = false
    fileprivate var presentationCanceller: ToastPresentationCanceller
    
    public var inferredContentType: InferredContentType {
        if contentConfiguration.contentView != nil {
            return .customContent
        }
        
        if contentConfiguration.title != nil {
            return .standardContent
        }
        
        return .invalid
    }
    
    public var canBePresented: Bool {
        inferredContentType != .invalid
    }
    
    public init(
        configuration: Configuration,
        contentConfiguration: ContentConfiguration
    ) {
        self.configuration = configuration
        self.contentConfiguration = contentConfiguration
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
    public init(
        icon: NSImage? = nil,
        title: String,
        valueSubtitle: String? = nil
    ) {
        self.configuration = Configuration()
        self.contentConfiguration = ContentConfiguration(
            icon: icon,
            title: title,
            valueSubtitle: valueSubtitle
        )
        
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
    public init(
        contentView: NSView,
        backgroundView: NSView? = nil
    ) {
        self.configuration = Configuration()
        self.contentConfiguration = ContentConfiguration(
            contentView: contentView,
            backgroundView: backgroundView
        )
        
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
    public func schedulePresentation(
        in window: NSWindow,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        let presenter = ToastPresenterProxy(toastPresenter: window)
        guard presenter.isPresentationEnabled else {
            return
        }
        
        let toast = self
        var toastStyle: AnyToastStyle = toast.configuration.toastStyle.erased()
        if let backgroundView = toast.contentConfiguration.backgroundView {
            toastStyle = AppKitBridgedToastStyle(
                inheritedStyle: toastStyle,
                backgroundView: backgroundView
            ).erased()
        }
        
        presenter.schedule(
            presentation: ToastPresentation(
                toast: Toast(
                    role: toast.role,
                    duration: toast.duration,
                    contentConfiguration: toast.contentConfiguration
                ),
                toastAlignment: toast.configuration.toastAlignment,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastStyle: toastStyle,
                    toastTransition: toast.configuration.toastTransition,
                    toastInteractiveDismissEnabled: toast.configuration.toastInteractiveDismissEnabled,
                    toastAccessibilityOptions: toast.configuration.toastAccessibilityOptions
                ),
                presentationCanceller: toast.presentationCanceller,
                onPresent: { [weak toast] in
                    toast?.isPresented = true
                    onPresent?()
                },
                onDismiss: { [weak toast] in
                    toast?.isPresented = false
                    onDismiss?()
                }
            )
        )
    }
    
    public func dismiss() {
        presentationCanceller.dismissPresentation()
    }
}

// MARK: NSToast + SwiftUI Bridging

struct AppKitBridgedView: NSViewRepresentable {
    let bridgedView: NSView
    
    init(_ bridgedView: NSView) {
        self.bridgedView = bridgedView
    }
    
    func makeNSView(context: Context) -> NSView {
        bridgedView
    }
    
    func updateNSView(_ uiView: NSView, context: Context) {}
}

struct AppKitBridgedToastStyle: ToastStyle {
    let inheritedStyle: AnyToastStyle
    let backgroundView: NSView
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            cornerRadius: 0,
            configuration: configuration
        ) { props in
            AppKitBridgedView(backgroundView)
        }
    }
}

// MARK: Toast + NSToast.ContentConfiguration

extension Toast {
    
    init(
        role: ToastRole,
        duration: ToastDuration,
        contentConfiguration: NSToast.ContentConfiguration
    ) {
        if let contentView = contentConfiguration.contentView {
            self = .init(
                role: role,
                duration: duration
            ) {
                AppKitBridgedView(contentView)
            }
        } else if let title = contentConfiguration.title {
            self = .init(
                icon: contentConfiguration.icon.flatMap({ Image(nsImage: $0) }),
                title: Text(title),
                valueSubtitle: contentConfiguration.valueSubtitle.flatMap({ Text($0) }),
                role: role,
                duration: duration
            )
        } else {
            self = .init("", role: role, duration: duration)
        }
    }
}

// MARK: Previews

#if ENABLE_PREVIEWS

@available(macOS 11.0, *)
class NSPreviewViewController: NSViewController {
    
    enum ToastType: String, CaseIterable {
        case title
        case titleAndIcon
        case titleAndSubtitle
        case titleAndSubtitleAndIcon
        case customContentView
        case customContentViewWithCustomBackground
    }
    
    private var selection: ToastType = .title
    
    override func loadView() {
        super.loadView()
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 16
        
        let popUp = NSPopUpButton(
            title: "Toast Type",
            target: self,
            action: #selector(popUpAction)
        )
        
        let menu = NSMenu()
        for type in ToastType.allCases {
            let item = NSMenuItem(
                title: type.rawValue,
                action: nil,
                keyEquivalent: ""
            )
            
            item.identifier = NSUserInterfaceItemIdentifier(type.rawValue)
            menu.addItem(item)
        }
        
        popUp.menu = menu
        stackView.addArrangedSubview(popUp)
        
        let button = NSButton(
            title: "Hit Me!",
            target: self,
            action: #selector(buttonAction)
        )
        
        stackView.addArrangedSubview(button)
        view = stackView
    }
    
    @objc func popUpAction(_ sender: NSPopUpButton?) {
        guard let selectionId = sender?.selectedItem?.identifier,
              let selection = ToastType.allCases
            .first(where: { $0.rawValue == selectionId.rawValue }) else {
            return
        }
        
        self.selection = selection
    }
    
    @objc func buttonAction(_ sender: NSButton?) {
        switch selection {
        case .title:
            showToastWithTitle()
        case .titleAndIcon:
            showToastWithTitleAndIcon()
        case .titleAndSubtitle:
            showToastWithTitleAndSubtitle()
        case .titleAndSubtitleAndIcon:
            showToastWithTitleAndSubtitleAndIcon()
        case .customContentView:
            showToastWithCustomView()
        case .customContentViewWithCustomBackground:
            showToastWithCustomViewAndBackground()
        }
    }
    
    private var window: NSWindow {
        view.window ?? NSWindow()
    }
    
    private func showToastWithTitle() {
        let toast = NSToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleAndIcon() {
        let toast = NSToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        toast.contentConfiguration.icon = NSImage(
            systemSymbolName: "star.fill",
            accessibilityDescription: nil
        )
        
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleAndSubtitle() {
        let toast = NSToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        toast.contentConfiguration.valueSubtitle = "Subtitle"
        
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleAndSubtitleAndIcon() {
        let toast = NSToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        toast.contentConfiguration.valueSubtitle = "Subtitle"
        toast.contentConfiguration.icon = NSImage(
            systemSymbolName: "star.fill",
            accessibilityDescription: nil
        )
        
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithCustomView() {
        let label = NSTextField(
            labelWithString: "Hello, Custom World!"
        )
        
        let toast = NSToast(contentView: label)
        toast.role = .informational
        toast.duration = .indefinite
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithCustomViewAndBackground() {
        let label = NSTextField(
            labelWithString: "Hello, Custom World!"
        )
        
        let toast = NSToast(contentView: label)
        toast.role = .informational
        toast.duration = .indefinite
        
        let backgroundView = NSVisualEffectView()
        backgroundView.material = .hudWindow
        backgroundView.state = .active
        toast.contentConfiguration.backgroundView = backgroundView
        
        toast.schedulePresentation(in: window) {
            print("NSToast Shown")
        } onDismiss: {
            print("NSToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
}

@available(macOS 14.0, *)
#Preview {
    NSPreviewViewController()
}

#endif

#endif
