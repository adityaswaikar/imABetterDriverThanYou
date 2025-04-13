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
    @State private var isMonitoringActive = false
    @ObservedObject var scoreManager = ScoreManager.shared
    
    
    var body: some View {
        TabView {
            // Tab 1: Home (Braking Screen)
            NavigationStack {
                Toggle(isOn: $isMonitoringActive) {
                        HStack {
                            Image(systemName: "car.fill")
                            Text("Driving Mode")
                                .font(.headline)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding()
                
                if(isMonitoringActive) {
                    Braking(isActive: $isMonitoringActive)
                    Text("This is working")
                } else {
                    VStack {
                        
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Driving mode is off")
                            .foregroundColor(.secondary)
                        }
                    
                    Text("All Time: \(scoreManager.allTimeScore)")
                        .font(.system(size: 40, weight: .bold))
                        .padding()
                    
                    .padding(.top, 40)
                }
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

