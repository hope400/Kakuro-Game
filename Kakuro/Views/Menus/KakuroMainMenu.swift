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
                    
                    
                    
                    
                    
                    NavigationLink(destination: MyStats())
                    {
                        PulsingMenuButton(title: "My Stats", isPulsing: isPulsing)
                    }.buttonStyle(.plain)
                       
                    
                    
                    NavigationLink(destination: MySettings())
                    {
                        PulsingMenuButton(title: "Settings", isPulsing: isPulsing)
                    }.buttonStyle(.plain)
                    
                        
                    
                    Spacer()
                    
                    //logout button
//                    Button {
//                        firebaseManager.signOut()
//                    } label: {
//                        Text("Logout")
//                            .foregroundStyle(.white)
//                            .font(Font.caption.bold())
//                            .padding()
//                            .background{
//                                RoundedRectangle(cornerRadius: 15)
//                                    .foregroundStyle(.red)
//                            }
//                            
//                    }
                    
                    
                }
//                .onAppear {
//                    if !isPulsing {
//                           isPulsing = true
//                       }
//            }
                
                
            }
            .navigationBarBackButtonHidden(true)
            //END OF ZSTACK
           
            
           
            
        }.padding() //end of NavigationStack
        
    }
}




#Preview {
    KakuroMainMenu()
}
