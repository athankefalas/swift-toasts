//
//  ToastConfiguration.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

/// The properties of a Toast component.
@MainActor
public struct ToastConfiguration: Sendable {
    public let role: ToastRole
    public let duration: ToastDuration
    public let content: AnyView
    
    init<Content: View>(
        role: ToastRole,
        duration: ToastDuration,
        content: Content
    ) {
        self.role = role
        self.duration = duration
        self.content = AnyView(content)
    }
}

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
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 10
            ) {
                self.state = .reachable
            }
        }
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
            }
            .disabled(saved || monitor.state != .reachable)
            .toast(isPresented: $saved) {
                dismiss()
            } content: {
                Toast("Settings saved.", role: .success)
            }
            .toastCancellation(.never)
        }
        .navigationTitle("Sound Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: settings) { _ in
            saved = false
        }
        .toast(byReceiving: monitor.$state) { newValue in
            if case NetworkState.unreachable = newValue {
                Toast(
                    "Disconnected from the network.",
                    systemImage: "network.slash",
                    role: .warning
                )
            }
        }
        .toastCancellation(.presentation)
        .toastPresentationInvalidation(.all)
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

extension Color {
    
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
