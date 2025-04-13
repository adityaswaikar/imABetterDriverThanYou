import Foundation
import CoreLocation

struct DrivingSession: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let score: Int
    let duration: TimeInterval
    let averageSpeed: Double
    let maxSpeed: Double
    let hardBrakingCount: Int
    let speedingDuration: TimeInterval
    let startLocation: LocationCoordinate?
    let endLocation: LocationCoordinate?
    
    // Simplified location storage for Codable support
    struct LocationCoordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        init(from location: CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}