//
//  SoundSettingsExample.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 27/7/25.
//

import SwiftUI

#if DEBUG

struct SoundSettingsModel: Hashable {
    var isOn = true
    var volume = 100.0
    
    func save() -> Bool { true }
}

enum NetworkState {
    case unknown
    case reachable
    case unreachable
}

@MainActor
class NetworkMonitor: ObservableObject {
    @Published
    var state: NetworkState = .reachable
    
    init() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 4.5
        ) {
            self.state = .unreachable
        }
    }
    
    func checkReachable() {
        self.state = .reachable
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
struct SoundSettingsExample: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @StateObject
    var monitor = NetworkMonitor()
    
    @State
    private var settings = SoundSettingsModel()
    
    @State
    private var initialSettingsSignature: Int?
    
    @State
    private var saved = false
    
    var body: some View {
        List {
            Section {
                Toggle("Sounds", isOn: $settings.isOn)
                    .toast(trigger: settings.isOn) { newValue in
                        if newValue {
                            Toast("Sound enabled.")
                        } else {
                            Toast("Sound muted.")
                        }
                    }
                    .toastCancellation(.always)
                    .toastTransition(.opacity)
                    .toastPresentationInvalidation(.all)
                    .toastInteractiveDismissDisabled(true)
            }
            
            if settings.isOn {
                Section("Volume") {
                    slider
                }
            }
            
            Button("Save") {
                saved = settings.save()
                initialSettingsSignature = settings.hashValue
                dismiss()
            }
            .disabled(
                initialSettingsSignature == settings.hashValue || monitor.state != .reachable
            )
            .toast(isPresented: $saved) {
                Toast("Settings saved.", role: .success)
            }
            .toastCancellation(.never)
        }
        .navigationTitle("Sound Settings")
        .toolbarTitleDisplayMode(.inline)
        .toast(byReceiving: monitor.$state) {
            monitor.state = .reachable
        } content: { newValue in
            if case NetworkState.unreachable = newValue {
                Toast(
                    "Disconnected from the network.",
                    systemImage: "network.slash",
                    role: .warning
                )
            }
        }
        .toastCancellation(.presentation)
        .onAppear {
            initialSettingsSignature = settings.hashValue
        }
    }
    
    private var slider: some View {
#if !os(tvOS)
        Slider(value: $settings.volume, in: 0...100) {
            Text("Volume: \(settings.volume)%")
        }
#else
        HStack {
            Button("Decrease") {
                settings.volume -= 10
            }
            
            Text("Volume \(settings.volume)%")
            
            Button("Increase") {
                settings.volume += 10
            }
        }
#endif
    }
}


#Preview {
    PresentedPreview {
        ZStack {
            if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
                SoundSettingsExample()
            }
        }
    }
}

#endif
