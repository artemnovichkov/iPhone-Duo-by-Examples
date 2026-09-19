import Charts
import SwiftUI

/// Records every hinge update and plots the angle over time with Swift Charts.
///
/// This is a handy way to see how often the system delivers updates.
/// The rate and granularity of angle updates are system policy, so never
/// depend on a particular frequency or precision.
struct HingeHistoryExample: View {
    private struct Sample: Identifiable {
        let id = UUID()
        let date: Date
        let hinge: DeviceHinge
    }

    @State private var samples: [Sample] = []
    @State private var isRecording = true

    var body: some View {
        List {
            Section {
                Chart(samples) { sample in
                    LineMark(
                        x: .value("Time", sample.date),
                        y: .value("Angle", sample.hinge.angle.degrees)
                    )
                    .interpolationMethod(.stepEnd)
                    .foregroundStyle(.indigo.gradient)

                    PointMark(
                        x: .value("Time", sample.date),
                        y: .value("Angle", sample.hinge.angle.degrees)
                    )
                    .foregroundStyle(sample.hinge.status.color)
                    .symbolSize(30)
                }
                .chartYScale(domain: 0...180)
                .chartYAxis {
                    AxisMarks(values: [0, 45, 90, 135, 180]) { value in
                        AxisGridLine()
                        AxisValueLabel("\(value.as(Int.self) ?? 0)°")
                    }
                }
                .frame(height: 240)
                .overlay {
                    if samples.isEmpty {
                        Text("Fold or unfold the device to record samples.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
            } header: {
                Text("Angle over time")
            }

            Section {
                Toggle("Recording", systemImage: "record.circle", isOn: $isRecording)
                Button("Clear", systemImage: "trash", role: .destructive) {
                    samples.removeAll()
                }
                .disabled(samples.isEmpty)
            }

            Section("Updates · \(samples.count)") {
                ForEach(samples.reversed()) { sample in
                    HStack {
                        Image(systemName: sample.hinge.status.symbol)
                            .foregroundStyle(sample.hinge.status.color)
                            .frame(width: 28)
                        Text(sample.hinge.status.title)
                        Spacer()
                        Text(sample.hinge.formattedAngle)
                            .monospacedDigit()
                        Text(sample.date, format: .dateTime.hour().minute().second())
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)
                }
            }
        }
        // 👇 The API: `isEnabled` pauses delivery without removing the modifier.
        // Updates that happen while it's disabled are simply not delivered.
        .onHingeChange(isEnabled: isRecording) { _, newContext in
            guard let hinge = newContext.hinge else { return }
            withAnimation {
                samples.append(Sample(date: .now, hinge: hinge))
            }
        }
    }
}

#Preview {
    HingeHistoryExample()
}
