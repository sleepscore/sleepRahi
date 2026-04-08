//
//  SleepScoreIndexView.swift
//  sleepX
//
//  Reusable single-day Sleep Score Index UI.
//

import SwiftUI

struct SleepScoreIndexView: View {
    @ObservedObject var viewModel: SleepScoreViewModel
    var showsMetrics: Bool = true
    var showsExplanation: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Score index + two stats
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 16) {
                    ScoreCircleView(score: viewModel.data.score, color: viewModel.scoreColor())

                    if showsMetrics {
                        VStack(alignment: .leading, spacing: 10) {
                            StatLine(title: "Time asleep", value: viewModel.formatDuration(viewModel.data.timeAsleepSeconds))
                            StatLine(title: "Time in bed", value: viewModel.formatDuration(viewModel.data.timeInBedSeconds))
                        }
                    }

                    Spacer(minLength: 0)
                }
            }

            // Explanation for the active score range
            if showsExplanation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sleep Score Explanation")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Showing for \(viewModel.activeExplanationRangeTitle())")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(viewModel.activeExplanation())
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
}

private struct StatLine: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

private struct ScoreCircleView: View {
    let score: Int
    let color: Color

    private var clampedScore: Double { Double(max(0, min(100, score))) }
    private var progress: Double { clampedScore / 100.0 }

    var body: some View {
        let size: CGFloat = 122

        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: 14)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(max(0, min(100, score)))")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Sleep Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

