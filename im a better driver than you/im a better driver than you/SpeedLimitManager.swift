//
//  SpeedLimitManager.swift
//  im a better driver than you
//
//  Created on 4/12/25.
//

import Foundation
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class SpeedLimitManager: NSObject, ObservableObject {
    @Published var currentSpeedLimit: Measurement<UnitSpeed>?
    @Published var speedLimitString: String = "Unknown"
    
    private let directions = Directions.shared
    private let speedLimitFormatter = MeasurementFormatter()
    
    override init() {
        super.init()
        
        // Configure the measurement formatter for speed limits
        speedLimitFormatter.unitOptions = .providedUnit
        speedLimitFormatter.numberFormatter.maximumFractionDigits = 0
    }
    
    func getCurrentSpeedLimit(for location: CLLocation) {
        // Create route options with the current location and a destination point
        // We need at least two coordinates for the Directions API to return a valid route
        
        // Create a second coordinate point a short distance from the current location
        // This could be improved by using a meaningful destination if available
        let currentCoordinate = location.coordinate
        let destinationCoordinate = CLLocationCoordinate2D(
            latitude: currentCoordinate.latitude + 0.001, 
            longitude: currentCoordinate.longitude + 0.001
        )
        
        let routeOptions = RouteOptions(coordinates: [currentCoordinate, destinationCoordinate])
        // Set profile to driving to get road-related information including speed limits
        routeOptions.profileIdentifier = .automobileAvoidingTraffic
        
        // Using Mapbox Directions to get road information including speed limit
        directions.calculateRoutes(options: routeOptions) { [weak self] (session, result) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("Error getting speed limit: \(error.localizedDescription)")
                self.speedLimitString = "Unknown"
                
            case .success(let response):
                // Extract speed limit information from the response if available
                if let route = response.routes?.first,
                   let firstLeg = route.legs.first,
                   let speedLimit = firstLeg.segmentMaximumSpeedLimits?.first {
                    
                    self.currentSpeedLimit = speedLimit
                    
                    // Format the speed limit for display
                    if let speedLimit = self.currentSpeedLimit {
                        self.speedLimitFormatter.unitStyle = .short
                        self.speedLimitString = self.speedLimitFormatter.string(from: speedLimit)
                    } else {
                        self.speedLimitString = "Unknown"
                    }
                } else {
                    print("No speed limit information available in the response")
                    self.speedLimitString = "Unknown"
                }
            }
        }
        // No need to call resume() as the request auto-starts in newer versions
    }
    
    // Alternative approach using Mapbox Navigation's RouteController
    func startMonitoringSpeedLimits() {
        // This method would use NavigationViewController or RouteController 
        // to continuously monitor speed limits along a route
        
        // Note: This is a more advanced implementation that would require 
        // setting up a route and navigation session, which is beyond the
        // scope of this implementation
    }
}

// Singleton instance for use throughout the app
let speedLimitManager = SpeedLimitManager()
