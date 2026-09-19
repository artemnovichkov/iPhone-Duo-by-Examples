import SwiftUI

/// Reads the live hinge angle with `onHingeChange` and mirrors it in a 3D model of the device.
///
/// `onHingeChange` calls its action with the initial state and on every update.
/// Both contexts carry an optional `DeviceHinge`: it's `nil` when the view
/// isn't in a hierarchy that provides hinge updates, for example on a device without a hinge.
struct HingeAngleExample: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                FoldingDeviceModel(angle: hinge?.angle ?? .degrees(180))
                    .frame(height: 220)
                    .padding(.top, 24)

                AngleGauge(angle: hinge?.angle ?? .zero)
                    .frame(width: 260, height: 150)

                StatusStrip(current: hinge?.status)

                if hinge == nil {
                    NoHingeNote()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        // 👇 The API: subscribe to hinge updates.
        .onHingeChange { _, newContext in
            withAnimation(.snappy) {
                hinge = newContext.hinge
            }
        }
    }
}

// MARK: - 3D model

/// Two panels joined by a hinge. The trailing panel rotates around the hinge line.
private struct FoldingDeviceModel: View {
    let angle: Angle

    var body: some View {
        HStack(spacing: 0) {
            Panel(label: "A")
            Panel(label: "B")
                // A flat device (180°) has no rotation; a closed device (0°) folds panel B onto panel A.
                .rotation3DEffect(
                    .degrees(180) - angle,
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    perspective: 0.4
                )
        }
        .rotation3DEffect(.degrees(18), axis: (x: 1, y: 0, z: 0))
    }

    private struct Panel: View {
        let label: String

        var body: some View {
            RoundedRectangle(cornerRadius: 18)
                .fill(.indigo.gradient)
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 2)
                }
                .overlay {
                    Text(label)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(width: 120, height: 200)
        }
    }
}

// MARK: - Gauge

/// A half-circle gauge from 0° (closed) to 180° (flat).
private struct AngleGauge: View {
    let angle: Angle

    private var progress: Double {
        min(max(angle.degrees / 180, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            HalfArc()
                .stroke(.fill.tertiary, style: StrokeStyle(lineWidth: 18, lineCap: .round))
            HalfArc()
                .trim(from: 0, to: progress)
                .stroke(.indigo.gradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))

            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(angle.degrees, format: .number.precision(.fractionLength(0)))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: angle.degrees))
                    Text("°")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
                .monospacedDigit()
                Text("\(angle.radians, format: .number.precision(.fractionLength(3))) rad")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hinge angle")
        .accessibilityValue("\(angle.degrees, format: .number.precision(.fractionLength(0))) degrees")
    }

    private nonisolated struct HalfArc: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.addArc(
                    center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: min(rect.width / 2, rect.height) - 9,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false
                )
            }
        }
    }
}

// MARK: - Status

/// All three hinge statuses, with the current one highlighted.
private struct StatusStrip: View {
    let current: DeviceHinge.Status?

    private let statuses: [DeviceHinge.Status] = [.closed, .partiallyOpen, .fullyOpen]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(statuses, id: \.self) { status in
                let isCurrent = status == current
                VStack(spacing: 6) {
                    Image(systemName: status.symbol)
                        .font(.title2)
                    Text(status.title)
                        .font(.caption.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isCurrent ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                .background(
                    isCurrent ? AnyShapeStyle(status.color.gradient) : AnyShapeStyle(.fill.quaternary),
                    in: .rect(cornerRadius: 14)
                )
            }
        }
        .frame(maxWidth: 420)
    }
}

#Preview {
    NavigationStack {
        HingeAngleExample()
    }
}
