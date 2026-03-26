//
//  KakuroMainMenu.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI

struct KakuroMainMenu: View {
    @State private var isPulsing: Bool = false
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var gameTracker: GameSession
    
    var body: some View {
        NavigationStack {
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(height: 600)
                
               
                VStack{
                    
                    Spacer()
                        .frame(height: 100)
                    Text("Welcome to Kakuro")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                        .frame(height: 100)
               
                    NavigationLink(destination: DifficultyMenu()) {
                       PulsingMenuButton(title: "Start Game", isPulsing: isPulsing)
                    }.buttonStyle(.plain)
                    
                    
                    
                    NavigationLink(destination: HowToPlay())
                    {
                        PulsingMenuButton(title: "How to Play", isPulsing: isPulsing)
                    }.buttonStyle(.plain)
                    
                    
                    
                    
                    
                    if gameTracker.isGuestMode {
                        PulsingMenuButton(title: "My Stats (Login required)", isPulsing: isPulsing)
                            .opacity(0.5)
                    } else {
                        NavigationLink(destination: MyStats()) {
                            PulsingMenuButton(title: "My Stats", isPulsing: isPulsing)
                        }
                        .buttonStyle(.plain)
                    }
                       
                    
                    
                    NavigationLink(destination: MySettings())
                    {
                        PulsingMenuButton(title: "Settings", isPulsing: isPulsing)
                    }.buttonStyle(.plain)
                    
                        
                    
                    Spacer()
                    
                    
                    
                    if !gameTracker.isGuestMode {
                        Button {
                            firebaseManager.signOut()
                            gameTracker.setGuestMode(true)
                        } label: {
                            Text("Logout")
                                .foregroundStyle(.white)
                                .font(.caption.bold())
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.red)
                                }
                        }
                    }
                    
                    
                }
//                .onAppear {
//                    if !isPulsing {
//                           isPulsing = true
//                       }
//            }
                
                
            }
           
            //END OF ZSTACK
           
            
           
            
        }.padding() //end of NavigationStack
        
    }
}




#Preview {
    KakuroMainMenu()
}
