//
//  SpecialButtons.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-05.
//

import SwiftUI

struct SpecialButtons: View {
    @EnvironmentObject var gameTracker: GameTracker
    var body: some View {
        VStack{
            Button{
                gameTracker.removeValue()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
                    
            }
            
            
            
            
        }
        .padding()
    }
}

#Preview {
    SpecialButtons()
        .environmentObject(GameTracker())
}
