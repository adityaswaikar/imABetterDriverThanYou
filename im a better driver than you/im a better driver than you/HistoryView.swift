import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    @State private var selectedSession: DrivingSession?
    @State private var showingSessionDetail = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Driving History")
                    .font(AppTheme.TextStyle.header)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Score Chart
                if !sessionManager.sessions.isEmpty {
                    chartSection
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: AppTheme.CardStyle.shadowRadius, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                }
                
                // Recent Sessions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Sessions")
                        .font(AppTheme.TextStyle.title)
                        .padding(.horizontal)
                    
                    if sessionManager.sessions.isEmpty {
                        emptyStateView
                    } else {
                        sessionsList
                    }
                }
                
                // For development only
                #if DEBUG
                Button("Add Test Data") {
                    sessionManager.addTestSessions()
                }
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                #endif
            }
            .padding(.vertical, 20)
        }
        .sheet(isPresented: $showingSessionDetail, content: {
            if let session = selectedSession {
                SessionDetailView(session: session)
            }
        })
    }
    
    // Chart section
    var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Trend")
                .font(AppTheme.TextStyle.title)
            
            let sortedSessions = sessionManager.sessions.sorted { $0.date < $1.date }
            
            Chart {
                ForEach(sortedSessions.suffix(10)) { session in
                    LineMark(
                        x: .value("Date", session.date),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(AppTheme.primary)
                    
                    PointMark(
                        x: .value("Date", session.date),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(scoreColor(for: session.score))
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
        }
    }
    
    // Empty state view
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.circle")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No driving sessions yet")
                .font(AppTheme.TextStyle.title)
                .foregroundColor(.secondary)
            
            Text("Your driving history will appear here after you complete your first drive.")
                .font(AppTheme.TextStyle.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    // Sessions list
    var sessionsList: some View {
        VStack(spacing: 12) {
            ForEach(sessionManager.sessions.sorted(by: { $0.date > $1.date })) { session in
                Button {
                    selectedSession = session
                    showingSessionDetail = true
                } label: {
                    sessionRow(for: session)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // Individual session row
    func sessionRow(for session: DrivingSession) -> some View {
        HStack {
            // Score circle
            ZStack {
                Circle()
                    .fill(scoreColor(for: session.score).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text("\(session.score)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(scoreColor(for: session.score))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Date
                Text(formatDate(session.date))
                    .font(AppTheme.TextStyle.body)
                
                // Duration
                Text("\(formatDuration(session.duration)) • \(String(format: "%.1f", session.averageSpeed)) MPH avg")
                    .font(AppTheme.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    // Helper functions
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case ..<40:
            return AppTheme.danger
        case 40..<70:
            return AppTheme.warning
        default:
            return AppTheme.success
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
}

struct SessionDetailView: View {
    let session: DrivingSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Score card
                    VStack(spacing: 16) {
                        Text("Drive Score")
                            .font(AppTheme.TextStyle.caption)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .trim(from: 0, to: min(CGFloat(session.score) / 100, 1.0))
                                .stroke(scoreColor(for: session.score), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(session.score)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(scoreColor(for: session.score))
                        }
                        
                        Text(formatDate(session.date))
                            .font(AppTheme.TextStyle.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: AppTheme.CardStyle.shadowRadius, x: 0, y: 2)
                    )
                    
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(title: "Duration", value: formatDuration(session.duration))
                        statCard(title: "Avg Speed", value: String(format: "%.1f MPH", session.averageSpeed))
                        statCard(title: "Max Speed", value: String(format: "%.1f MPH", session.maxSpeed))
                        statCard(title: "Hard Brakes", value: "\(session.hardBrakingCount)")
                        statCard(title: "Speeding", value: formatDuration(session.speedingDuration))
                    }
                    
                    // Performance assessment
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Drive Assessment")
                            .font(AppTheme.TextStyle.title)
                        
                        performanceItem(
                            icon: "hand.raised.fill", 
                            title: "Hard Braking", 
                            value: "\(session.hardBrakingCount)",
                            color: session.hardBrakingCount == 0 ? AppTheme.success : (session.hardBrakingCount < 3 ? AppTheme.warning : AppTheme.danger)
                        )
                        
                        performanceItem(
                            icon: "speedometer", 
                            title: "Speeding", 
                            value: formatDuration(session.speedingDuration),
                            color: session.speedingDuration < 60 ? AppTheme.success : (session.speedingDuration < 300 ? AppTheme.warning : AppTheme.danger)
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: AppTheme.CardStyle.shadowRadius, x: 0, y: 2)
                    )
                }
                .padding()
            }
            .navigationTitle("Drive Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Helper views and functions
    func statCard(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppTheme.TextStyle.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(AppTheme.TextStyle.title)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CardStyle.cornerRadius)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    func performanceItem(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(AppTheme.TextStyle.body)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.TextStyle.body)
                .foregroundColor(color)
        }
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case ..<40:
            return AppTheme.danger
        case 40..<70:
            return AppTheme.warning
        default:
            return AppTheme.success
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
}

#Preview {
    HistoryView()
}