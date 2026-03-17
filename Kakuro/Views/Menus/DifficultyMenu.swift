//
//  DifficultyMenu.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI

struct DifficultyMenu: View {
    @State private var isPulsing: Bool = false
    @EnvironmentObject var gameTracker: GameSession
    @State private var showAccessAlert = false
    @State private var navigateToHard = false
    
    
    
    var body: some View {
        NavigationStack {

            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(height: 600)

                VStack {

                    Spacer().frame(height: 100)

                    Text("Choose a difficulty")
                        .font(.largeTitle)
                        .bold()

                    Spacer().frame(height: 100)

                    NavigationLink(destination: EasyLevels()) {
                        PulsingMenuButton(title: "Easy", isPulsing: isPulsing)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            gameTracker.setDifficulty(.easy)
                        }
                    )
                    .buttonStyle(.plain)

                    NavigationLink(destination: Mediumlevels()) {
                        PulsingMenuButton(title: "Medium", isPulsing: isPulsing)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            gameTracker.setDifficulty(.medium)
                        }
                    )
                    .buttonStyle(.plain)

                    Button {
                        let allowed = gameTracker.selectDifficulty(.hard)

                        if allowed {
                            navigateToHard = true
                        } else {
                            showAccessAlert = true
                        }

                    } label: {
                        PulsingMenuButton(title: "Hard", isPulsing: isPulsing)
                    }
                    .buttonStyle(.plain)
                    .alert("Login required", isPresented: $showAccessAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Hard difficulty requires a logged in account.")
                    }

                    Spacer()
                }
                .onAppear {
                    if !isPulsing {
                        isPulsing = true
                    }
                }
            }

        }
        .navigationDestination(isPresented: $navigateToHard) {
            HardLevels()
        }
        .padding() //end of NavigationStack
    }
}





#Preview {
    DifficultyMenu()
}
