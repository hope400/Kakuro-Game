//
//  Numpad.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-05.
//

import SwiftUI

struct Numpad: View {
    @EnvironmentObject var gameTracker: GameTracker
 
    var body: some View {
        let allowed = gameTracker.allowedNumbers()
        VStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(1 + row * 3 ... 3 + row * 3, id: \.self) { digit in
                        Button {
                            // handle digit tap
                            gameTracker.setValue(digit)
                        } label: {
                            Text("\(digit)")
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue)
                                )
                        }
                    }
                }
                
                
            }
            
            
        }
    }
}


#Preview {
    Numpad()
        .environmentObject(GameTracker())
}
