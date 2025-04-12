//
//  scoring.swift
//  im a better driver than you
//
//  Created by Parth Sampat on 4/11/25.
//

import Foundation

class ScoreManager: ObservableObject {
    @Published var currentScore: Int = 0 {
           didSet {
               UserDefaults.standard.set(currentScore, forKey: "savedScore")
           }
       }
    
    init() {
            self.currentScore = UserDefaults.standard.integer(forKey: "savedScore")
        }
    
    func addScore(points : Int){
        currentScore += points
    }
}
