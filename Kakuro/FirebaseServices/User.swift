//
//  User.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-15.
//

import Foundation


struct User: Codable, Identifiable {
    let id: UUID
    let name: String
    let email: String

    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
