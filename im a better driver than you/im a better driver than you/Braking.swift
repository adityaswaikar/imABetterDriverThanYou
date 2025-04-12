//
//  Braking.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/12/25.
//

import SwiftUI
import CoreMotion
import CoreLocation

struct Braking: View {
    @State private var currentSpeed: Double? = nil
    @State private var brakingWarning: String? = nil
    private let activityManager = CMMotionActivityManager()
    @State private var isDriving: Bool = false  // Flag to track if the user is driving


    var body: some View {
        VStack {
            Text(isDriving ? "You're Driving!" : "Not Driving")
                .font(.largeTitle)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let speed = currentSpeed {
                Text(String(format: "%.1f", speed))
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
            speedMonitor.startTrackingSpeed { speed in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentSpeed = speed
                    }
                }
            }
            
            if CMMotionActivityManager.isActivityAvailable() {
                activityManager.startActivityUpdates(to: OperationQueue.main) { activity in
                    guard let activity = activity else { return }
                    isDriving = activity.walking && activity.confidence != .low
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
