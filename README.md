🚗 Gaadi

Gaadi is a driving companion app that helps users monitor and improve their driving behavior by tracking speed, braking patterns, and overall driving performance. The app provides real-time feedback, score calculations, and historical insights to encourage safer driving habits.

🛠️ Planned Features

⏱️ Drive Timer & Positive Scoring

Implement a timer that tracks the duration of each drive.

Introduce positive scores for safe driving over sustained periods, complementing the current penalty-based system.

🌐 Social & Competitive Backend

Store driving data on a backend system to compare scores with friends.

Enable friendly competitions and leaderboards.

Likely implementation via Google Firebase or a similar cloud service.

✨ Features

🚦 Real-Time Driving Monitoring

Detects driving activity using device motion and GPS.

Monitors current speed and compares it to local speed limits.

Flags hard braking events and speeding violations in real-time.

🏆 Driving Score

Calculates a score for each driving session based on smoothness, consistency, and adherence to speed limits.

Maintains both recent session scores and an all-time driving score.

Provides a percentile rank comparing the user’s performance to others.

📊 Score Breakdown

Displays detailed components contributing to the score:

Base Score

Hard Braking Penalties

Speeding Penalties

Consistency Bonuses

📈 Driving History & Analytics

Visualizes score trends over time using interactive charts.

Lists recent sessions with details like duration, average speed, and hard braking count.

Detailed session view shows full performance metrics and assessments.

⚡ Speed Limit Awareness

Integrates with Mapbox Directions API to retrieve local speed limits.

Converts units and displays speed limit in miles per hour.

Highlights when the driver exceeds the speed limit.

🎨 Theming & UI

Modern, clean SwiftUI interface.

Color-coded feedback: green for safe driving, yellow for warnings, red for critical events.

Smooth animations for score updates and alerts.

🧰 Technical Overview

Languages & Frameworks: Swift, SwiftUI, CoreLocation, CoreMotion

Data Persistence: UserDefaults for all-time scores

Design Patterns: Singleton pattern for ScoreManager, SessionManager, and SpeedMonitor

External Services: Mapbox Directions API for speed limit data

📂 File Structure

ScoreManager.swift – Manages driving scores, breakdowns, and percentile ranking.

Braking.swift – SwiftUI view showing real-time driving score, speed, and braking warnings.

Accelerometer.swift – Tracks sudden deceleration and calculates hard braking events.

HistoryView.swift – Displays historical driving sessions and analytics.

SpeedLimitManager.swift – Fetches and converts local speed limit data from Mapbox.

AppTheme.swift – Defines consistent color schemes, font styles, and card layouts.

⚙️ How It Works

Monitoring

When a driving session starts, SpeedMonitor tracks speed and location continuously.

Hard braking is detected using sudden deceleration measurements.

Speed limit information is retrieved in real-time via SpeedLimitManager.

Scoring

Each session generates a score based on speed, braking, and consistency.

Scores are time-weighted to prioritize recent driving behavior.

The ScoreManager updates the all-time score, recent score, percentile rank, and score breakdown.

Visualization

The Braking view provides live feedback during driving.

The HistoryView shows trends over time and allows users to inspect individual session details.

📥 Installation & Setup

Clone the repository.

Open Gaadi.xcodeproj in Xcode 15 or later.

Ensure location and motion permissions are enabled in the app settings.

Add your Mapbox access token to im-a-better-driver-than-you-Info.plist under MBXAccessToken.

Build and run on a real iOS device (location and motion sensors are required for full functionality).
