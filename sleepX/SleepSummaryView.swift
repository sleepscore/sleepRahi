//
//  SleepSummaryView.swift
//  sleepX
//
//  Displays a multi-day review (Monday-Friday) using previously-saved results.
//

import SwiftUI

struct SleepSummaryView: View {
    @StateObject private var viewModel = SleepSummaryViewModel()

    @State private var selectedScoreViewModel: SleepScoreViewModel?

    private let dayLabels = ["M", "T", "W", "TH", "F"]

    var body: some View {
        NavigationStack {
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
                            "Week starting",
                            selection: Binding(
                                get: { viewModel.weekStartDate },
                                set: { newValue in viewModel.setWeekStartDate(newValue) }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select a day")
                            .font(.headline)

                        HStack(spacing: 10) {
                            ForEach(Array(viewModel.weekDatesMondayToFriday.enumerated()), id: \.offset) { index, date in
                                DaySelectButton(
                                    label: dayLabels[index],
                                    date: date,
                                    isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                                ) {
                                    viewModel.selectedDate = date
                                }
                            }
                        }
                    }

                    if let vm = selectedScoreViewModel {
                        SleepScoreIndexView(viewModel: vm)
                    } else {
                        Text("No sleep data saved for this day yet.")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Summary View")
            .onAppear {
                selectedScoreViewModel = viewModel.sleepScoreViewModel(for: viewModel.selectedDate)
            }
            .onChange(of: viewModel.selectedDate) { _, newValue in
                selectedScoreViewModel = viewModel.sleepScoreViewModel(for: newValue)
            }
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

private struct DaySelectButton: View {
    let label: String
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var dateText: String {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df.string(from: date)
    }
}

#Preview {
    SleepSummaryView()
}

