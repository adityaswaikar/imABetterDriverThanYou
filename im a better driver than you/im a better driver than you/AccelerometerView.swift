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
    @State private var count = 0
    @State private var speedLimit: String = "Unknown"
    // @ObservedObject private var speedLimitObserver = speedLimitManager
    
    // Display score in the home tab
    var body: some View {
        ZStack {
            if isBrakingHard && (currentSpeed ?? 0 ) > 0.0 {
                Color.red
            } else {
                Color.clear
            }
            
            VStack {
                Text("Current Score: \(currentScore)")
                    .font(.system(size: 40, weight: .bold))
                    .padding()
                
                (Text(isDriving ? "You're Driving!" : "Not Driving")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center))
                
                
                if let speed = currentSpeed {
                    Text(String(format: "%.0f", speed))
                        .font(.system(size: 50, weight: .bold))
                        .padding(.top, 5)
                    
                    // Dynamically adjusts text color for light/dark mode
                    Text("Speed (MPH)")
                        .font(.title2)
                        .foregroundColor(Color.primary)
                        
//                    Divider()
//                        .padding(.vertical, 10)
                    
//                    HStack {
//                        Image(systemName: "speedometer")
//                            .font(.system(size: 24))
//                        
//                        Text("Speed Limit: \(speedLimitObserver.speedLimitString)")
//                            .font(.title3)
//                            .bold()
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color(UIColor.secondarySystemBackground))
//                    )
                }
                
            }
        }
            .padding()
            .onAppear {
                speedMonitor.startTrackingSpeed { speed in
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentSpeed = speed
                            // Determine if driving based on speed threshold
                            isDriving = (currentSpeed ?? 0) > 1.0  // You can adjust this threshold
                            
                            // Update speed limit when location changes significantly
                            //                        if isDriving, let location = speedMonitor.lastLocation {
                            //                            speedLimitManager.getCurrentSpeedLimit(for: location)
                            //                        }
                        }
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
