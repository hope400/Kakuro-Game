//
//  FirebaseManager.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-15.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore



// FirebaseManager is responsible for handling authentication.
// In simple terms, this class manages:
//
// - creating accounts
// - signing users in
// - signing users out
// - keeping track of the currently logged-in user
//
// The rest of the app watches this object to know
// whether a user is logged in or not.
class FirebaseManager: ObservableObject {
    
    private let db = Firestore.firestore()
    
    // A single shared instance used across the entire app.
    // This avoids creating multiple authentication managers.
    static let shared = FirebaseManager()
    
    // The currently logged-in user.
    // When this changes, SwiftUI automatically updates the UI.
    @Published var user: FirebaseAuth.User?
    
    
    // MARK: - Persistent Login (Optional)
    // Firebase remembers users between app launches.
    // If enabled, this restores the previous user automatically.
    //
    // init() {
    //     self.user = Auth.auth().currentUser
    // }
    
    
    // MARK: - Sign Up
    // Creates a new account using email and password.
    //
    // If successful:
    // - Firebase automatically signs the user in
    // - we store the user so the app can move forward
    //
    // If something fails:
    // - we print the error for debugging
    func signUp(email: String, password: String, username: String) async throws {

        // Create the authentication account
        let result = try await Auth.auth()
            .createUser(withEmail: email, password: password)

        let user = result.user
        let uid = user.uid

        // Create the user document in Firestore
        try await db.collection("users").document(uid).setData([
            "email": email,
            "username": username
        ])

        // Update app state on the main thread
        await MainActor.run {
            self.user = user
        }
    }
    
    
    // MARK: - Sign In
    // Logs in an existing user.
    //
    // This version uses async/await so errors can be passed
    // back to the screen that called it.
    //
    // If login succeeds:
    // - the current user is updated
    // - the app automatically switches to the main screen
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth()
            .signIn(withEmail: email, password: password)

        // Update user on the main thread so UI refreshes safely.
        await MainActor.run {
            self.user = result.user
        }
    }
    
    
    func usernameExists(_ username: String) async throws -> Bool {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()

        return !snapshot.documents.isEmpty
    }
    
    
    
    // MARK: - Sign Out
    // Logs the current user out.
    //
    // After signing out:
    // - user becomes nil
    // - the app returns to the login screen automatically
    func signOut() {
        do {
            try Auth.auth().signOut()

            DispatchQueue.main.async {
                self.user = nil
            }

        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}
