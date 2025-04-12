//
//  Braking.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/12/25.
//

import SwiftUI
import CoreMotion

struct Braking: View {
    @State private var currentSpeed: Double? = nil
    @State private var brakingWarning: String? = nil
    @State private var isDriving: Bool = false  // Flag to track if the user is driving

    private let activityManager = CMMotionActivityManager()
    @StateObject private var speedMonitor = SpeedMonitor()
    @State private var brakeCount = 0

    // Track previous braking state to detect transitions
    @State private var wasBrakingHard = false
    @State private var isMotionDriving = false

    var body: some View {
        ZStack {
            if speedMonitor.isBrakingHard && (currentSpeed ?? 0) > 0.0 {
                Color.red
            } else {
                Color.clear
            }

            VStack {
                Text(isDriving ? "You're Driving!" : "Not Driving")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                if let speed = currentSpeed {
                    Text(String(format: "%.1f", speed))
                        .font(.system(size: 50, weight: .bold))
                        .padding(.top, 5)

                    Text("Speed (MPH)")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                if speedMonitor.isBrakingHard {
                    Text("BREAKING HARD!!!")
                        .font(.title)
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
            }
            .padding()
        }
        .onAppear {
            setupSpeedTracking()
            setupActivityUpdates()
        }
        .onDisappear {
            speedMonitor.stopTrackingSpeed()
            activityManager.stopActivityUpdates()
        }
        .onChange(of: speedMonitor.isBrakingHard) { oldValue, newValue in
            if newValue && !oldValue {
                brakeCount += 1
            }
        }
    }

    private func setupSpeedTracking() {
        speedMonitor.startTrackingSpeed { speed in
            DispatchQueue.main.async {
                currentSpeed = speed
                updateDrivingState()
            }
        }
    }

    private func setupActivityUpdates() {
        activityManager.startActivityUpdates(to: .main) { activity in
            if let activity = activity {
                DispatchQueue.main.async {
                    isMotionDriving = activity.automotive
                    updateDrivingState()
                }
            }
        }
    }

    private func updateDrivingState() {
        let speedDriving = currentSpeed.map { $0 > 10.0 } ?? false

        // If currently considered driving, allow small dips (like being at a stop)
        if isMotionDriving || speedDriving {
            isDriving = true
        } else if !isMotionDriving && (currentSpeed ?? 0.0) < 3.0 {
            isDriving = false
        }
    }
}

#Preview {
    Braking()
}
