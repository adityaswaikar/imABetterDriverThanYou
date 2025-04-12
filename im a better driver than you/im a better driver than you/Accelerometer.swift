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
let decelerationThreshold: Double = 0.7

// SpeedMonitor uses CoreLocation to monitor device speed and detect sudden deceleration events like hard braking
public class SpeedMonitor: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    
    public var speedCallback: ((Double) -> Void)?
    public var previousSpeed: CLLocationSpeed?
    
    @Published public var isBrakingHard: Bool = false
    
    private var resetBrakingWorkItem: DispatchWorkItem?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 9 // Update every ~1 meter
    }

    public func startTrackingSpeed(callback: @escaping (Double) -> Void) {
        self.speedCallback = callback
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    public func stopTrackingSpeed() {
        locationManager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        let currentSpeed = latestLocation.speed // m/s

        if let lastSpeed = previousSpeed, currentSpeed >= 0 {
            let delta = lastSpeed - currentSpeed
            let timeDelta = latestLocation.timestamp.timeIntervalSince1970 - (locations.dropLast().last?.timestamp.timeIntervalSince1970 ?? latestLocation.timestamp.timeIntervalSince1970)
            let rateOfChange = delta / max(timeDelta, 0.1)  // avoid divide-by-zero

            if rateOfChange >= decelerationThreshold {
                isBrakingHard = true
                print("⚠️ Sudden deceleration detected: \(rateOfChange) m/s²")
                
                // Optional: Reset after short delay
                resetBrakingWorkItem?.cancel()
                let workItem = DispatchWorkItem {
                    DispatchQueue.main.async {
                        self.isBrakingHard = false
                    }
                }
                resetBrakingWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
            }
        }

        previousSpeed = currentSpeed
        
        if currentSpeed >= 0 {
            speedCallback?(currentSpeed * 2.23694) // Convert to MPH
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// Singleton instance of SpeedMonitor
public let speedMonitor = SpeedMonitor()
