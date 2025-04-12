//
//  SpeedLimitManager.swift
//  im a better driver than you
//
//  Created on 4/12/25.
//

import Foundation
import CoreLocation

// Structure to parse Mapbox speed limit data
struct MapboxSpeedLimit {
    let speed: Double
    let unit: String
    
    // Convert to miles per hour for display
    var speedInMPH: Double {
        if unit.lowercased() == "km/h" {
            
            let mphValue = speed * 0.621371 // Convert km/h to mph
            return round(mphValue / 5) * 5 // Round to nearest 5 mph

        } else {
            return speed // Already in mph
        }
    }
    
    var formattedString: String {
        return "\(Int(speedInMPH)) mph"
    }
}

class SpeedLimitManager: NSObject, ObservableObject {
    @Published var currentSpeedLimit: MapboxSpeedLimit?
    @Published var speedLimitString: String = "Unknown"
    
    // Mapbox access token from Info.plist
    private var accessToken: String {
        guard let path = Bundle.main.path(forResource: "im-a-better-driver-than-you-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let token = dict["MBXAccessToken"] as? String else {
            return "pk.eyJ1Ijoic3VtZWRoa2FuZSIsImEiOiJjbTllZzI4NzkxYXk5Mm5vZHQ0N3NlYmc3In0.29JutwNTWzi_QxQQV8nsNA" // Use a default or fallback token
        }
        return token
    }
    
    override init() {
        super.init()
        print("SpeedLimitManager initialized with token: \(accessToken)")
    }
    
    func getCurrentSpeedLimit(for location: CLLocation) {
        // Create a destination point a short distance from the current location
        let currentCoordinate = location.coordinate
        let destinationCoordinate = CLLocationCoordinate2D(
            latitude: currentCoordinate.latitude + 0.001, 
            longitude: currentCoordinate.longitude + 0.001
        )
        
        // Format URL for Mapbox Directions API request
        let urlString = "https://api.mapbox.com/directions/v5/mapbox/driving/\(currentCoordinate.longitude),\(currentCoordinate.latitude);\(destinationCoordinate.longitude),\(destinationCoordinate.latitude)?annotations=maxspeed&overview=full&access_token=\(accessToken)"
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        
        // Create and start the network request
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching speed limit: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.speedLimitString = "Unknown"
                }
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                DispatchQueue.main.async {
                    self.speedLimitString = "Unknown"
                }
                return
            }
            
            // Parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let firstRoute = routes.first,
                   let legs = firstRoute["legs"] as? [[String: Any]],
                   let firstLeg = legs.first,
                   let annotation = firstLeg["annotation"] as? [String: Any],
                   let maxspeeds = annotation["maxspeed"] as? [[String: Any]],
                   let firstMaxspeed = maxspeeds.first,
                   let speed = firstMaxspeed["speed"] as? Double,
                   let unit = firstMaxspeed["unit"] as? String {
                    
                    let speedLimit = MapboxSpeedLimit(speed: speed, unit: unit)
                    
                    DispatchQueue.main.async {
                        self.currentSpeedLimit = speedLimit
                        self.speedLimitString = speedLimit.formattedString
                        print("Speed limit found: \(speedLimit.formattedString)")
                    }
                } else {
                    print("Error: Could not parse speed limit from response")
                    DispatchQueue.main.async {
                        self.speedLimitString = "Unknown"
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.speedLimitString = "Unknown"
                }
            }
        }
        
        task.resume()
    }
}

// Singleton instance for use throughout the app
let speedLimitManager = SpeedLimitManager()
