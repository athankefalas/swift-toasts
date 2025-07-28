//
//  SoundSettingsExample.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 27/7/25.
//

import SwiftUI

#if DEBUG && os(iOS)

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

@available(iOS 17.0, *)
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
                    Slider(value: $settings.volume, in: 0...100) {
                        Text("Volume: \(settings.volume)%")
                    }
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
        .navigationBarTitleDisplayMode(.inline)
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
}

struct PreviewStage: View {
    var body: some View {
        PresentedPreview {
            ZStack {
                if #available(iOS 17.0, *) {
                    SoundSettingsExample()
                }
            }
        }
    }
}


#Preview {
    PreviewStage()
}

#endif
