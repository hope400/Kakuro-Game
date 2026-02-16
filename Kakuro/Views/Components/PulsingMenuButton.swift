//
//  PulsingMenuButton.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//
import SwiftUI

struct PulsingMenuButton: View {
    let title: String
    let isPulsing: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue)
                .scaleEffect(isPulsing ? 1.08 : 1.0)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(width: 200, height: 55)
        .contentShape(Rectangle()) // 🔑 aligns hitbox with visuals
        .animation(
            .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
            value: isPulsing
        )
    }
}



