//
//  ToastScheduler.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
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
        
        static func cancellationToken() -> ToastPresentationRequest {
            return ToastPresentationRequest(
                presentation: ToastPresentation(
                    toast: Toast(""),
                    toastAlignment: .bottom,
                    toastEnvironmentValues: ToastEnvironmentValues(),
                    presentationCanceller: nil
                )
            )
        }
    }
    
    private let handler: @MainActor (ToastPresentation) async -> Void
    private let toastStream: AsyncStream<ToastPresentationRequest>
    private let toastStreamContinuation: AsyncStream<ToastPresentationRequest>.Continuation
    private var handlingTask: Task<Void, Never>?
    
    @MainActor
    private var cancellationToken: ToastPresentationRequest?
    
    var customMirror: Mirror {
        Mirror(self, children: [], displayStyle: .class)
    }
    
    init(
        presenterID: ObjectIdentifier,
        presenterPhasePublisher: AnyPublisher<PresenterPhaseObserver.PresenterPhase, Never>? = nil,
        handler: @escaping @MainActor (ToastPresentation) async -> Void
    ) {
        self.handler = handler
        let streamContinuationPair = AsyncStream.makeStream(of: ToastPresentationRequest.self)
        self.toastStream = streamContinuationPair.stream
        self.toastStreamContinuation = streamContinuationPair.continuation
        
        Task(priority: .userInitiated) { @MainActor in
            await self.startHandling(
                presenterID: presenterID,
                presenterPhasePublisher: presenterPhasePublisher
            )
        }
    }
    
    deinit {
        handlingTask?.cancel()
        toastStreamContinuation.finish()
    }
    
    private func startHandling(
        presenterID: ObjectIdentifier,
        presenterPhasePublisher: AnyPublisher<PresenterPhaseObserver.PresenterPhase, Never>?
    ) {
        let handler = self.handler
        let toastStream = self.toastStream
        self.handlingTask = Task(priority: .low) { @MainActor [weak self] in
            let scenePhaseObserver = ScenePhaseObserver(sceneID: presenterID)
            let presenterPhaseObserver = PresenterPhaseObserver(presenterPhasePublisher: presenterPhasePublisher)
            
            for await toastRequest in toastStream {
                guard let self,
                      !Task.isCancelled else {
                    break
                }
                
                if let cancellationToken = self.cancellationToken {
                    if cancellationToken === toastRequest {
                        self.cancellationToken = nil
                    }
                    
                    toastRequest.canceller().cancel()
                    continue
                }
                
                await scenePhaseObserver.appIsActive()
                await presenterPhaseObserver.presenterIsActive()
                
                if Task.isCancelled {
                    break
                }
                
                guard !toastRequest.isCancelled else {
                    continue
                }
                
                await handler(toastRequest.presentation)
                await toastRequest.handled()
                
                if Task.isCancelled {
                    break
                }
            }
            
            assert(
                Task.isCancelled,
                "Handling task loop should never finish without prior task cancellation."
            )
        }
    }
    
    @MainActor
    @discardableResult
    func cancelScheduledPresentations() -> Bool {
        guard cancellationToken == nil else {
            return false
        }
        
        let semanticCancellationToken = ToastPresentationRequest.cancellationToken()
        cancellationToken = semanticCancellationToken
        toastStreamContinuation.yield(semanticCancellationToken)
        return true
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
