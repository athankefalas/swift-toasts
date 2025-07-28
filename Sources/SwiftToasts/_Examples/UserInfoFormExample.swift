//
//  UserInfoFormExample.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 27/7/25.
//

import SwiftUI

#if DEBUG //&& os(iOS)

@available(iOS 17.0, macOS 14.0, *)
@MainActor
@Observable
class UserInfoFormModel {
    enum Field: String, Hashable {
        case firstName
        case middleName
        case lastName
        case age
        case submit
    }
    
    var firstName: String
    var middleName: String
    var lastName: String
    var age: Int
    
    init(
        firstName: String = "",
        middleName: String = "",
        lastName: String = "",
        age: Int = 0
    ) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.age = age
    }
    
    func load() async throws {
        try await Task.sleep(for: .seconds(2))
        
        guard Bool.random() else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        self.firstName = "John"
        self.middleName = "Appleseed"
        self.lastName = "Doe"
        self.age = 33
    }
    
    func submitted(
        field: Field
    ) -> Field? {
        switch field {
            case .firstName:
                return .middleName
            case .middleName:
                return .lastName
            case .lastName:
                return .age
            case .age:
                return .submit
            case .submit:
                return nil
        }
    }
    
    func save() async throws {
        try await Task.sleep(for: .seconds(3))
        if Bool.random() {
            return
        } else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
struct UserInfoFormExample: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var loadId = UUID()
    
    @State
    private var isLoading = false
    
    @FocusState
    private var formField: UserInfoFormModel.Field?
    
    @Bindable
    private var formModel: UserInfoFormModel
    
    init(formModel: UserInfoFormModel) {
        self._formModel = Bindable(formModel)
    }
    
    var body: some View {
        Form {
            personalInfoSection
                .disabled(isLoading)
            
            ageSection
                .disabled(isLoading)
            
            submitSection
                .disabled(isLoading)
        }
        .navigationTitle("Edit Profile")
        .toolbarTitleDisplayMode(.inline)
        .toast(isPresented: $isLoading, alignment: .center) {
            Toast(role: .informational) {
                Label {
                    Text("Loading...")
                } icon: {
                    ProgressView()
                        .scaleEffect(2)
                        .frame(width: 56, height: 56)
                }
            }
        }
        .toastInteractiveDismissDisabled(true)
        .refreshable {
            loadId = UUID()
        }
        .task(id: loadId) { schedule in
            isLoading = true
            defer {
                isLoading = false
            }
            
            do {
                try await formModel.load()
                formField = .firstName
            } catch {
                schedule(
                    toast: Toast(role: .failure, duration: .longer) {
                        HStack(spacing: 32) {
                            Label(
                                "Failed to load profile.",
                                systemImage: "xmark.circle.fill"
                            )
                            
                            Button("Retry", systemImage: "arrow.trianglehead.clockwise") {
                                loadId = UUID()
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                )
            }
        }
    }
    
    private var personalInfoSection: some View {
        Section("Personal Info") {
            TextField("First Name", text: $formModel.firstName)
                .focused($formField, equals: .firstName)
                .onSubmit {
                    formField = formModel.submitted(
                        field: .firstName
                    )
                }
            
            TextField("Middle Name", text: $formModel.middleName)
                .focused($formField, equals: .middleName)
                .onSubmit {
                    formField = formModel.submitted(
                        field: .middleName
                    )
                }
            
            TextField("Last Name", text: $formModel.lastName)
                .focused($formField, equals: .lastName)
                .onSubmit {
                    formField = formModel.submitted(
                        field: .lastName
                    )
                }
        }
    }
    
    private var ageSection: some View {
        Section {
            Stepper(
                value: $formModel.age,
                in: 12...120,
                step: 1
            ) {
                TextField(
                    "Age",
                    text: Binding<String> {
                        guard formModel.age > 0 else {
                            return ""
                        }
                        
                        return formModel.age.description
                    } set: { newValue in
                        formModel.age = Int(newValue) ?? formModel.age
                    }
                )
                .fixedSize(horizontal: true, vertical: false)
                .focused($formField, equals: .age)
            } onEditingChanged: { isPressed in
                guard !isPressed else { return }
                formField = formModel.submitted(
                    field: .age
                )
            }
            .onSubmit {
                formField = formModel.submitted(
                    field: .age
                )
            }
        } header: {
            Text("Age")
        } footer: {
            Text("Only user between ages 12 and 120 can use the app")
        }
    }
    
    private var submitSection: some View {
        Section {
            ToastButton("Submit") { schedule in
                isLoading = true
                Task {
                    defer {
                        isLoading = false
                    }
                    
                    do {
                        try await formModel.save()
                        schedule(
                            toast: Toast(
                                "Profile saved.",
                                systemImage: "checkmark.circle.fill",
                                role: .success
                            )
                        )
                        
                        dismiss()
                    } catch {
                        schedule(
                            toast: Toast(
                                "Something went wrong.",
                                systemImage: "xmark.circle.fill",
                                role: .failure
                            )
                        )
                    }
                }
            }
            .focusable()
            .focused($formField, equals: .submit)
            .keyboardShortcut(
                formField == .submit ? .defaultAction : nil
            )
            .toastInteractiveDismissDisabled(false)
            .toastCancellation(.never)
        }
    }
}

#Preview {
    PresentedPreview {
        ZStack {
            if #available(iOS 17.0, macOS 14.0, *) {
                UserInfoFormExample(
                    formModel: UserInfoFormModel()
                )
            }
        }
    }
    .frame(maxWidth: 428)
}

#endif
