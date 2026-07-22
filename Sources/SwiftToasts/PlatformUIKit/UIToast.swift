//
//  UIToast.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)

import UIKit
import SwiftUI
import Combine

// A Toast component used to present transient messages to the user.
@MainActor
public class UIToast: NSObject {
    
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
        public var icon: UIImage?
        /// The title of a toast.
        public var title: String?
        /// The value subtitle of a toast.
        public var valueSubtitle: String?
        
        
        /// The custom content view of a toast.
        public var contentView: UIView?
        /// The background view of a toast.
        public var backgroundView: UIView?
        
        /// Create a new toast content configuration using a standard content mode.
        /// - Parameters:
        ///   - icon: The icon of a toast.
        ///   - title: The title of a toast.
        ///   - valueSubtitle: The value subtitle of a toast.
        ///   - role: The role of a toast.
        ///   - duration: The duration of a toast.
        public init(
            icon: UIImage?,
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
            contentView: UIView,
            backgroundView: UIView?,
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
    public var icon: UIImage? {
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
    public var contentView: UIView? {
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
    public var backgroundView: UIView? {
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
        icon: UIImage? = nil,
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
        contentView: UIView,
        backgroundView: UIView? = nil,
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

// MARK: UIToast + SwiftUI Bridging

struct UIKitBridgedView: UIViewRepresentable {
    let bridgedView: UIView
    
    init(_ bridgedView: UIView) {
        self.bridgedView = bridgedView
    }
    
    func makeUIView(context: Context) -> UIView {
        bridgedView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct UIKitBridgedToastStyle: ToastStyle {
    let inheritedStyle: AnyToastStyle
    let hasCustomContent: Bool
    let backgroundView: UIView
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            insetContent: !hasCustomContent,
            cornerRadius: 0,
            configuration: configuration
        ) { props in
            UIKitBridgedView(backgroundView)
        }
    }
}

// MARK: Toast Presentation + UIViewController

public extension UIViewController {
    private var targetPresenter: ToastPresenterProxy? {
        ToastPresenterProxy(toastPresenter: _getDefaultToastPresenter())
    }
    
    /// Schedule the given toast for presentation.
    /// - Parameters:
    ///   - toast: The toast to schedule for presentation.
    ///   - onPresent: A callback invoked when the toast is presented.
    ///   - onDismiss: A callback invoked when the toast is dismissed.
    func schedulePresentation(
        of toast: UIToast,
        onPresent: (@MainActor () -> Void)? = nil,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        guard let presenter = targetPresenter,
              presenter.isPresentationEnabled else {
            return
        }
        
        let configuration = toast.configuration
        var toastStyle: AnyToastStyle = configuration.style.erased()
        if let backgroundView = configuration.backgroundView {
            toastStyle = UIKitBridgedToastStyle(
                inheritedStyle: toastStyle,
                hasCustomContent: configuration.contentView != nil,
                backgroundView: backgroundView
            ).erased()
        }
        
        let toastKey = ObjectIdentifier(self)
        let presentation = ToastPresentation(
            toast: Toast(contentConfiguration: configuration),
            toastAlignment: toast.configuration.alignment,
            toastEnvironmentValues: ToastEnvironmentValues(
                toastStyle: toastStyle,
                toastTransition: toast.configuration.transition,
                toastInteractiveDismissEnabled: toast.configuration.interactiveDismissEnabled,
                toastBackgroundInteractionEnabled: toast.configuration.backgroundInteractionEnabled,
                toastAccessibilityOptions: toast.configuration.accessibilityOptions
            ),
            presentationCanceller: toast.presentationCanceller,
            onPresent: { [weak toast] in
                Task { @MainActor in
                    toast?.isPresented = true
                    toast?.scheduledPresentationCanceller = nil
                    GlobalToastCancellationTokenStorage.shared.remove(forKey: toastKey)
                    onPresent?()
                }
            },
            onDismiss: { [weak toast] in
                toast?.isPresented = false
                onDismiss?()
                toast?._resetPresentationState()
            }
        )
        
        if toast.cancellationTracksLifetime {
            toast.scheduledPresentationCanceller = presenter.scheduleCancellable(
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
            
            toast.scheduledPresentationCanceller = AnyCancellable({})
        }
    }
}

// MARK: Toast + UIToast.ContentConfiguration

extension Toast {
    
    init(contentConfiguration configuration: UIToast.Configuration) {
        if let contentView = configuration.contentView {
            self = .init(
                role: configuration.role,
                duration: configuration.duration
            ) {
                UIKitBridgedView(contentView)
            }
        } else if let title = configuration.title {
            self = .init(
                icon: configuration.icon.flatMap({ Image(uiImage: $0) }),
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

// MARK: UIToast.Configuration + common

public extension UIToast.Configuration {
    
    static func plain() -> Self {
        var configuration = UIToast.Configuration(
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
        var configuration = UIToast.Configuration(
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
        var configuration = UIToast.Configuration(
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
        var configuration = UIToast.Configuration(
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
        var configuration = UIToast.Configuration(
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

class UIPreviewViewController: UIViewController,
                               UIPickerViewDelegate,
                               UIPickerViewDataSource,
                               UITextFieldDelegate {
    
    enum ToastType: String, CaseIterable {
        case title
        case titleAndIcon
        case titleAndSubtitle
        case titleAndSubtitleAndIcon
        case customContentView
        case customContentViewWithCustomBackground
    }
    
    private var selection: ToastType = .title {
        didSet {
            guard viewIfLoaded != nil,
                  let stackView = view.subviews.first as? UIStackView,
                  let textField = stackView.arrangedSubviews.first as? UITextField else {
                return
            }
            
            textField.text = selection.rawValue
        }
    }
    
    override func loadView() {
        super.loadView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 16
        
        let textField = UITextField()
        textField.text = selection.rawValue
        textField.borderStyle = .roundedRect
        textField.allowsEditingTextAttributes = false
        textField.rightViewMode = .unlessEditing
        textField.rightView = UIImageView(
            image: UIImage(
                systemName: "chevron.up.chevron.down"
            )
        )
        
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        textField.inputView = picker
        
        let toolBar = UIToolbar()
        var doenButtonStyle: UIBarButtonItem.Style = .done
        if #available(iOS 26.0, *) {
            doenButtonStyle = .prominent
        }
        
        toolBar.setItems(
            [
                UIBarButtonItem(
                    title: "Done",
                    style: doenButtonStyle,
                    target: self,
                    action: #selector(self.tapAction)
                ),
                UIBarButtonItem(
                    barButtonSystemItem: .flexibleSpace,
                    target: nil,
                    action: nil
                ),
                UIBarButtonItem(
                    image: UIImage(systemName: "chevron.up"),
                    style: .plain,
                    target: self,
                    action: #selector(selectPreviousButtonAction)
                ),
                UIBarButtonItem(
                    image: UIImage(systemName: "chevron.down"),
                    style: .plain,
                    target: self,
                    action: #selector(selectNextButtonAction)
                )
            ],
            animated: true
        )
        
        toolBar.sizeToFit()
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        let showToastButton = UIButton(
            type: .system
        )
        
        showToastButton.setTitle("Show Toast", for: .normal)
        showToastButton.addTarget(self, action: #selector(showToastButtonAction), for: .touchUpInside)
        stackView.addArrangedSubview(showToastButton)
        
        let height = textField.intrinsicContentSize.height + showToastButton.intrinsicContentSize.height
        stackView.frame = CGRect(
            origin: CGPoint(
                x: 16,
                y: view.frame.midY - height * 0.5
            ),
            size: CGSize(
                width: view.frame.width - (16 * 2),
                height: height
            )
        )
        
        view.addSubview(stackView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapAction(_ sender: UITapGestureRecognizer?) {
        guard let stackView = view.subviews.first as? UIStackView,
              let textField = stackView.arrangedSubviews.first as? UITextField else {
            return
        }
        
        textField.resignFirstResponder()
    }
    
    @objc
    private func selectPreviousButtonAction(_ sender: Any?) {
        let selectionIndex = ToastType.allCases.firstIndex(of: selection) ?? 0
        let previousIndex = selectionIndex - 1
        
        guard previousIndex >= 0 else {
            return
        }
        
        selection = ToastType.allCases[previousIndex]
    }
    
    @objc
    private func selectNextButtonAction(_ sender: Any?) {
        let selectionIndex = ToastType.allCases.firstIndex(of: selection) ?? 0
        let nextIndex = selectionIndex + 1
        
        guard nextIndex < ToastType.allCases.count else {
            return
        }
        
        selection = ToastType.allCases[nextIndex]
    }
    
    @objc
    private func showToastButtonAction(_ sender: UIButton) {
        switch selection {
        case .title:
            showToastWithTitle()
        case .titleAndIcon:
            showToastWithTitleAndIcon()
        case .titleAndSubtitle:
            showToastWithTitleAndSubtitle()
        case .titleAndSubtitleAndIcon:
            showToastWithTitleSubtitleAndIcon()
        case .customContentView:
            showToastWithCustomContent()
        case .customContentViewWithCustomBackground:
            showToastWithCustomContentAndBackground()
        }
    }
    
    // Picker Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ToastType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        ToastType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection = ToastType.allCases[row]
    }
    
    // TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        return false
    }
    
    // Toasts
    
    private func showToastWithTitle() {
        let toast = UIToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleAndIcon() {
        let toast = UIToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        
        toast.configuration.icon = UIImage(systemName: "star.fill")?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.red)
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleAndSubtitle() {
        let toast = UIToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        toast.configuration.valueSubtitle = "Some subtitle"
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithTitleSubtitleAndIcon() {
        let toast = UIToast(title: "Hello, World!")
        toast.role = .informational
        toast.duration = .indefinite
        
        let icon = UIImage(systemName: "star.fill")?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.red)
        toast.configuration.icon = icon
        toast.configuration.valueSubtitle = "Some subtitle"
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithCustomContent() {
        let label = UILabel()
        label.text = "Hello, Custom World!"
        
        let toast = UIToast(contentView: label)
        toast.role = .informational
        toast.duration = .indefinite
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
    
    private func showToastWithCustomContentAndBackground() {
        let label = UILabel()
        label.text = "Hello, Custom World!"
        
        let backgroundView = UIVisualEffectView(
            effect: UIBlurEffect(style: .regular)
        )
        
        let toast = UIToast(
            contentView: label,
            backgroundView: backgroundView
        )
        toast.role = .informational
        toast.duration = .indefinite
        
        schedulePresentation(of: toast) {
            print("UIToast Shown")
        } onDismiss: {
            print("UIToast Dismissed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.dismiss()
        }
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview {
    UIPreviewViewController()
}

#endif

#endif


