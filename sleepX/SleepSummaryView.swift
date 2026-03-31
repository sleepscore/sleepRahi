//
//  SleepSummaryView.swift
//  sleepX
//

import SwiftUI

struct SleepSummaryView: View {
    @StateObject private var viewModel = SleepSummaryViewModel()
    @State private var selectedScoreViewModel: SleepScoreViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(weekRangeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    DatePicker(
                        "Select day",
                        selection: Binding(
                            get: { viewModel.selectedDate },
                            set: { viewModel.selectDayFromCalendar($0) }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }

                if let vm = selectedScoreViewModel {
                    SleepScoreIndexView(viewModel: vm)
                } else {
                    Text("No sleep score data saved.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Summary View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedScoreViewModel = viewModel.sleepScoreViewModel(for: viewModel.selectedDate)
        }
        .onChange(of: viewModel.selectedDate) { _, newValue in
            selectedScoreViewModel = viewModel.sleepScoreViewModel(for: newValue)
        }
    }

    private var weekRangeText: String {
        let start = viewModel.weekStartDate
        let end = viewModel.weekEndDate
        let df = DateFormatter()
        df.dateStyle = .medium
        return "Week: \(df.string(from: start)) - \(df.string(from: end))"
    }
}

#Preview {
    NavigationStack {
        SleepSummaryView()
    }
}
