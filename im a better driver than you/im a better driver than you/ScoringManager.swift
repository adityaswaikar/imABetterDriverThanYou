//
//  scoring.swift
//  im a better driver than you
//
//  Created by Parth Sampat on 4/11/25.
//

import Foundation
import Combine

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    // Published properties that the UI can observe
    @Published var allTimeScore: Int = 100 {
        didSet {
            UserDefaults.standard.set(allTimeScore, forKey: "savedScore")
        }
    }
    
    @Published var recentScore: Int = 100
    @Published var percentileRank: Int = 50  // Default to 50th percentile
    @Published var scoreBreakdown: [ScoreComponent] = []
    
    // Constants for scoring system
    private let minimumDriveDuration: TimeInterval = 60 // 5 minutes = 300 seconds
    private let maxTimeWeight: TimeInterval = 30 * 24 * 60 * 60 // 30 days in seconds
    
    // Reference score distributions (these would ideally come from analytics)
    private let scoreDistribution: [Int: Int] = [
        0: 10,   // 10% of users score below 10
        10: 20,  // 20% of users score below 20
        20: 30,  // etc.
        30: 40,
        40: 50,
        50: 60,
        60: 70,
        70: 80,
        80: 90,
        90: 95,
        95: 100
    ]
    
    init() {
        self.allTimeScore = UserDefaults.standard.integer(forKey: "savedScore")
        if self.allTimeScore == 0 {
            self.allTimeScore = 100
            UserDefaults.standard.set(allTimeScore, forKey: "savedScore")
        }
        
        // Initialize with default breakdown
        updateScoreBreakdown(baseScore: 100, hardBrakingPenalty: 0, speedingPenalty: 0, consistencyBonus: 0)
        
        // Subscribe to session changes
        updateScoresFromSessions()
    }
    
    // Legacy method for backward compatibility
    func addScore(points: Int) {
        allTimeScore += points
    }
    
    // Calculate time-weighted average from all sessions
    func updateScoresFromSessions() {
        let sessions = SessionManager.shared.sessions
        
        // Filter out sessions that are too short
        let validSessions = sessions.filter { $0.duration >= minimumDriveDuration }
        
        if validSessions.isEmpty {
            return
        }
        
        // Sort sessions by date (oldest first)
        let sortedSessions = validSessions.sorted { $0.date < $1.date }
        
        // Calculate time-weighted scores
        var totalWeightedScore: Double = 0
        var totalWeight: Double = 0
        
        let now = Date()
        
        for session in sortedSessions {
            // Calculate weight based on recency (more recent = higher weight)
            let ageInSeconds = now.timeIntervalSince(session.date)
            let normalizedAge = min(ageInSeconds / maxTimeWeight, 1.0)
            let recencyFactor = 1.0 - normalizedAge
            
            // Also consider session duration as a weight factor (longer drives have more impact)
            let durationFactor = min(session.duration / 3600, 1.0) // Cap at 1 hour
            
            // Combined weight takes into account both recency and duration
            let weight = recencyFactor * (0.5 + (0.5 * durationFactor))
            
            totalWeightedScore += Double(session.score) * weight
            totalWeight += weight
        }
        
        // Calculate the weighted average
        if totalWeight > 0 {
            let weightedAverage = totalWeightedScore / totalWeight
            allTimeScore = Int(weightedAverage)
        }
        
        // Calculate recent score (last 5 sessions or fewer)
        if !sortedSessions.isEmpty {
            let recentSessions = Array(sortedSessions.suffix(min(5, sortedSessions.count)))
            let recentTotal = recentSessions.reduce(0) { $0 + $1.score }
            recentScore = recentTotal / recentSessions.count
        }
        
        // Update percentile rank
        updatePercentileRank()
        
        // Update score breakdown based on most recent session
        if let mostRecent = sortedSessions.last {
            // Retrieve the penalties from the most recent session
            let hardBrakingPenalty = mostRecent.hardBrakingCount * 5
            let speedingPenalty = Int(mostRecent.speedingDuration / 60) * 2
            
            // Calculate consistency bonus based on average vs max speed
            let consistencyRatio = mostRecent.averageSpeed / (mostRecent.maxSpeed > 0 ? mostRecent.maxSpeed : 1)
            let consistencyBonus = Int((consistencyRatio * 10).rounded())
            
            updateScoreBreakdown(
                baseScore: 100,
                hardBrakingPenalty: hardBrakingPenalty,
                speedingPenalty: speedingPenalty,
                consistencyBonus: consistencyBonus
            )
        }
    }
    
    private func updatePercentileRank() {
        // Find where the user's score falls in the distribution
        for (score, percentile) in scoreDistribution {
            if allTimeScore <= score {
                percentileRank = percentile
                break
            }
        }
        // If score is higher than all distribution points, they're in the top percentile
        if allTimeScore > (scoreDistribution.keys.max() ?? 0) {
            percentileRank = 99
        }
    }
    
    private func updateScoreBreakdown(baseScore: Int, hardBrakingPenalty: Int, speedingPenalty: Int, consistencyBonus: Int) {
        scoreBreakdown = [
            ScoreComponent(name: "Base Score", value: baseScore, isPositive: true),
            ScoreComponent(name: "Hard Braking", value: -hardBrakingPenalty, isPositive: false),
            ScoreComponent(name: "Speeding", value: -speedingPenalty, isPositive: false),
            ScoreComponent(name: "Consistency Bonus", value: consistencyBonus, isPositive: true)
        ]
    }
    
    // Score component for breakdown display
    struct ScoreComponent: Identifiable {
        var id = UUID()
        var name: String
        var value: Int
        var isPositive: Bool
        
        var formattedValue: String {
            return isPositive ? "+\(value)" : "\(value)"
        }
    }
}
