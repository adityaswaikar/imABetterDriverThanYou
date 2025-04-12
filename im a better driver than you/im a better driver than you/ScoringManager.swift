//
//  scoring.swift
//  im a better driver than you
//
//  Created by Parth Sampat on 4/11/25.
//

import Foundation

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    @Published var allTimeScore: Int = 0 {
           didSet {
               UserDefaults.standard.set(allTimeScore, forKey: "savedScore")
           }
       }
    
     init() {
            self.allTimeScore = UserDefaults.standard.integer(forKey: "savedScore")
        }
    
    func addScore(points : Int){
        allTimeScore += points
    }
}
