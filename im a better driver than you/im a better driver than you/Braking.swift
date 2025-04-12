//
//  Braking.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/12/25.
//

import SwiftUI
import CoreMotion
import CoreLocation

class Monitor: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var speedUpdateHandler: ((Double) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .automotiveNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5 // meters
    }

    func startTrackingSpeed(handler: @escaping (Double) -> Void) {
        speedUpdateHandler = handler
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopTrackingSpeed() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let speed = locations.last?.speed, speed >= 0 else { return }
        // Convert speed to MPH and call the handler on the main thread
        DispatchQueue.main.async {
            self.speedUpdateHandler?(speed * 2.23694)
        }
    }
}

struct Braking: View {
    @State private var currentSpeed: Double? = nil
    @State private var brakingWarning: String? = nil
    private let activityManager = CMMotionActivityManager()
    @State private var isDriving: Bool = false  // Flag to track if the user is driving
    private let speedMonitor = SpeedMonitor()

    var body: some View {
        VStack {
            Text(isDriving ? "You're Driving!" : "Not Driving")
                .font(.largeTitle)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let speed = currentSpeed {
                Text("\(Int(speed.rounded()))")
                    .font(.system(size: 50, weight: .bold))
                    .padding(.top, 5)
                
                Text("Speed (MPH)")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            if let warning = brakingWarning {
                Text(warning)
                    .foregroundColor(.orange)
                    .bold()
                    .padding(.top, 10)
            }
        }
        .padding()
        .onAppear {
            currentSpeed = 0
            speedMonitor.startTrackingSpeed { speed in
                currentSpeed = speed
            }
            
            if CMMotionActivityManager.isActivityAvailable() {
                activityManager.startActivityUpdates(to: OperationQueue.main) { activity in
                    guard let activity = activity else { return }
                    isDriving = activity.automotive && activity.confidence != .low
                }
            }
        }
        .onDisappear {
            speedMonitor.stopTrackingSpeed()
            activityManager.stopActivityUpdates()
        }
    }
}

#Preview {
    Braking()
}
