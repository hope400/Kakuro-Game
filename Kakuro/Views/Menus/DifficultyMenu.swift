//
//  DifficultyMenu.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI

struct DifficultyMenu: View {
    @State private var isPulsing: Bool = false
    @EnvironmentObject var gameTracker: GameTracker
    var body: some View {
        NavigationStack {
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(height: 600)
                
                
                VStack{
                    
                    Spacer()
                        .frame(height: 100)
                    Text("Choose a difficulty")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                        .frame(height: 100)
                    
                    NavigationLink(destination: EasyLevels()) {
                        PulsingMenuButton(title: "Easy", isPulsing: isPulsing)
                        
                        
                        
                        
                    }.simultaneousGesture(
                        TapGesture().onEnded {
                            gameTracker.setDifficulty(.easy)

                        }
                    )
                    .buttonStyle(.plain)
                    
                    
                    
                    NavigationLink(destination: Mediumlevels())
                    {
                        PulsingMenuButton(title: "Medium", isPulsing: isPulsing)
                    }.simultaneousGesture(
                        TapGesture().onEnded {
                            gameTracker.setDifficulty(.medium)

                        }
                    )
                    .buttonStyle(.plain)
                    
                    
                    
                    
                    NavigationLink(destination: HardLevels())
                    {
                        PulsingMenuButton(title: "Hard", isPulsing: isPulsing)
                    }.simultaneousGesture(
                        TapGesture().onEnded {
                            gameTracker.setDifficulty(.hard)

                        }
                    )
                    .buttonStyle(.plain)
                    
                    
                    
                    
                    
                    Spacer()
                    
                    
                } .onAppear {
                    if !isPulsing {
                           isPulsing = true
                       }
            }
                
                
            }//END OF ZSTACK
            
           
            
        }.padding() //end of NavigationStack
    }
}





#Preview {
    DifficultyMenu()
}
