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
    @State private var isDriving: Bool = false
    @State private var count = 0
    @State private var speedLimit: String = "Unknown"
    @Binding var isActive: Bool
    @ObservedObject private var speedLimitObserver = speedLimitManager
    @ObservedObject var scoreManager = ScoreManager.shared
    
    var body: some View {
        ZStack {
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
                    }
                }
            }
        }
    }
    
    private func stopMonitoring() {
        speedMonitor.stopTrackingSpeed()
        activityManager.stopActivityUpdates()
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
}
