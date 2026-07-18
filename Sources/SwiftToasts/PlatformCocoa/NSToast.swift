//
//  NSToast.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

#if canImport(Cocoa) && canImport(SwiftUI)

import AppKit
import SwiftUI
import Combine

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
        public var toastBackgroundInteractionEnabled: Bool
        public var toastAccessibilityOptions: ToastAccessibilityOptions
        
        public var role: ToastRole
        public var duration: ToastDuration
        public var icon: NSImage?
        public var title: String?
        public var valueSubtitle: String?
        
        public var contentView: NSView?
        public var backgroundView: NSView?
        
        public init(
            icon: NSImage?,
            title: String,
            valueSubtitle: String?,
            role: ToastRole,
            duration: ToastDuration
        ) {
            // Options
            self.toastStyle = .automatic
            self.toastAlignment = .defaultAlignment
            self.toastTransition = .defaultTransition
            self.toastInteractiveDismissEnabled = true
            self.toastBackgroundInteractionEnabled = true
            self.toastAccessibilityOptions = .hidden
            
            // Attributes
            self.role = role
            self.duration = duration
            
            // Content
            self.icon = icon
            self.title = title
            self.valueSubtitle = valueSubtitle
        }
        
        public init(
            contentView: NSView,
            backgroundView: NSView?,
            role: ToastRole,
            duration: ToastDuration
        ) {
            // Options
            self.toastStyle = .automatic
            self.toastAlignment = .defaultAlignment
            self.toastTransition = .defaultTransition
            self.toastInteractiveDismissEnabled = true
            self.toastBackgroundInteractionEnabled = true
            self.toastAccessibilityOptions = .hidden
            
            // Attributes
            self.role = role
            self.duration = duration
            
            // Content
            self.contentView = contentView
            self.backgroundView = backgroundView
        }
    }
    
    public var configuration: Configuration
    
    public var role: ToastRole {
        get {
            configuration.role
        }
        
        set {
            configuration.role = newValue
        }
    }
    
    public var duration: ToastDuration {
        get {
            configuration.duration
        }
        
        set {
            configuration.duration = newValue
        }
    }
    
    public var icon: NSImage? {
        get {
            configuration.icon
        }
        
        set {
            configuration.contentView = nil
            configuration.icon = newValue
        }
    }
    
    public var title: String? {
        get {
            configuration.title
        }
        
        set {
            configuration.contentView = nil
            configuration.title = newValue
        }
    }
    
    public var valueSubtitle: String? {
        get {
            configuration.valueSubtitle
        }
        
        set {
            configuration.contentView = nil
            configuration.valueSubtitle = newValue
        }
    }
    
    public var contentView: NSView? {
        get {
            configuration.contentView
        }
        
        set {
            if newValue != nil {
                configuration.icon = nil
                configuration.title = nil
                configuration.valueSubtitle = nil
            }
            
            configuration.contentView = newValue
        }
    }
    
    public var backgroundView: NSView? {
        get {
            configuration.backgroundView
        }
        
        set {
            configuration.backgroundView = newValue
        }
    }
    
    public var inferredContentType: InferredContentType {
        if configuration.contentView != nil {
            return .customContent
        }
        
        if configuration.title != nil {
            return .standardContent
        }
        
        return .invalid
    }
    
    public internal(set) var isPresented: Bool = false
    internal var scheduledPresentationCanceller: AnyCancellable? = nil
    internal var presentationCanceller: ToastPresentationCanceller = ToastPresentationCanceller()
    
    public var canBePresented: Bool {
        inferredContentType != .invalid
    }
    
    public var isScheduledForPresentation: Bool {
        scheduledPresentationCanceller != nil
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public init(
        icon: NSImage? = nil,
        title: String,
        valueSubtitle: String? = nil,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.configuration = Configuration(
            icon: icon,
            title: title,
            valueSubtitle: valueSubtitle,
            role: role,
            duration: duration
        )
    }
    
    public init(
        contentView: NSView,
        backgroundView: NSView? = nil,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.configuration = Configuration(
            contentView: contentView,
            backgroundView: backgroundView,
            role: role,
            duration: duration
        )
    }
    
    internal func _resetPresentationState() {
        isPresented = false
        scheduledPresentationCanceller = nil
        presentationCanceller = ToastPresentationCanceller()
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
                
        var toastStyle: AnyToastStyle = configuration.toastStyle.erased()
        if let backgroundView = configuration.backgroundView {
            toastStyle = AppKitBridgedToastStyle(
                inheritedStyle: toastStyle,
                hasCustomContent: configuration.contentView != nil,
                backgroundView: backgroundView
            ).erased()
        }
        
        scheduledPresentationCanceller = presenter.scheduleCancellable(
            presentation: ToastPresentation(
                toast: Toast(contentConfiguration: configuration),
                toastAlignment: configuration.toastAlignment,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastStyle: toastStyle,
                    toastTransition: configuration.toastTransition,
                    toastInteractiveDismissEnabled: configuration.toastInteractiveDismissEnabled,
                    toastBackgroundInteractionEnabled: configuration.toastBackgroundInteractionEnabled,
                    toastAccessibilityOptions: configuration.toastAccessibilityOptions
                ),
                presentationCanceller: presentationCanceller,
                onPresent: { [weak self] in
                    self?.isPresented = true
                    onPresent?()
                },
                onDismiss: { [weak self] in
                    self?.isPresented = false
                    onDismiss?()
                    self?._resetPresentationState()
                }
            )
        )
    }
    
    public func cancelScheduledPresentation() {
        scheduledPresentationCanceller?.cancel()
        scheduledPresentationCanceller = nil
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
    let hasCustomContent: Bool
    let backgroundView: NSView
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            insetContent: !hasCustomContent,
            cornerRadius: 0,
            configuration: configuration
        ) { props in
            AppKitBridgedView(backgroundView)
        }
    }
}

// MARK: Toast + NSToast.ContentConfiguration

extension Toast {
    
    init(contentConfiguration configuration: NSToast.Configuration) {
        if let contentView = configuration.contentView {
            self = .init(
                role: configuration.role,
                duration: configuration.duration
            ) {
                AppKitBridgedView(contentView)
            }
        } else if let title = configuration.title {
            self = .init(
                icon: configuration.icon.flatMap({ Image(nsImage: $0) }),
                title: Text(title),
                valueSubtitle: configuration.valueSubtitle.flatMap({ Text($0) }),
                role: configuration.role,
                duration: configuration.duration
            )
        } else {
            self = .init("", role: configuration.role, duration: configuration.duration)
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
        toast.configuration.icon = NSImage(
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
        toast.configuration.valueSubtitle = "Subtitle"
        
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
        toast.configuration.valueSubtitle = "Subtitle"
        toast.configuration.icon = NSImage(
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
        toast.configuration.backgroundView = backgroundView
        
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
#Preview(traits: .fixedLayout(width: 360, height: 580)) {
    NSPreviewViewController()
}

#endif

#endif
