import Foundation
import CoreLocation

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var sessions: [DrivingSession] = []
    @Published var currentSession: DrivingSessionBuilder?
    
    private let sessionsKey = "DrivingSessions"
    
    init() {
        loadSessions()
    }
    
    // Start a new driving session
    func startSession() {
        currentSession = DrivingSessionBuilder()
    }
    
    // End the current session and save it
    func endSession() {
        guard let builder = currentSession else { return }
        
        let session = builder.build()
        
        // Only add session if it meets minimum duration requirement (5 minutes)
        let minimumDuration: TimeInterval = 300 // 5 minutes
        if session.duration >= minimumDuration {
            sessions.append(session)
            saveSessions()
            
            // Update scores in ScoreManager based on new session data
            ScoreManager.shared.updateScoresFromSessions()
        } else {
            print("Session discarded - duration less than 5 minutes: \(Int(session.duration / 60)) minutes")
        }
        
        currentSession = nil
    }
    
    // Record a hard braking event
    func recordHardBraking() {
        currentSession?.hardBrakingCount += 1
    }
    
    // Update current speed
    func updateSpeed(_ speed: Double) {
        currentSession?.updateSpeed(speed)
    }
    
    // Update location
    func updateLocation(_ location: CLLocation) {
        currentSession?.updateLocation(location)
    }
    
    // Record speeding
    func recordSpeeding(duration: TimeInterval) {
        currentSession?.speedingDuration += duration
    }
    
    // Save sessions to UserDefaults
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    // Load sessions from UserDefaults
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([DrivingSession].self, from: data) {
            sessions = decoded
        }
    }
    
    // Add test data - for development only
    func addTestSessions() {
        sessions.append(DrivingSession(
            date: Date().addingTimeInterval(-86400), // Yesterday
            score: 85,
            duration: 1800, // 30 minutes
            averageSpeed: 42.5,
            maxSpeed: 65.0,
            hardBrakingCount: 1,
            speedingDuration: 120, // 2 minutes
            startLocation: nil,
            endLocation: nil
        ))
        
        sessions.append(DrivingSession(
            date: Date().addingTimeInterval(-172800), // 2 days ago
            score: 70,
            duration: 2400, // 40 minutes
            averageSpeed: 38.2,
            maxSpeed: 72.0,
            hardBrakingCount: 3,
            speedingDuration: 360, // 6 minutes
            startLocation: nil,
            endLocation: nil
        ))
        
        sessions.append(DrivingSession(
            date: Date().addingTimeInterval(-345600), // 4 days ago
            score: 92,
            duration: 3600, // 60 minutes
            averageSpeed: 35.0,
            maxSpeed: 55.0,
            hardBrakingCount: 0,
            speedingDuration: 0,
            startLocation: nil,
            endLocation: nil
        ))
        
        saveSessions()
    }
}

// Helper class to build a driving session
class DrivingSessionBuilder {
    let startDate = Date()
    var hardBrakingCount = 0
    var speedingDuration: TimeInterval = 0
    var speeds: [Double] = []
    var startLocation: CLLocation?
    var endLocation: CLLocation?
    
    func updateSpeed(_ speed: Double) {
        speeds.append(speed)
    }
    
    func updateLocation(_ location: CLLocation) {
        if startLocation == nil {
            startLocation = location
        }
        endLocation = location
    }
    
    func build() -> DrivingSession {
        let endDate = Date()
        let duration = endDate.timeIntervalSince(startDate)
        
        // Calculate score based on driving metrics
        let maxScore = 100
        let brakingPenalty = hardBrakingCount * 5
        let speedingPenalty = Int(speedingDuration / 60) * 2
        let score = max(0, maxScore - brakingPenalty - speedingPenalty)
        
        return DrivingSession(
            date: startDate,
            score: score,
            duration: duration,
            averageSpeed: speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count),
            maxSpeed: speeds.max() ?? 0,
            hardBrakingCount: hardBrakingCount,
            speedingDuration: speedingDuration,
            startLocation: startLocation != nil ? DrivingSession.LocationCoordinate(from: startLocation!) : nil,
            endLocation: endLocation != nil ? DrivingSession.LocationCoordinate(from: endLocation!) : nil
        )
    }
}