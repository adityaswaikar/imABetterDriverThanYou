//
//  AccelerometerView.swift
//  im a better driver than you
//
//  Created by Aditya Waikar on 4/12/25.
//

import SwiftUI
import CoreMotion // Motion data
import CoreLocation // Location services

struct Braking: View {
    @State private var currentSpeed: Double? = nil // stores current speed
    private let activityManager = CMMotionActivityManager() // allows for driving detection
    @State private var isDriving: Bool = false // variable to detect when user is driving
    @Binding var isActive: Bool // assigned from isMonitoringActive from MainTabView
    @ObservedObject private var speedLimitObserver = speedLimitManager // observes shared speed limit
    @ObservedObject var scoreManager = ScoreManager.shared // Accesses score from scoreManager
    @State private var driveTime: TimeInterval = 0      // total seconds
    @State private var timer: Timer? = nil

    
    var body: some View {
        ZStack { // layers views on top of each other
            // Background color changes when braking hard
            if isBrakingHard && (currentSpeed ?? 0) > 0.0 {
                Color.red.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            VStack(spacing: 16) {
                // Score Card
                VStack(spacing: 8) {
                    Text("Current Drive Score")
                        .font(AppTheme.TextStyle.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(currentScore)")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(scoreColor(for: currentScore))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Driving Status Card
                HStack {
                    Image(systemName: isDriving ? "car.fill" : "car")
                        .font(.system(size: 30))
                        .foregroundColor(isDriving ? AppTheme.success : .secondary)
                    
                    Text(isDriving ? "Driving Detected" : "Not Driving")
                        .font(AppTheme.TextStyle.title)
                        .foregroundColor(isDriving ? AppTheme.success : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)

                
                if let speed = currentSpeed {
                    // Speed Card
                    VStack(spacing: 8) {
                        // Current Speed
                        Text(String(format: "%.0f", speed))
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(speedColor(speed: speed))
                        
                        Text("Speed (MPH)")
                            .font(AppTheme.TextStyle.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // Speed Limit
                        HStack {
                            Image(systemName: "speedometer")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                            
                            Text("Speed Limit: \(speedLimitObserver.speedLimitString)")
                                .font(AppTheme.TextStyle.body)
                                .bold()
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                // Drive Time Card
                VStack(spacing: 8) {
                    Text(formatDriveTime(driveTime))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Hard Braking Warning
                if isBrakingHard && (currentSpeed ?? 0) > 0.0 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("HARD BRAKING DETECTED")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                            .fill(AppTheme.danger)
                    )
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .animation(.easeInOut(duration: 0.3), value: isBrakingHard)
        .onAppear {
            startMonitoring()
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                startMonitoring()
            } else {
                stopMonitoring()
            }
        }
        .onDisappear {
            stopMonitoring()
        }
    }
    
    // Helper functions
    private func startMonitoring() {
        speedMonitor.startTrackingSpeed { speed in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentSpeed = speed
                    isDriving = (currentSpeed ?? 0) > 1.0
                    
                    if isDriving, let location = speedMonitor.lastLocation {
                        speedLimitManager.getCurrentSpeedLimit(for: location)
                        
                        // Start a session if one isn't already started
                        if SessionManager.shared.currentSession == nil {
                            SessionManager.shared.startSession()
                        }
                        
                        // Update the current session with speed and location
                        SessionManager.shared.updateSpeed(speed)
                        SessionManager.shared.updateLocation(location)
                        
                        startTimer()
                    }
                }
            }
        }
    }
    
    private func stopMonitoring() {
        speedMonitor.stopTrackingSpeed()
        activityManager.stopActivityUpdates()
        
        // End the current session
        if SessionManager.shared.currentSession != nil {
            SessionManager.shared.endSession()
        }
        
        stopTimer()
        driveTime = 0
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case ..<0:
            return AppTheme.danger
        case 0..<50:
            return AppTheme.warning
        default:
            return AppTheme.success
        }
    }
    
    private func speedColor(speed: Double) -> Color {
        if let currentLimit = speedLimitObserver.currentSpeedLimit?.speedInMPH {
            if speed > currentLimit + 10 {
                return AppTheme.danger
            } else if speed > currentLimit {
                return AppTheme.warning
            }
        }
        return .primary
    }
    
    private func startTimer() {
        guard timer == nil else { return } // prevent multiple timers
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            driveTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    
    private func formatDriveTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

}
