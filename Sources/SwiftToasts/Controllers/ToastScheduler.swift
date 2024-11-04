//
//  ToastScheduler.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI
import Combine

actor ToastScheduler: @preconcurrency CustomReflectable {
    
    private enum ToastPresentationState: Hashable, Sendable {
        case queued
        case cancelled
        case presented(Date)
        case completed
        
        var isHandled: Bool {
            switch self {
            case .cancelled:
                return true
            case .completed:
                return true
            default:
                return false
            }
        }
        
        mutating func cancelled() {
            guard self == .queued else {
                return
            }
            
            self = .cancelled
        }
        
        mutating func presented() {
            guard self == .queued else {
                return
            }
            
            self = .presented(Date())
        }
        
        mutating func dismissed() {
            guard case ToastPresentationState.presented = self else {
                return
            }
            
            self = .completed
        }
    }
    
    @MainActor
    private final class ToastPresentationRequest {
        private var state: ToastPresentationState
        private(set) var presentation: ToastPresentation
        private var handlingTask: Task<Void, Never>?
        
        var isCancelled: Bool {
            state == .cancelled
        }
        
        init(
            presentation: ToastPresentation
        ) {
            self.state = .queued
            self.presentation = presentation
            
            
            self.presentation = presentation
                .onPresent { [weak self] in
                    self?.state.presented()
                }
                .onDismiss { [weak self] in
                    self?.state.dismissed()
                    self?.handlingTask?.cancel()
                }
        }
        
        final func canceller() -> AnyCancellable {
            AnyCancellable { [weak self] in
                self?.state.cancelled()
            }
        }
        
        final func handled() async {
            if handlingTask == nil {
                handlingTask = Task {
                    while !state.isHandled {
                        do {
                            let waitingTimeSeconds = max(remainingTimeInterval(), 0.3)
                            try await Task.sleep(duration: .seconds(waitingTimeSeconds))
                        } catch {
                            break
                        }
                    }
                }
            }
            
            await handlingTask?.value
        }
        
        private final func remainingTimeInterval() -> TimeInterval {
            let toastDuration = presentation.toast.configuration.duration
            
            guard case let ToastPresentationState.presented(time) = state,
                  toastDuration.rawValue > 0 else {
                return 0
            }
            
            let now = Date()
            let expirationTime = time.addingTimeInterval(toastDuration.rawValue)
            
            guard expirationTime > now else {
                return 0
            }
            
            return expirationTime.timeIntervalSince(now)
        }
    }
    
    private let handler: @MainActor (ToastPresentation) async -> Void
    private let toastStream: AsyncStream<ToastPresentationRequest>
    private let toastStreamContinuation: AsyncStream<ToastPresentationRequest>.Continuation
    private var handlingTask: Task<Void, Never>?
    
    var customMirror: Mirror {
        Mirror(self, children: [], displayStyle: .class)
    }
    
    init(
        handlerID: ObjectIdentifier,
        handler: @escaping @MainActor (ToastPresentation) async -> Void
    ) {
        self.handler = handler
        let streamContinuationPair = AsyncStream.makeStream(of: ToastPresentationRequest.self)
        self.toastStream = streamContinuationPair.stream
        self.toastStreamContinuation = streamContinuationPair.continuation
        
        Task(priority: .userInitiated) { @MainActor in
            await self.startHandling(handlerID: handlerID)
        }
    }
    
    deinit {
        handlingTask?.cancel()
        toastStreamContinuation.finish()
    }
    
    private func startHandling(
        handlerID: ObjectIdentifier
    ) {
        
        self.handlingTask = Task(priority: .low) { @MainActor in
            let scenePhaseObserver = ScenePhaseObserver(handlerID: handlerID)
            
            for await toastRequest in toastStream {
                await scenePhaseObserver.appIsActive()
                                
                guard !toastRequest.isCancelled else {
                    continue
                }
                
                await handler(toastRequest.presentation)
                await toastRequest.handled()
            }
            
            assert(Task.isCancelled, "Handling task loop should never finish without task cancelleation.")
        }
    }
    
    @MainActor
    func schedulePresentation(
        _ toastPresentation: ToastPresentation
    ) {
        toastStreamContinuation.yield(
            ToastPresentationRequest(
                presentation: toastPresentation
            )
        )
    }
    
    @MainActor
    func scheduleCancellablePresentation(
        _ toastPresentation: ToastPresentation
    ) -> AnyCancellable {
        let entry = ToastPresentationRequest(
            presentation: toastPresentation
        )
        
        toastStreamContinuation.yield(entry)
        return entry.canceller()
    }
}
