//
//  Accelerometer.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/11/25.
//
//  This file now tracks sudden changes in speed (e.g., hard braking) during a driving session using CoreLocation.
import Foundation
import CoreLocation
// Threshold value in m/s² used to determine what qualifies as a sudden deceleration

let decelerationThreshold: Double = 3.0

// SpeedMonitor uses CoreLocation to monitor device speed and detect sudden deceleration events like hard braking
public class SpeedMonitor: NSObject, CLLocationManagerDelegate {
    // CLLocationManager instance used to get location and speed updates
    private let locationManager = CLLocationManager()
    // Optional callback to pass current speed to external handlers (not used for braking detection directly)
    public var speedCallback: ((Double) -> Void)?
    // Stores the last known speed for comparison
    public var previousSpeed: CLLocationSpeed?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.5 // Update for every ~1 meter moved
    }

    public func startTrackingSpeed(callback: @escaping (Double) -> Void) {
        // Save the callback
        self.speedCallback = callback
        // Request permission from the user to access location while the app is in use
        locationManager.requestWhenInUseAuthorization()
        // Start receiving location updates
        locationManager.startUpdatingLocation()
    }

    public func stopTrackingSpeed() {
        // Stop receiving location updates
        locationManager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        // Get the current speed from the most recent location update
        let currentSpeed = latestLocation.speed  // in m/s

        if let lastSpeed = previousSpeed, currentSpeed >= 0 {
            // If we have a previous speed, calculate the rate of deceleration
            let delta = lastSpeed - currentSpeed
            // Calculate time difference between the current and previous speed measurement
            let timeDelta = latestLocation.timestamp.timeIntervalSince1970 - (locations.dropLast().last?.timestamp.timeIntervalSince1970 ?? latestLocation.timestamp.timeIntervalSince1970)
            // Calculate the rate of change in speed (acceleration/deceleration)
            let rateOfChange = delta / timeDelta

            // If the deceleration exceeds the threshold, log a warning
            if rateOfChange >= decelerationThreshold {
                print("⚠️ Sudden deceleration detected: \(rateOfChange) m/s²")
            }
        }

        // Update the previous speed for the next comparison
        previousSpeed = currentSpeed
        
        if currentSpeed >= 0 {
            speedCallback?(currentSpeed * 2.23694) // Convert to MPH if desired
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location errors by printing the error description
        print("Location error: \(error.localizedDescription)")
    }
}

// Singleton instance of SpeedMonitor for use throughout the app
public let speedMonitor = SpeedMonitor()
