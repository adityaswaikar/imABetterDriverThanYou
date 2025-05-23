//
//  MainTabView.swift
//  im a better driver than you
//
//  Created by Aaryan Jadhav on 4/12/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var isMonitoringActive = false
    @ObservedObject var scoreManager = ScoreManager.shared
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 0) {
                    // Custom toggle for driving mode
                    HStack {
                        Image(systemName: isMonitoringActive ? "car.fill" : "car")
                            .font(.system(size: 22))
                            .foregroundColor(isMonitoringActive ? .white : .primary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(isMonitoringActive ? AppTheme.success : Color(UIColor.tertiarySystemBackground))
                            )
                        
                        Text("Driving Mode")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isMonitoringActive)
                            .toggleStyle(SwitchToggleStyle(tint: AppTheme.success))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if isMonitoringActive {
                        Braking(isActive: $isMonitoringActive)
                    } else {
                        VStack(spacing: 30) {
                            // Illustration
                            ZStack {
                                Circle()
                                    .fill(Color(UIColor.tertiarySystemBackground))
                                    .frame(width: 180, height: 180)
                                
                                Image(systemName: "car.2.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(Color.secondary)
                            }
                            .padding(.top, 40)
                            
                            // Status text
                            Text("Driving mode is off")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            // All time score card
                            VStack(spacing: 8) {
                                Text("All-Time Score")
                                    .font(AppTheme.TextStyle.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(scoreManager.allTimeScore)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(scoreColor(for: scoreManager.allTimeScore))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal, 40)
                            
                            // Instructions
                            Text("Toggle driving mode on when you start your trip to track your driving and improve your score.")
                                .font(AppTheme.TextStyle.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 20)
                            
                            Spacer()
                        }
                        .padding(.top, 20)
                    }
                }
                .navigationTitle("I'm a Better Driver")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Drive", systemImage: "car.fill")
            }
            
            NavigationStack {
                ScoringView()
                    .navigationTitle("My Score")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Score", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                HistoryView()
                    .navigationTitle("Driving History")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
        }
        .accentColor(AppTheme.primary)
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case ..<40:
            return AppTheme.danger
        case 40..<70:
            return AppTheme.warning
        default:
            return AppTheme.success
        }
    }
}

#Preview {
    MainTabView()
}

