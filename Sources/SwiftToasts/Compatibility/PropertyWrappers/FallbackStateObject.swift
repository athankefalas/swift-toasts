//
//  FallbackStateObject.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 1/11/24.
//

@preconcurrency import SwiftUI
@preconcurrency import Combine

@MainActor
@preconcurrency
@propertyWrapper
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct FallbackStateObject<Value: ObservableObject>: @preconcurrency DynamicProperty, Sendable {
    
    @MainActor
    private final class ObservableObjectChangedBrigde: ObservableObject {}
    
    @MainActor
    private final class Storage: @unchecked Sendable {
        private var namespace: UUID
        private var latestValue: Value?
        private var observation: AnyCancellable?
        private var observationCallback: @MainActor () -> Void
        private let wrappedValueProvider: () -> Value
        
        var holdsValue: Bool {
            latestValue != nil
        }
        
        init(
            namespace: UUID,
            wrappedValue wrappedValueProvider: @escaping () -> Value
        ) {
            self.latestValue = nil
            self.namespace = namespace
            self.observationCallback = {}
            self.wrappedValueProvider = wrappedValueProvider
        }
        
        deinit {
            MainActor.assumeIsolated {
                dismantle()
            }
        }
        
        final func onObservableObjectWillChange(
            perform action: @escaping @MainActor () -> Void
        ) {
            self.observationCallback = action
        }
        
        final func get() -> Value {
            
            if let latestValue = latestValue {
                return latestValue
            }
            
            let newValue = makeNewValue()
            self.latestValue = newValue
            
            return newValue
        }
        
        final func set(to newValue: Value) {
            self.latestValue = newValue
        }
        
        final func update(
            namespace: UUID
        ) {
            
            guard namespace != self.namespace else {
                return initIfNeeded()
            }
            
            self.namespace = namespace
            self.latestValue = makeNewValue()
        }
        
        private final func initIfNeeded() {
            guard latestValue == nil else {
                return
            }
            
            latestValue = makeNewValue()
        }
        
        private final func makeNewValue() -> Value {
            let newValue = wrappedValueProvider()
            observation?.cancel()
            observation = newValue.objectWillChange
                .sink { [weak self] _ in
                    self?.observationCallback()
                }
            
            return newValue
        }
        
        final func dismantle() {
            latestValue = nil
            observation?.cancel()
            observation = nil
        }
    }
    
    @State
    private var namespace: UUID
    
    @State
    private var storage: Storage
    
    @ObservedObject
    private var observableObjectChangedBrigde = ObservableObjectChangedBrigde()
    
    @MainActor
    var wrappedValue: Value {
        get {
            storage.get()
        }
        
        nonmutating set {
            storage.set(to: newValue)
        }
    }
    
    @MainActor
    public var projectedValue: Binding<Value> {
        Binding {
            wrappedValue
        } set: { newValue, transaction in
            $storage.transaction(transaction).wrappedValue.set(to: newValue)
        }
    }
    
    init(wrappedValue: @escaping @autoclosure () -> Value) {
        let namespace = UUID()
        self._namespace = State(
            initialValue: namespace
        )
        
        self._storage = State(
            initialValue:
                Storage(
                    namespace: namespace,
                    wrappedValue: wrappedValue
                )
        )
    }
    
    func update() {
        storage.update(namespace: namespace)
        storage.onObservableObjectWillChange { [weak observableObjectChangedBrigde] in
            observableObjectChangedBrigde?.objectWillChange.send()
        }
    }
}

// MARK: Previews

#if ENABLE_PREVIEWS

struct _FallbackStateObjectPreview: View {
    
    struct WrappedContent: View {
        @FallbackStateObject
        var object = SomeObservableOject()
        
        var body: some View {
            VStack {
                Text("Count \(object.count)")
                
                Button("Increment") {
                    object.count += 1
                }
                
                Button("Decrement") {
                    object.count -= 1
                }
                
#if !os(tvOS) && !os(watchOS)
                Stepper("Value", value: $object.count, step: 1)
#endif
                Divider()
                
                NavigationLink("Say Hi") {
                    Text("Hello!")
                }
            }
        }
    }
    
    @Environment(\.fallbackIsPresented)
    private var isPresented
    
    @State
    var identity = Date()
    
    var body: some View {
        VStack {
            Button("Invalidate ID") { identity = Date() }
            
            WrappedContent()
                .padding(32)
                .id(identity)
        }
        .fallbackOnChange(of: isPresented) { newValue in
            print("## IsPresented \(newValue)")
        }
    }
}

#Preview {
    PresentedPreview {
        _FallbackStateObjectPreview()
    }
}

#endif
