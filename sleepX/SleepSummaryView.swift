// Summary screen of calendar, selected night, score UI or empty state
import SwiftUI
import SwiftData

struct SleepSummaryView: View {
    @StateObject private var viewModel = SleepSummaryViewModel()

    // Query ALL SleepResult records from SwiftData, sorted newest first
    @Query(sort: \SleepResult.date, order: .reverse)

    private var allResults: [SleepResult]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(weekRangeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                // Calendar
                VStack {
                    DatePicker(
                        "Select day",
                        selection: Binding(
                            get: { viewModel.selectedDate },
                            set: { viewModel.selectDayFromCalendar($0) }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(.indigo)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                // Selected day label
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.indigo)
                    Text(selectedDayText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Metrics or empty state
                if let result = resultForSelectedDay {
                    SleepScoreIndexView(
                        viewModel: viewModel.scoreViewModel(from: result)
                    )
                } else {
                    EmptyDayView()
                }
            }
            .padding()
        }
        // Navigation bar
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    // SwiftData record for the selected calendar day
    private var resultForSelectedDay: SleepResult? {
        allResults.first { viewModel.isSameDay($0.date, viewModel.selectedDate) }
    }

    private var weekRangeText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return "\(df.string(from: viewModel.weekStartDate)) – \(df.string(from: viewModel.weekEndDate))"
    }

    private var selectedDayText: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d"
        return df.string(from: viewModel.selectedDate)
    }
}

// Empty state when no night is recorded
private struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 40))
                .foregroundStyle(.indigo.opacity(0.5))
            Text("No data for this night")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Make sure your device recorded and has disconnected.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .modelContainer(for: SleepResult.self, inMemory: true)
}
