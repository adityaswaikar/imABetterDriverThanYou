//
//  MainTabView.swift
//  im a better driver than you
//
//  Created by Aaryan Jadhav on 4/12/25.
//

import SwiftUI


struct HomeScreen: View {
    var body: some View {
        Text("Home Tab")
    }
}

struct YourScoreScreen: View {
    var body: some View {
        Text("Your Score")
    }
}


struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: Home (Braking Screen)
            NavigationStack {
                Braking()
            }
            .tabItem {
                Label("Home", systemImage: "car.fill")
            }

            // Tab 2: Scoring
            NavigationStack {
                ScoringView()
            }
            .tabItem {
                Label("Scoring", systemImage: "chart.bar.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
}

