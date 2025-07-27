//
//  ToastReceivePublisherModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 10/10/24.
//

import SwiftUI
import Combine

private struct ToastReceivePublisherModifier<Output: Equatable, Failure: Error>: ViewModifier {
    
    private enum PublisherState: Equatable {
        case empty
        case received(Output)
        case failed(Failure)
        
        private var caseID: Int {
            switch self {
            case .empty:
                return 1
            case .received:
                return 2
            case .failed:
                return 3
            }
        }
        
        var toResult: Result<Output, Failure>? {
            switch self {
            case .empty:
                return nil
            case .received(let output):
                return .success(output)
            case .failed(let failure):
                return .failure(failure)
            }
        }
        
        static func == (lhs: PublisherState, rhs: PublisherState) -> Bool {
            guard case PublisherState.received(let lhsValue) = lhs,
                  case PublisherState.received(let rhsValue) = rhs else {
                return lhs.caseID == rhs.caseID
            }
            
            return lhsValue == rhsValue
        }
    }
    
    @MainActor
    private class PublisherSubscriber: ObservableObject {
        
        @Published
        private(set) var value: PublisherState = .empty
        
        private let publisher: AnyPublisher<Output, Failure>
        private var subscription: AnyCancellable?
        
        init(publisher: AnyPublisher<Output, Failure>) {
            self.publisher = publisher
            self.subscription = publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.receiveCompletion(completion)
                } receiveValue: { [weak self] newValue in
                    self?.receiveValue(newValue)
                }
        }
        
        deinit {
            MainActor.assumeIsolated {
                subscription?.cancel()
                subscription = nil
            }
        }
        
        private func receiveCompletion(_ completion: Subscribers.Completion<Failure>) {
            guard case let Subscribers.Completion<Failure>.failure(error) = completion else {
                return
            }
            
            value = .failed(error)
        }
        
        private func receiveValue(_ value: Output) {
            if self.value == .empty {
                self.value = .received(value)
                return
            }
            
            guard case let PublisherState.received(previousOutput) = self.value,
                previousOutput != value else {
                return
            }
            
            self.value = .received(value)
        }
    }
    
    @Environment(\.toastPresenter)
    private var toastPresenter
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @Environment(\.toastTransition)
    private var toastTransition
    
    @Environment(\.toastCancellation)
    private var toastCancellation
    
    @Environment(\.toastPresentationInvalidation)
    private var toastPresentationInvalidation
    
    @Environment(\.toastInteractiveDismissEnabled)
    private var toastInteractiveDismissEnabled
    
    @PresentationBoundState
    private var cancellables: Set<AnyCancellable> = []
    
    @State
    private var presentationCanceller = ToastPresentationCanceller()
    
    @FallbackStateObject
    private var publisherSubscriber: PublisherSubscriber
    
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor () -> Void)?
    private let toast: (Result<Output, Failure>) -> Toast?
    
    private var invalidationOptions: ToastPresentationInvalidationOptions {
        toastPresentationInvalidation ?? .contextChanged
    }
    
    init(
        publisher: AnyPublisher<Output, Failure>,
        toastAlignment: ToastAlignment,
        onToastDismiss:(@MainActor () -> Void)?,
        toast: @escaping (Result<Output, Failure>) -> Toast?
    ) {
        self.toastAlignment = toastAlignment
        self.onToastDismiss = onToastDismiss
        self.toast = toast
        self._publisherSubscriber = FallbackStateObject(
            wrappedValue: PublisherSubscriber(
                publisher: publisher
            )
        )
    }
    
    func body(content: Content) -> some View {
        content.fallbackOnChange(of: publisherSubscriber.value) { newValue in
            guard let newValueResult = newValue.toResult else {
                return
            }
            
            if invalidationOptions.contains(.contextChanged) {
                presentationCanceller.dismissPresentation()
            }
            
            guard let toast = toast(newValueResult) else {
                return
            }
            
            toastPresenter._schedule(
                presentation: ToastPresentation(
                    toast: toast,
                    toastAlignment: toastAlignment,
                    toastEnvironmentValues: ToastEnvironmentValues(
                        toastStyle: toastStyle,
                        toastTransition: toastTransition,
                        toastInteractiveDismissEnabled: toastInteractiveDismissEnabled
                    ),
                    presentationCanceller: presentationCanceller,
                    onDismiss: onToastDismiss
                ),
                cancellationPolicy: toastCancellation.byReplacingAutomatic(
                    with: .presentation
                ),
                cancellables: &cancellables
            )
        }
        .fallbackOnChange(of: invalidationOptions) { newValue in
            presentationCanceller.dismissOnDeinit = newValue.contains(.presentationDismissed)
        }
        .onAppear {
            presentationCanceller.dismissOnDeinit = invalidationOptions.contains(.presentationDismissed)
        }
    }
}

public typealias PublishedResult<P: Publisher> = Result<P.Output, P.Failure>

public extension View {
    
    /// Presents a Toast when the given publisher publishes a new value.
    /// - Parameters:
    ///   - publisher: The given publisher.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present for the given published result.
    func toast<ValuePublisher: Publisher>(
        byReceiving publisher: ValuePublisher,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping (PublishedResult<ValuePublisher>) -> Toast?
    ) -> some View
    where ValuePublisher.Output: Equatable {
        modifier(
            ToastReceivePublisherModifier(
                publisher: publisher.eraseToAnyPublisher(),
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: toast
            )
        )
    }
    
    /// Presents a Toast when the given publisher publishes a new value.
    /// - Parameters:
    ///   - publisher: The given publisher.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present for the given published result.
    func toast<ValuePublisher: Publisher>(
        byReceiving publisher: ValuePublisher,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping (ValuePublisher.Output) -> Toast?
    ) -> some View
    where ValuePublisher.Output: Equatable, ValuePublisher.Failure == Never {
        modifier(
            ToastReceivePublisherModifier(
                publisher: publisher.eraseToAnyPublisher(),
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: {
                    if case let Result.success(value) = $0 {
                        return toast(value)
                    } else {
                        return nil
                    }
                }
            )
        )
    }
    
    /// Presents a Toast when the given publisher publishes a new value.
    /// - Parameters:
    ///   - publisher: The given publisher.
    ///   - alignment: The alignment to use when presenting the Toast.
    ///   - onDismiss: A callback invoked when the Toast is dismissed.
    ///   - toast: The Toast to present when the publisher fires.
    func toast<ValuePublisher: Publisher>(
        byReceiving publisher: ValuePublisher,
        alignment: ToastAlignment = .defaultAlignment,
        onDismiss:(@MainActor () -> Void)? = nil,
        @ToastBuilder content toast: @escaping () -> Toast?
    ) -> some View
    where ValuePublisher.Output: Equatable {
        modifier(
            ToastReceivePublisherModifier(
                publisher: publisher.eraseToAnyPublisher(),
                toastAlignment: alignment,
                onToastDismiss: onDismiss,
                toast: { _ in toast() }
            )
        )
    }
}

// MARK: Previews

#if DEBUG

let start = Date()

struct _ToastReceivePublisherModifierPreview: View {
    
    @State
    private var timer = Timer.publish(
        every: 1.5,
        on: .main,
        in: .common
    )
    .autoconnect()
    .receive(on: DispatchQueue.global(qos: .background))
    .tryMap { date in
        if date.timeIntervalSince(start) > 1.5 * 3 {
            throw CancellationError()
        } else {
            return date
        }
    }
    .map({ round($0.timeIntervalSince1970).truncatingRemainder(dividingBy: 2) == 0 })
    
    var body: some View {
        Text("Content")
            .toast(byReceiving: timer) {
                Toast("Toast Message!")
            }
    }
}

#Preview {
    PreviewContent {
        PresentedPreview {
            _ToastReceivePublisherModifierPreview()
        }
    }
}

#endif
