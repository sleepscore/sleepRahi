// Sleep score layout: ring, primary stats, metric grid, and explanation card.
import SwiftUI

struct SleepScoreIndexView: View {
    @ObservedObject var viewModel: SleepScoreViewModel
    var showsMetrics: Bool    = true
    var showsExplanation: Bool = true
    
    //UI
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Score circle and primary stats
            HStack(alignment: .center, spacing: 20) {
                ScoreCircleView(
                    score: viewModel.data.score,
                    color: viewModel.scoreColor()
                )

                if showsMetrics {
                    VStack(alignment: .leading, spacing: 12) {
                        PrimaryStatLine(
                            icon: "moon.fill",
                            color: .indigo,
                            title: "Asleep",
                            value: viewModel.formatDuration(viewModel.data.timeAsleepSeconds)
                        )
                        PrimaryStatLine(
                            icon: "bed.double.fill",
                            color: .blue.opacity(0.7),
                            title: "In Bed",
                            value: viewModel.formatDuration(viewModel.data.timeInBedSeconds)
                        )
                    }
                }
                Spacer(minLength: 0)
            }

            // Metric cards grid
            if showsMetrics {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {

                    MetricCard(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: "Avg Heart Rate",
                        value: viewModel.data.avgHR.map { "\(Int($0)) bpm" } ?? "—"
                    )

                    MetricCard(
                        icon: "waveform.path.ecg",
                        iconColor: .green,
                        title: "Sleep Efficiency",
                        value: String(format: "%.0f%%", viewModel.data.sleepEfficiencyPct)
                    )

                    MetricCard(
                        icon: "eye.slash.fill",
                        iconColor: .purple,
                        title: "Wake Bouts",
                        value: "\(viewModel.data.wakeBouts)"
                    )

                    MetricCard(
                        icon: "lungs.fill",
                        iconColor: viewModel.data.spo2DropCount > 0 ? .orange : .teal,
                        title: "SpO₂ Drops",
                        value: viewModel.data.spo2DropCount == 0
                            ? "None"
                            : "\(viewModel.data.spo2DropCount)"
                    )
                }
            }

            // Explanation
            if showsExplanation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sleep Score Explanation")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(viewModel.scoreColor())
                                .frame(width: 8, height: 8)
                            Text("Score range \(viewModel.activeExplanationRangeTitle())")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text(viewModel.activeExplanation())
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                }
            }
        }
    }
}

// Score circle

private struct ScoreCircleView: View {
    let score: Int
    let color: Color

    private var progress: Double { Double(max(0, min(100, score))) / 100.0 }

    var body: some View {
        let size: CGFloat = 126

        ZStack {
            // Track
            Circle()
                .stroke(Color.primary.opacity(0.1), lineWidth: 14)
                .frame(width: size, height: size)

            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: progress)

            VStack(spacing: 2) {
                Text("\(max(0, min(100, score)))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("Sleep Score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Primary stat beside circle

private struct PrimaryStatLine: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}

// Metric card

private struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}
