//
//  Braking.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/12/25.
//

import SwiftUI
import CoreMotion

// Main view that displays the app's home screen and driving detection status
struct Braking: View {
    // State variable to track the current speed and braking warning
    @State private var currentSpeed: Double? = nil
    @State private var brakingWarning: String? = nil
    // Instance of CMMotionActivityManager to monitor motion activity (driving, walking, etc.)
    private let activityManager = CMMotionActivityManager()
    @State private var isDriving: Bool = false  // Flag to track if the user is driving

    var body: some View {
        // UI layout containing the app title and driving status message
        VStack {
            // Show fallback message if driving status is not detected
            Text(isDriving ? "You're Driving!" : "Not Driving")
                .font(.largeTitle) // Large font for visibility
                .foregroundColor(.black) // Black color for the text
                .multilineTextAlignment(.center) // Center align the text
            
            // Display speed if available
            if let speed = currentSpeed {
                // Convert speed from meters per second to miles per hour
                let mphSpeed = speed * 2.23694
                Text("\(Int(mphSpeed.rounded()))") // Display the rounded speed
                    .font(.system(size: 50, weight: .bold)) // Make the speed large and bold
                    .padding(.top, 5) // Add space between speed and label
                
                Text("Speed (MPH)") // Label for the speed in miles per hour
                    .font(.title2) // Smaller title font
                    .foregroundColor(.gray) // Gray color for the label
            }

            // Display braking warning if available
            if let warning = brakingWarning {
                Text(warning) // Show the warning text
                    .foregroundColor(.orange) // Orange color for warnings
                    .bold() // Bold the warning text
                    .padding(.top, 10) // Add space above the warning
            }
        }
        .padding() // Add padding around the entire view
        
        // Start motion activity updates when the view appears
        .onAppear {
            currentSpeed = 0 // Initialize speed to 0 when the view appears
            speedMonitor.startTrackingSpeed { speed in
                currentSpeed = speed // Update current speed as it changes
            }
            
            // Check if motion activity updates are available on the device
            if CMMotionActivityManager.isActivityAvailable() {
                // Start receiving activity updates from the device
                activityManager.startActivityUpdates(to: OperationQueue.main) { activity in
                    guard let activity = activity else { return }
                    // Set the 'isDriving' flag based on the activity type and confidence level
                    isDriving = activity.automotive && activity.confidence != .low
                }
            }
        }
        
        // Stop motion activity updates when the view disappears
        .onDisappear {
            speedMonitor.stopTrackingSpeed() // Stop speed tracking when the view disappears
            activityManager.stopActivityUpdates() // Stop receiving activity updates
        }
    }
}

// Preview provider for Xcode canvas
#Preview {
    Braking()
}
