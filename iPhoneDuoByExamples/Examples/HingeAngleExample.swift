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

/// Two halves joined by a hinge, drawn with a real perspective projection.
///
/// Like the device, the fold is symmetric: the screens face the viewer and each half
/// swings toward them by half of the remaining angle, `(180° − angle) / 2`.
private struct FoldingDeviceModel: View {
    let angle: Angle

    var body: some View {
        ZStack {
            HalfPanel(side: -1, angle: angle, label: "A")
            HalfPanel(side: 1, angle: angle, label: "B")
        }
        .frame(width: 300, height: 220)
    }
}

private struct HalfPanel: View {
    let side: CGFloat
    let angle: Angle
    let label: String

    var body: some View {
        let shape = FoldedPanelShape(side: side, foldAngle: angle.radians)
        let turn = (Double.pi - angle.radians) / 2

        shape
            .fill(.indigo.gradient)
            .overlay {
                shape.stroke(.white.opacity(0.4), lineWidth: 2)
            }
            .overlay {
                GeometryReader { proxy in
                    Text(label)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white.opacity(0.85))
                        // Foreshorten the label together with its half.
                        .scaleEffect(x: max(cos(turn), 0.01), y: 1)
                        .position(shape.labelPosition(in: proxy.frame(in: .local)))
                }
            }
    }
}

/// One half of the device as seen by a camera in front of the hinge.
private nonisolated struct FoldedPanelShape: Shape {
    /// `-1` for the leading half, `1` for the trailing half.
    var side: CGFloat
    /// The hinge angle in radians: `.pi` when flat, `0` when closed.
    var foldAngle: Double

    var animatableData: Double {
        get { foldAngle }
        set { foldAngle = newValue }
    }

    private let halfWidth: CGFloat = 115
    private let height: CGFloat = 190
    private let cornerRadius: CGFloat = 20
    private let cameraDistance: CGFloat = 700
    private let elevation = 0.18

    func path(in rect: CGRect) -> Path {
        let points = outline().map { project($0, in: rect) }
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }

    func labelPosition(in rect: CGRect) -> CGPoint {
        project((d: halfWidth / 2, y: 0), in: rect)
    }

    /// The outline of the half in its own flat coordinates:
    /// `d` is the distance from the hinge, `y` the vertical position.
    /// Only the outer corners are rounded; the hinge side is straight.
    private func outline() -> [(d: CGFloat, y: CGFloat)] {
        var points: [(d: CGFloat, y: CGFloat)] = [(0, -height / 2)]
        let outerCorners: [(center: (d: CGFloat, y: CGFloat), start: Double)] = [
            ((halfWidth - cornerRadius, -height / 2 + cornerRadius), -.pi / 2),
            ((halfWidth - cornerRadius, height / 2 - cornerRadius), 0),
        ]
        for corner in outerCorners {
            for step in 0...8 {
                let t = corner.start + Double(step) / 8 * (.pi / 2)
                points.append((corner.center.d + cornerRadius * cos(t), corner.center.y + cornerRadius * sin(t)))
            }
        }
        points.append((0, height / 2))
        return points
    }

    private func project(_ point: (d: CGFloat, y: CGFloat), in rect: CGRect) -> CGPoint {
        // Swing the half toward the camera around the hinge line.
        let turn = (Double.pi - foldAngle) / 2
        let x = side * point.d * cos(turn)
        let z = point.d * sin(turn)
        // Look at the device slightly from above.
        let y = point.y * cos(elevation) - z * sin(elevation)
        let depth = point.y * sin(elevation) + z * cos(elevation)
        let scale = cameraDistance / (cameraDistance - depth)
        return CGPoint(x: rect.midX + x * scale, y: rect.midY + y * scale)
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
