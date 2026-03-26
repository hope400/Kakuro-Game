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

class FirebaseManager: ObservableObject {
    
    lazy var db = Firestore.firestore()
    static let shared = FirebaseManager()
    @Published var user: FirebaseAuth.User?
    
    
    
//     init() {
//         self.user = Auth.auth().currentUser
//     }
//
    
    
    func saveStatistics(_ stats: Statistics) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        try db.collection("users")
            .document(uid)
            .collection("statistics")
            .document("playerStats")
            .setData(from: stats, merge: true)
    }
    
    func loadStatistics(for difficulty: GameDifficulty) async throws -> Statistics {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "NoUser", code: 0)
        }

        let snapshot = try await db
            .collection("users")
            .document(uid)
            .collection("statistics")
            .document(difficulty.rawValue)   // easy / medium / hard
            .getDocument()

        guard let stats = try? snapshot.data(as: Statistics.self) else {
            return Statistics()
        }

        return stats
    }
    
    func fetchTemplate(
        difficulty: GameDifficulty,
        level: Int,
        completion: @escaping ([[Bool]]?) -> Void
    )
    {

        let docID = "\(difficulty.rawValue)_\(level)"

        db.collection("kakuro_templates")
            .document(docID)
            .getDocument { snapshot, error in

                guard
                    let data = snapshot?.data(),
                    let gridMap = data["grid"] as? [String: [Int]]
                else {
                    completion(nil)
                    return
                }

                // Sort rows (row0, row1, row2...)
                let sortedRows = gridMap.sorted { lhs, rhs in
                    let lhsIndex = Int(lhs.key.replacingOccurrences(of: "row", with: "")) ?? 0
                    let rhsIndex = Int(rhs.key.replacingOccurrences(of: "row", with: "")) ?? 0
                    return lhsIndex < rhsIndex
                }

                let grid: [[Bool]] = sortedRows.map { _, row in
                    row.map { $0 == 1 }
                }

                completion(grid)
            }
    }
    
    
    
    // MARK: - Sign Up
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
    
    
 
    
    func uploadAllTemplates() {


        func upload(difficulty: String, templates: [Int: [[Bool]]]) {

            for (level, grid) in templates {

                // convert Bool grid -> Int grid
                let intGrid = grid.map { row in
                    row.map { $0 ? 1 : 0 }
                }

                // convert rows into the Firestore map format
                var gridMap: [String: [Int]] = [:]

                for (index, row) in intGrid.enumerated() {
                    gridMap["row\(index)"] = row
                }

                let data: [String: Any] = [
                    "difficulty": difficulty,
                    "level": level,
                    "size": grid.count,
                    "grid": gridMap
                ]

                db.collection("kakuro_templates")
                    .document("\(difficulty)_\(level)")
                    .setData(data)

                print("Uploaded \(difficulty)_\(level)")
            }
        }

        upload(difficulty: "easy", templates: KakuroTemplates.easy5x5)
        upload(difficulty: "easy", templates: KakuroTemplates.easy6x6)

        upload(difficulty: "medium", templates: KakuroTemplates.medium8x8)
        upload(difficulty: "medium", templates: KakuroTemplates.medium10x10)

        upload(difficulty: "hard", templates: KakuroTemplates.hard12x12)
        upload(difficulty: "hard", templates: KakuroTemplates.hard15x15)
    }
    
    
   
    
}
