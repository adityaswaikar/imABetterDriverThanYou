//
//  im_a_better_driver_than_youApp.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/11/25.
//

import SwiftUI

@main
struct im_a_better_driver_than_youApp: App {
    @StateObject private var scoreManager = ScoreManager() // To show the score across views (into the main view)
    var body: some Scene {
        WindowGroup {
            // ContentView()
            // ScoringView()
            // Braking()
            MainTabView().environmentObject(scoreManager)
        }
    }
}
