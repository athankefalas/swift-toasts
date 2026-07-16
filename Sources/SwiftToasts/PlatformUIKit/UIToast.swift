//
//  UIToast.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

#if canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)

import UIKit
import SwiftUI

@MainActor
public class UIToast: NSObject {
    
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
        public var icon: UIImage?
        public var title: String?
        public var valueSubtitle: String?
        
        public var contentView: UIView?
        public var backgroundView: UIView?
        
        public init(
            icon: UIImage?,
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
            contentView: UIView,
            backgroundView: UIView?,
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
    public fileprivate(set) var isPresented: Bool = false
    fileprivate var presentationCanceller: ToastPresentationCanceller
    
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
    
    public var inferredContentType: InferredContentType {
        if configuration.contentView != nil {
            return .customContent
        }
        
        if configuration.title != nil {
            return .standardContent
        }
        
        return .invalid
    }
    
    public var canBePresented: Bool {
        inferredContentType != .invalid
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
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
        
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
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
        
        self.presentationCanceller = ToastPresentationCanceller()
    }
    
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
    let backgroundView: UIView
    
    func makeBody(configuration: Configuration) -> some View {
        StyledViewBody(
            insetContent: false,
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
        var toastStyle: AnyToastStyle = configuration.toastStyle.erased()
        if let backgroundView = configuration.backgroundView {
            toastStyle = UIKitBridgedToastStyle(
                inheritedStyle: toastStyle,
                backgroundView: backgroundView
            ).erased()
        }
        
        presenter.schedule(
            presentation: ToastPresentation(
                toast: Toast(contentConfiguration: configuration),
                toastAlignment: toast.configuration.toastAlignment,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastStyle: toastStyle,
                    toastTransition: toast.configuration.toastTransition,
                    toastInteractiveDismissEnabled: toast.configuration.toastInteractiveDismissEnabled,
                    toastBackgroundInteractionEnabled: toast.configuration.toastBackgroundInteractionEnabled,
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
        return showLoadingHUD()
        
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
    
    // Stuff
    
    var loadingTask: Task<Void, Never>?
    func someLongOperation() async {
        if #available(iOS 16.0, *) {
            try? await Task.sleep(for: .seconds(10))
        } else { // Fallback on earlier versions
            try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
        }
    }
}

extension UIPreviewViewController {
//class SomeViewController: UIViewController {
    
    func handleShowToastAction(_ sender: Any?) {
        // Create a Toast with default content
        let toast = UIToast(title: "Logged In.")
        toast.role = .plain
        toast.duration = .short
        
        schedulePresentation(of: toast)
    }
    
    func handleShowToastAction2(_ sender: Any?) {
        // Create a Toast with default content
        let toast = UIToast(title: "Logged In.")
        toast.role = .plain
        toast.duration = .short
        
        schedulePresentation(of: toast)
    }
    
    func showAddedToFavoritesToast(itemName: String?) {
        // Create a Toast with default content
        let toast = UIToast(
            icon: UIImage(systemName: "star.fill"),
            title: "Added to Favorites",
            valueSubtitle: itemName
        )
        
        toast.role = .informational
        toast.duration = .long
        
        schedulePresentation(of: toast)
    }
    
    class HUDContentStackView: UIStackView {
        var preferredContentSize: CGSize?
        
        override var intrinsicContentSize: CGSize {
            if let preferredContentSize {
                return preferredContentSize
            }
            
            return super .intrinsicContentSize
        }
    }
    
    func showLoadingHUD() {
        let hudContent = HUDContentStackView()
        hudContent.axis = .vertical
        hudContent.distribution = .fillProportionally
        hudContent.spacing = 8
        hudContent.alignment = .center
        hudContent.preferredContentSize = CGSize(
            width: view.frame.width * 0.33,
            height: 100
        )
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.color = .white
        hudContent.addArrangedSubview(activityIndicator)
        
        let label = UILabel()
        label.text = "Loading"
        label.textColor = .white
        hudContent.addArrangedSubview(label)
        
        let hudBackgroundView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemThinMaterialDark)
        )
        
        hudBackgroundView.layer.cornerRadius = 24
        hudBackgroundView.subviews.forEach({ $0.layer.cornerRadius = 24 })

        let toast = UIToast(
            contentView: hudContent,
            backgroundView: hudBackgroundView
        )
        toast.role = .plain
        toast.duration = .indefinite
        toast.configuration.toastAlignment = .center
        toast.configuration.toastTransition = .opacity
        toast.configuration.toastInteractiveDismissEnabled = false
        toast.configuration.toastBackgroundInteractionEnabled = false
        
        schedulePresentation(of: toast) {
            self.loadingTask = Task {
                await self.someLongOperation()
                toast.dismiss()
            }
        } onDismiss: {
            self.loadingTask = nil
        }
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview {
    UIPreviewViewController()
}

#endif

#endif
