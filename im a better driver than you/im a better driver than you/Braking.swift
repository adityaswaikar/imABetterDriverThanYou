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
    private let activityManager = CMMotionActivityManager()
    @State private var isDriving: Bool = false  // Flag to track if the user is driving
    @StateObject var accelerationCheck = SpeedMonitor()

    
    var body: some View {
        ZStack {
            (accelerationCheck.isBrakingHard ? Color.red : Color.clear)
                .animation(.easeInOut(duration: 0.5), value: accelerationCheck.isBrakingHard)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(isDriving ? "You're Driving!" : "Not Driving")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if let speed = currentSpeed {
                    Text(String(format: "%.1f", speed))
                        .font(.system(size: 50, weight: .bold))
                        .padding(.top, 5)
                    
                    // Dynamically adjusts text color for light/dark mode
                    Text("Speed (MPH)")
                        .font(.title2)
                        .foregroundColor(Color.primary)
                }

                if accelerationCheck.isBrakingHard {
                    Text("breaking hard !!!")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .onAppear {
            speedMonitor.startTrackingSpeed { speed in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentSpeed = speed
                        // Determine if driving based on speed threshold
                        isDriving = (currentSpeed ?? 0) > 1.0  // You can adjust this threshold
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
