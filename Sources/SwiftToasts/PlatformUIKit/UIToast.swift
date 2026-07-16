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
        public var icon: UIImage?
        public var title: String?
        public var valueSubtitle: String?
        
        public var contentView: UIView?
        public var backgroundView: UIView?
        
        public init(
            icon: UIImage? = nil,
            title: String,
            valueSubtitle: String? = nil
        ) {
            self.icon = icon
            self.title = title
            self.valueSubtitle = valueSubtitle
        }
        
        public init(
            contentView: UIView,
            backgroundView: UIView? = nil
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
        icon: UIImage? = nil,
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
        contentView: UIView,
        backgroundView: UIView? = nil
    ) {
        self.configuration = Configuration()
        self.contentConfiguration = ContentConfiguration(
            contentView: contentView,
            backgroundView: backgroundView
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
        
        var toastStyle: AnyToastStyle = toast.configuration.toastStyle.erased()
        if let backgroundView = toast.contentConfiguration.backgroundView {
            toastStyle = UIKitBridgedToastStyle(
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
}

// MARK: Toast + UIToast.ContentConfiguration

extension Toast {
    
    init(
        role: ToastRole,
        duration: ToastDuration,
        contentConfiguration: UIToast.ContentConfiguration
    ) {
        if let contentView = contentConfiguration.contentView {
            self = .init(
                role: role,
                duration: duration
            ) {
                UIKitBridgedView(contentView)
            }
        } else if let title = contentConfiguration.title {
            self = .init(
                icon: contentConfiguration.icon.flatMap({ Image(uiImage: $0) }),
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
        textField.placeholder = "Enter a message"
        textField.borderStyle = .roundedRect
        textField.text = selection.rawValue
        textField.allowsEditingTextAttributes = false
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.frame.size = CGSize(
            width: view.frame.width,
            height: view.frame.height * 0.5
        )
        picker.sizeToFit()
        textField.inputView = picker
        
        let toolBar = UIToolbar()
        var doenButtonStyle: UIBarButtonItem.Style = .done
        if #available(iOS 26.0, *) {
            doenButtonStyle = .prominent
        }
        
        let doneEditingButton = UIBarButtonItem(
            title: "Done",
            style: doenButtonStyle,
            target: self,
            action: #selector(self.tapAction)
        )
        
        toolBar.setItems(
            [
                doneEditingButton,
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
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        toolBar.frame.size.width = view.frame.width
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
        
        toast.contentConfiguration.icon = UIImage(systemName: "star.fill")?
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
        toast.contentConfiguration.valueSubtitle = "Some subtitle"
        
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
        toast.contentConfiguration.icon = icon
        toast.contentConfiguration.valueSubtitle = "Some subtitle"
        
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
