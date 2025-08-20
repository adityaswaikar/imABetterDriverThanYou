//
//  ScoringView.swift
//  im a better driver than you
//
//  Created by Parth Sampat on 4/11/25.
//

import SwiftUI

struct ScoringView: View {
    @ObservedObject var scoreManager = ScoreManager.shared
    @State private var showingTips = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Driver Score")
                    .font(AppTheme.TextStyle.header)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Score Card
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .trim(from: 0, to: min(CGFloat(scoreManager.allTimeScore) / 100, 1.0))
                            .stroke(scoreColor(for: scoreManager.allTimeScore), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .overlay(
                                Text("\(scoreManager.allTimeScore)")
                                    .font(.system(size: 32, weight: .bold))
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("All-Time Score")
                                .font(AppTheme.TextStyle.title)
                            
                            Text(scoreRating(for: scoreManager.allTimeScore))
                                .font(AppTheme.TextStyle.body)
                                .foregroundColor(scoreColor(for: scoreManager.allTimeScore))
                        }
                        .padding(.leading, 20)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Driving Tips
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: {
                        withAnimation {
                            showingTips.toggle()
                        }
                    }) {
                        HStack {
                            Text("Improve Your Score")
                                .font(AppTheme.TextStyle.title)
                            
                            Spacer()
                            
                            Image(systemName: showingTips ? "chevron.up" : "chevron.down")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if showingTips {
                        VStack(alignment: .leading, spacing: 12) {
                            tipRow(icon: "hand.raised.fill", title: "Avoid Hard Braking", description: "Gradually slow down instead of slamming the brakes.")
                            
                            tipRow(icon: "speedometer", title: "Follow Speed Limits", description: "Stay within posted speed limits for safety.")
                            
                            tipRow(icon: "timer", title: "Drive Consistently", description: "Maintain steady speeds and avoid rapid acceleration.")
                            
                            tipRow(icon: "bell.slash", title: "Avoid Distractions", description: "Never use your phone while driving.")
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Debug button (remove in production)
                Button("Add Points") {
                    scoreManager.addScore(points: 5)
                }
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primary)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(AppTheme.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
        }
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
    
    private func scoreRating(for score: Int) -> String {
        switch score {
        case ..<40:
            return "Needs Improvement"
        case 40..<70:
            return "Good Driver"
        case 70..<90:
            return "Great Driver"
        default:
            return "Excellent Driver"
        }
    }
}

#Preview {
    ScoringView()
}
