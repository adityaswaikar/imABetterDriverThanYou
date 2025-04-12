//
//  ScoringView.swift
//  im a better driver than you
//
//  Created by Parth Sampat on 4/11/25.
//

import SwiftUI

struct ScoringView: View {
    @ObservedObject var scoreManager = ScoreManager.shared
    
    // @StateObject var scoreManager = ScoreManager()
    var body: some View {
        Text("Score: \(scoreManager.currentScore)")
            .font(.system(size: 40, weight: .bold))
            .padding()
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            
            Button ("Tap me") {
                scoreManager.addScore(points: 1)
            }
        }
        .padding()
    }
}

#Preview {
    ScoringView()
}
