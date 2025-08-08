//
//  SwiftUI+Fallbacks.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 31/10/24.
//

import SwiftUI

extension View {
    
    func fallbackAccessibilityIdentifier(_ identifier: String) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.accessibilityIdentifier(identifier)
        } else {
            self.accessibility(identifier: identifier)
        }
    }
    
    func fallbackAccessibilityHidden(_ hidden: Bool) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.accessibilityHidden(hidden)
        } else {
            self.accessibility(hidden: hidden)
        }
    }
    
    func fallbackAccessibilityAddTraits(_ traits: AccessibilityTraits) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.accessibilityAddTraits(traits)
        } else {
            self.accessibility(addTraits: traits)
        }
    }
}

extension Font {
    
    static var fallbackTitle3: Font {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return .title3
        } else {
            return .title
        }
    }
}

extension EnvironmentValues {
    
    var fallbackIsPresented: Bool {
        get { self.presentationMode.wrappedValue.isPresented }
    }
}

// MARK: OnHover


private struct OnHoverFallbackModifier: ViewModifier {
    
    let action: (Bool) -> Void
    
    init(action: @escaping (Bool) -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        modifyContent(content)
    }
    
    func modifyContent(_ content: Content) -> AnyView {
#if os(tvOS) || os(watchOS)
        return AnyView(content)
#else
        if #available(iOS 13.4, macOS 10.15, *) {
            return AnyView(content.onHover(perform: action))
        } else {
            return AnyView(content)
        }
#endif
    }
}

extension View {
    
    func fallbackOnHover(perform action: @escaping (Bool) -> Void) -> some View {
        self.modifier(
            OnHoverFallbackModifier(
                action: action
            )
        )
    }
}

// MARK: OnChange

private struct OnChangeFallbackModifier<Value: Equatable>: ViewModifier {
    
    @State
    var latestValue: Value
    
    let value: Value
    let action: @MainActor (Value) -> Void
    
    init(
        value: Value,
        action: @escaping @MainActor (Value) -> Void
    ) {
        self._latestValue = State(initialValue: value)
        self.value = value
        self.action = action
    }
    
    func body(content: Content) -> some View {
        modifyContent(content)
    }
    
    private func modifyContent(_ content: Content) -> AnyView {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return AnyView(makeBody(content))
        } else {
            return AnyView(makeFallbackBody(content))
        }
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    private func makeBody(_ content: Content) -> some View {
        content.onChange(of: value, perform: action)
    }
    
    private func makeFallbackBody(_ content: Content) -> some View {
        defer {
            evaluatedBody()
        }
        
        return content
    }
    
    private func evaluatedBody() {
        Task(priority: .userInitiated) { @MainActor in
            guard latestValue != value else {
                return
            }
            
            latestValue = value
            action(value)
        }
    }
}

extension View {
    
    func fallbackOnChange<V: Equatable>(
        of value: V,
        perform action: @escaping @MainActor (_ newValue: V) -> Void
    ) -> some View {
        self.modifier(
            OnChangeFallbackModifier(
                value: value,
                action: action
            )
        )
    }
}

// MARK: Task

private struct TaskFallbackModifier: ViewModifier {
    
    @MainActor
    final class PerformedTaskController: ObservableObject, Sendable {
        var activeTask: Task<Void, Never>?
        
        init() {}
        
        deinit {
            MainActor.assumeIsolated {
                cancelTask()
            }
        }
        
        final func beginTask(
            priority: TaskPriority,
            performing action: @escaping @Sendable () async -> Void
        ) {
            activeTask = Task(priority: priority) { @MainActor [weak self] in
                await action()
                self?.activeTask = nil
            }
        }
        
        final func cancelTask() {
            activeTask?.cancel()
            activeTask = nil
        }
    }
    
    struct TaskPerformingContent: View {
        @FallbackStateObject
        private var controller = PerformedTaskController()
        
        let content: Content
        let priority: TaskPriority
        let action: @MainActor @Sendable () async -> Void
        
        var body: some View {
            content
                .onAppear {
                    controller.beginTask(priority: priority) {
                        await action()
                    }
                }
                .onDisappear {
                    controller.cancelTask()
                }
        }
    }
    
    let priority: TaskPriority
    let action: @MainActor @Sendable () async -> Void
    
    init(
        priority: TaskPriority,
        action: @escaping @MainActor @Sendable () async -> Void
    ) {
        self.priority = priority
        self.action = action
    }
    
    func body(content: Content) -> some View {
        modifyContent(content)
    }
    
    private func modifyContent(_ content: Content) -> AnyView {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return AnyView(makeBody(content))
        } else {
            return AnyView(makeFallbackBody(content))
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func makeBody(_ content: Content) -> some View {
        content.task(priority: priority) {
            await action()
        }
    }
    
    private func makeFallbackBody(_ content: Content) -> some View {
        TaskPerformingContent(
            content: content,
            priority: priority
        ) {
            await action()
        }
    }
}

extension View {
    
    func fallbackTask(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        self.modifier(
            TaskFallbackModifier(priority: priority) {
                await action()
            }
        )
    }
}

// MARK: Identifiable Task

private struct IdentifiableTaskFallbackModifier<ID: Equatable>: ViewModifier {
    
    @MainActor
    final class PerformedTaskController: ObservableObject, Sendable {
        var activeTask: Task<Void, Never>?
        
        init() {}
        
        deinit {
            MainActor.assumeIsolated {
                cancelTask()
            }
        }
        
        final func beginTask(
            priority: TaskPriority,
            performing action: @escaping @MainActor @Sendable () async -> Void
        ) {
            activeTask = Task(priority: priority) { @MainActor [weak self] in
                await action()
                self?.activeTask = nil
            }
        }
        
        final func cancelTask() {
            activeTask?.cancel()
            activeTask = nil
        }
    }
    
    struct TaskPerformingContent: View {
        @FallbackStateObject
        private var controller = PerformedTaskController()
        
        let content: Content
        let id: ID
        let priority: TaskPriority
        let action: @MainActor @Sendable () async -> Void
        
        var body: some View {
            content
                .onAppear {
                    controller.beginTask(priority: priority) {
                        await action()
                    }
                }
                .fallbackOnChange(of: id) { newValue in
                    controller.cancelTask()
                    controller.beginTask(priority: priority) {
                        await action()
                    }
                }
                .onDisappear {
                    controller.cancelTask()
                }
        }
    }
    
    let id: ID
    let priority: TaskPriority
    let action: @MainActor @Sendable () async -> Void
    
    init(
        id: ID,
        priority: TaskPriority,
        action: @escaping @MainActor @Sendable () async -> Void
    ) {
        self.id = id
        self.priority = priority
        self.action = action
    }
    
    func body(content: Content) -> some View {
        modifyContent(content)
    }
    
    private func modifyContent(_ content: Content) -> AnyView {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return AnyView(makeBody(content))
        } else {
            return AnyView(makeFallbackBody(content))
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func makeBody(_ content: Content) -> some View {
        content.task(id: id, priority: priority) {
            await action()
        }
    }
    
    private func makeFallbackBody(_ content: Content) -> some View {
        TaskPerformingContent(
            content: content,
            id: id,
            priority: priority
        ) {
            await action()
        }
    }
}

extension View {
    
    func fallbackTask<ID: Equatable>(
        id: ID,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        self.modifier(
            IdentifiableTaskFallbackModifier(id: id, priority: priority) {
                await action()
            }
        )
    }
}

struct FallbackAnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        self._path = { shape.path(in: $0) }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}
