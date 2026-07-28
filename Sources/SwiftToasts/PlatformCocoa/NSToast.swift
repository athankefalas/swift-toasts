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

// A Toast component used to present transient messages to the user.
@MainActor
public class NSToast: NSObject {
    
    /// The type of content mode a toast is inferred to have.
    public enum InferredContentMode {
        case empty
        case standardContent
        case customContent
    }
    
    public struct Configuration {
        /// The style of the toast.
        public var style: any ToastStyle
        /// The alignment of the toast.
        public var alignment: ToastAlignment
        /// The transition that will be used for the toast presentation.
        public var transition: ToastTransition
        /// A flag that controls whether the toast can be interactively dismissed.
        public var interactiveDismissEnabled: Bool
        /// A flag that controls whether the content behind a presented toast can be interacted with during a toast presentation.
        public var backgroundInteractionEnabled: Bool
        /// The accessibility options used for the toast content.
        public var accessibilityOptions: ToastAccessibilityOptions
        
        
        /// The role of a toast.
        public var role: ToastRole
        /// The duration of a toast.
        public var duration: ToastDuration
        /// The icon of a toast.
        public var icon: NSImage?
        /// The title of a toast.
        public var title: String?
        /// The value subtitle of a toast.
        public var valueSubtitle: String?
        
        
        /// The custom content view of a toast.
        public var contentView: NSView?
        /// The background view of a toast.
        public var backgroundView: NSView?
        
        /// Create a new toast content configuration using a standard content mode.
        /// - Parameters:
        ///   - icon: The icon of a toast.
        ///   - title: The title of a toast.
        ///   - valueSubtitle: The value subtitle of a toast.
        ///   - role: The role of a toast.
        ///   - duration: The duration of a toast.
        public init(
            icon: NSImage?,
            title: String,
            valueSubtitle: String?,
            role: ToastRole,
            duration: ToastDuration
        ) {
            // Options
            self.style = .automatic
            self.alignment = .defaultAlignment
            self.transition = .defaultTransition
            self.interactiveDismissEnabled = true
            self.backgroundInteractionEnabled = true
            self.accessibilityOptions = .hidden
            
            // Attributes
            self.role = role
            self.duration = duration
            
            // Content
            self.icon = icon
            self.title = title
            self.valueSubtitle = valueSubtitle
        }
        
        /// Create a new toast content configuration using a custom content mode.
        /// - Parameters:
        ///   - contentView: The custom content view of a toast.
        ///   - backgroundView: The background view of a toast.
        ///   - role: The role of a toast.
        ///   - duration: The duration of a toast.
        public init(
            contentView: NSView,
            backgroundView: NSView?,
            role: ToastRole,
            duration: ToastDuration
        ) {
            // Options
            self.style = .automatic
            self.alignment = .defaultAlignment
            self.transition = .defaultTransition
            self.interactiveDismissEnabled = true
            self.backgroundInteractionEnabled = true
            self.accessibilityOptions = .hidden
            
            // Attributes
            self.role = role
            self.duration = duration
            
            // Content
            self.contentView = contentView
            self.backgroundView = backgroundView
        }
    }
    
    /// The configuration of a  `Toast` that controls it's content, behavior and appearance.
    public var configuration: Configuration
    
    /// The role of a `Toast`.
    public var role: ToastRole {
        get {
            configuration.role
        }
        
        set {
            configuration.role = newValue
        }
    }
    
    /// The duration of a `Toast`.
    public var duration: ToastDuration {
        get {
            configuration.duration
        }
        
        set {
            configuration.duration = newValue
        }
    }
    
    /// The icon of a `Toast` using the standard content mode.
    /// - Note: Setting this property with a non-nil value
    /// will clear any custom content mode properties set.
    public var icon: NSImage? {
        get {
            configuration.icon
        }
        
        set {
            if newValue != nil {
                configuration.contentView = nil
            }
            
            configuration.icon = newValue
        }
    }
    
    /// The title of a `Toast` using the standard content mode.
    /// - Note: Setting this property with a non-nil value
    /// will clear any custom content mode properties set.
    public var title: String? {
        get {
            configuration.title
        }
        
        set {
            if newValue != nil {
                configuration.contentView = nil
            }
            
            configuration.title = newValue
        }
    }
    
    /// The value subtitle of a `Toast` using the standard content mode.
    /// - Note: Setting this property with a non-nil value
    /// will clear any custom content mode properties set.
    public var valueSubtitle: String? {
        get {
            configuration.valueSubtitle
        }
        
        set {
            if newValue != nil {
                configuration.contentView = nil
            }
            
            configuration.valueSubtitle = newValue
        }
    }
    
    /// The content view of a `Toast` using the custom content mode.
    /// - Note: Setting this property with a non-nil value
    /// will clear any standard content mode properties such as icon, title and subtitles set.
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
    
    /// The background view of a `Toast`.
    public var backgroundView: NSView? {
        get {
            configuration.backgroundView
        }
        
        set {
            configuration.backgroundView = newValue
        }
    }
    
    /// The content mode the toast is inferred to have based on the current content configuration.
    public var inferredContentMode: InferredContentMode {
        if configuration.contentView != nil {
            return .customContent
        }
        
        if configuration.title != nil {
            return .standardContent
        }
        
        return .empty
    }
    
    /// A flag that indicates whether this `Toast` is currently presented.
    public internal(set) var isPresented: Bool = false
    /// A flag that indicates whether the scheduled presentation of this `Toast`
    /// will be automatically cancelled when this instance will be deallocated.
    public var cancellationTracksLifetime: Bool = false
    internal var scheduledPresentationCanceller: AnyCancellable? = nil
    internal var presentationCanceller: ToastPresentationCanceller = ToastPresentationCanceller()
    
    /// A flag that indicates if this `Toast` is scheduled for presentation.
    public var isScheduledForPresentation: Bool {
        scheduledPresentationCanceller != nil
    }
    
    /// Creates a new `UIToast` with the given content configuration.
    /// - Parameter configuration: The content configuration to use.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /// Create a new `UIToast` with the standard content mode.
    /// - Parameters:
    ///   - icon: An optional icon for the toast.
    ///   - title: The title to use for the toast.
    ///   - valueSubtitle: An optional value subtitle to use.
    ///   - role: The role of the toast.
    ///   - duration: The duration of the toast presentation.
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
    
    /// Create a new `UIToast` with a custom content mode.
    /// - Parameters:
    ///   - contentView: A custom content view to use for the toast.
    ///   - backgroundView: An optional custom background view to use for the toast.
    ///   - role: The role of the toast.
    ///   - duration: The duration of the toast presentation.
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
    
    /// Schedule the given toast for presentation.
    /// - Parameters:
    ///   - toast: The toast to schedule for presentation.
    ///   - onPresent: A callback invoked when the toast is presented.
    ///   - onDismiss: A callback invoked when the toast is dismissed.
    public func schedulePresentation(
        in window: NSWindow,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        let presenter = ToastPresenterProxy(toastPresenter: window)
        guard presenter.isPresentationEnabled else {
            return
        }
                
        var toastStyle: AnyToastStyle = configuration.style.erased()
        if let backgroundView = configuration.backgroundView {
            toastStyle = AppKitBridgedToastStyle(
                inheritedStyle: toastStyle,
                hasCustomContent: configuration.contentView != nil,
                backgroundView: backgroundView
            ).erased()
        }
        
        let toastKey = ObjectIdentifier(self)
        let presentation = ToastPresentation(
            toast: Toast(contentConfiguration: configuration),
            toastAlignment: configuration.alignment,
            toastEnvironmentValues: ToastEnvironmentValues(
                toastStyle: toastStyle,
                toastTransition: configuration.transition,
                toastInteractiveDismissEnabled: configuration.interactiveDismissEnabled,
                toastBackgroundInteractionEnabled: configuration.backgroundInteractionEnabled,
                toastAccessibilityOptions: configuration.accessibilityOptions
            ),
            presentationCanceller: presentationCanceller,
            onPresent: { [weak self] in
                Task { @MainActor in
                    self?.isPresented = true
                    self?.scheduledPresentationCanceller = nil
                    GlobalToastCancellationTokenStorage.shared.remove(forKey: toastKey)
                    onPresent?()
                }
            },
            onDismiss: { [weak self] in
                self?.isPresented = false
                onDismiss?()
                self?._resetPresentationState()
            }
        )
        
        if self.cancellationTracksLifetime {
            self.scheduledPresentationCanceller = presenter.scheduleCancellable(
                presentation: presentation
            )
        } else {
            let cancellable = presenter.scheduleCancellable(
                presentation: presentation
            )
            
            GlobalToastCancellationTokenStorage.shared.store(
                cancellable: cancellable,
                forKey: toastKey
            )
            
            self.scheduledPresentationCanceller = AnyCancellable({})
        }
    }
    
    /// Cancel the scheduled presentation of this toast while it is still pending.
    public func cancelScheduledPresentation() {
        scheduledPresentationCanceller?.cancel()
        scheduledPresentationCanceller = nil
        
        let key = ObjectIdentifier(self)
        let canceller = GlobalToastCancellationTokenStorage.shared
            .storedCancellable(forKey: key)
        
        guard let externallyStoredCanceller = canceller else {
            return
        }
        
        externallyStoredCanceller.cancel()
        GlobalToastCancellationTokenStorage.shared.remove(forKey: key)
    }
    
    /// Dismiss this toast of it is currently presented.
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

// MARK: NSToast.Configuration + common

public extension NSToast.Configuration {
    
    static func plain() -> Self {
        var configuration = NSToast.Configuration(
            icon: nil,
            title: "",
            valueSubtitle: nil,
            role: .plain,
            duration: .short
        )
        
        configuration.title = nil
        return configuration
    }
    
    static func informational() -> Self {
        var configuration = NSToast.Configuration(
            icon: nil,
            title: "",
            valueSubtitle: nil,
            role: .informational,
            duration: .short
        )
        
        configuration.title = nil
        return configuration
    }
    
    static func success() -> Self {
        var configuration = NSToast.Configuration(
            icon: nil,
            title: "",
            valueSubtitle: nil,
            role: .success,
            duration: .short
        )
        
        configuration.title = nil
        return configuration
    }
    
    static func warning() -> Self {
        var configuration = NSToast.Configuration(
            icon: nil,
            title: "",
            valueSubtitle: nil,
            role: .warning,
            duration: .long
        )
        
        configuration.title = nil
        return configuration
    }
    
    static func failure() -> Self {
        var configuration = NSToast.Configuration(
            icon: nil,
            title: "",
            valueSubtitle: nil,
            role: .failure,
            duration: .long
        )
        
        configuration.title = nil
        return configuration
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
