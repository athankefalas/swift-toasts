//
//  ToastReceivePublisherModifier.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 10/10/24.
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
    
    @PresentationBoundState
    private var cancellables: Set<AnyCancellable> = []
    
    @FallbackStateObject
    private var publisherSubscriber: PublisherSubscriber
    
    private let toastAlignment: ToastAlignment
    private let onToastDismiss: (@MainActor () -> Void)?
    private let toast: (Result<Output, Failure>) -> Toast?
    
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
            guard let newValueResult = newValue.toResult,
                  let toast = toast(newValueResult) else {
                return
            }
            
            toastPresenter._schedule(
                presentation: ToastPresentation(
                    toast: toast,
                    toastAlignment: toastAlignment,
                    toastStyle: toastStyle,
                    toastTransition: toastTransition,
                    presentationCanceller: nil,
                    onDismiss: onToastDismiss
                ),
                cancellationPolicy: toastCancellation.byReplacingAutomatic(
                    with: .presentation
                ),
                cancellables: &cancellables
            )
        }
    }
}

public typealias PublishedResult<P: Publisher> = Result<P.Output, P.Failure>

public extension View {
    
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
        every: 5,
        on: .main,
        in: .common
    )
    .autoconnect()
    .receive(on: DispatchQueue.global(qos: .background))
    .tryMap { date in
        if date.timeIntervalSince(start) > 5 * 3 {
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
