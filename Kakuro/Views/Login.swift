//
//  LoginView.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-09.
//

import SwiftUI

// LoginView is the first screen users see.
// It allows users to either:
// - log into an existing account
// - create a new account
// - or continue as a guest
//
// This view only handles user input and validation.
// Actual login and signup work is handled by FirebaseManager.
struct LoginView: View {

    // Determines whether the screen is in Login or Sign Up mode.
    // The UI changes depending on this value.
    enum AuthMode: String, CaseIterable {
        case login = "Login"
        case signup = "Sign Up"
    }
    
    // Access to the shared authentication manager.
    // This lets us call sign in and sign up functions.
    @EnvironmentObject var firebaseManager: FirebaseManager

    // MARK: - Auth Mode
    @State private var authMode: AuthMode = .login

    // MARK: - Login Input
    @State private var email: String = ""
    @State private var password: String = ""

    // MARK: - Sign Up Input
    @State private var confirmPassword: String = ""
    @State private var username: String = ""

    // Message shown when something goes wrong
    @State private var errorMessage: String = ""

    // Used only for guest navigation
    @State private var asGuest: Bool = false
    
    @FocusState private var focusedField: Field?
    @State private var usernameCheckTask: Task<Void, Never>?
    @State private var passwordStrength: String = ""
    @State private var passwordsMatch = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Spacer()

                // App title
                Text("Kakuro")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Switch between Login and Sign Up
                Picker("", selection: $authMode) {
                    ForEach(AuthMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Input Fields
                VStack(spacing: 12) {

                    // Username only appears during sign up
                    if authMode == .signup {
                        TextField("Username", text: $username)
                            .focused($focusedField, equals: .username)
                            .onChange(of: username) { newValue in
                                    validateUsernameLive(newValue)
                                }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Email input
                    TextField("Email", text: $email)
                        .focused($focusedField, equals: .email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: email) { newValue in
                            validateEmailLive(newValue)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Password input
                    // iOS is told whether this is a new password or existing one
                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .password)
                        .onChange(of: password) { newValue in
                            checkPasswordStrength(newValue)
                        }
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    if authMode == .signup {
                    Text("Password Status : \(passwordStrength)")
                    }
                    
                    // Confirm password only during sign up
                    if authMode == .signup {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .focused($focusedField, equals: .confirmPassword)
                            .onChange(of: confirmPassword) { _ in
                                comparePasswords()
                            }
                            .textContentType(.oneTimeCode)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Error message shown when validation or login fails
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - Main Action Button
                Button {
                    if authMode == .login {
                        validateLogin(email: email, password: password)
                    } else {
                        validateSignup(
                            username: username,
                            email: email,
                            password: password,
                            confirmPassword: confirmPassword
                        )
                    }
                } label: {
                    Text(authMode == .login ? "Log In" : "Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                // MARK: - Guest Access
                // Allows entering the game without creating an account
                Button {
                    asGuest.toggle()
                } label: {
                    Text("Play as guest")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .underline()
                }

                Spacer()

                // Navigation for guest mode only
                NavigationLink(
                    destination: KakuroMainMenu(),
                    isActive: $asGuest
                ) {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    // MARK: - Sign Up Validation
    // Checks user input before attempting to create an account.
    // Prevents unnecessary network calls if something is clearly wrong.
    func validateSignup(username: String,
                        email: String,
                        password: String,
                        confirmPassword: String)
    {
        
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }

        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }

        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email."
            return
        }

        errorMessage = ""

        Task {
            do {
                try await firebaseManager.signUp(
                    email: email,
                    password: password,
                    username: username
                )
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func comparePasswords() {
    
        passwordsMatch = (password == confirmPassword)
        errorMessage = !passwordsMatch ? "Passwords do not match." : ""
    }
    
    private func checkPasswordStrength(_ password: String) {

        if password.isEmpty {
            passwordStrength = ""
            return
        }

        if password.count < 6 {
            passwordStrength = "Too short"
            return
        }

        if password.range(of: "[0-9]", options: .regularExpression) != nil {
            passwordStrength = "Good password"
        } else {
            passwordStrength = "Add a number"
        }
    }
    
    private func validateUsernameLive(_ username: String) {

        // cancel previous check if user keeps typing
        usernameCheckTask?.cancel()

        // do not check empty usernames
        guard !username.isEmpty else {
            errorMessage = ""
            return
        }

        usernameCheckTask = Task {
            // wait before checking (user finished typing)
            try? await Task.sleep(nanoseconds: 600_000_000)

            // if cancelled, stop here
            if Task.isCancelled { return }

            do {
                let exists = try await firebaseManager.usernameExists(username)

                await MainActor.run {
                    if exists {
                        errorMessage = "Username already taken."
                    } else {
                        errorMessage = ""
                    }
                }
            } catch {
                // silently ignore or show generic error
            }
        }
    }

    // MARK: - Login Validation
    // Ensures fields are filled before attempting login.
    func validateLogin(email: String, password: String) {

        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }

        errorMessage = ""

        Task {
            do {
                try await firebaseManager.signIn(email: email, password: password)
            } catch {
                await MainActor.run {
                    errorMessage = "Email or password is incorrect."
                }
            }
        }
    }
    
    // Validates email while the user is typing.
    // Shows an error only when the format is clearly invalid.
    private func validateEmailLive(_ email: String) {

        // Do not show errors for empty input
        if email.isEmpty {
            errorMessage = ""
            return
        }

        // Avoid showing errors too early while typing
        if email.contains("@") && !isValidEmail(email) {
            errorMessage = "Invalid email format"
        } else {
            errorMessage = ""
        }
    }
    

    // MARK: - Email Validation
    // Simple format check to catch obvious mistakes.
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}


enum Field {
    case email
    case password
    case username
    case confirmPassword
}

#Preview {
    LoginView()
}
