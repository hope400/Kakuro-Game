//
//  SpecialButtons.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-05.
//

import SwiftUI
import Combine

struct SpecialButtons: View {
    @EnvironmentObject var gameTracker: GameSession

    var body: some View {
        VStack {

            Button {
                gameTracker.undoEntry()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
            }
            .disabled(!gameTracker.canUndo())

            Button {
                gameTracker.redoEntry()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
            }
            .disabled(!gameTracker.canRedo())
        }
        .padding()
    }
}




#Preview {
    SpecialButtons()
        .environmentObject(GameSession())
}
