import SwiftUI

// Helpers that turn `DeviceHinge` values into something presentable.
// `DeviceHinge.Status` is a struct with static members rather than an enum,
// so we compare against each known value.

extension DeviceHinge.Status {
    var title: String {
        switch self {
        case .closed: "Closed"
        case .partiallyOpen: "Partially Open"
        case .fullyOpen: "Fully Open"
        default: "Unknown"
        }
    }

    var symbol: String {
        switch self {
        case .closed: "iphone.gen3"
        case .partiallyOpen: "laptopcomputer"
        case .fullyOpen: "ipad.landscape"
        default: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .closed: .gray
        case .partiallyOpen: .orange
        case .fullyOpen: .green
        default: .secondary
        }
    }
}

extension DeviceHinge {
    /// The hinge angle in whole degrees, formatted for display.
    var formattedAngle: String {
        angle.degrees.formatted(.number.precision(.fractionLength(0))) + "°"
    }
}

/// A compact capsule with the current hinge status and angle.
struct HingeBadge: View {
    let hinge: DeviceHinge?

    var body: some View {
        HStack(spacing: 8) {
            if let hinge {
                Image(systemName: hinge.status.symbol)
                Text(hinge.status.title)
                Text(hinge.formattedAngle)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText(value: hinge.angle.degrees))
            } else {
                Image(systemName: "iphone.slash")
                    .symbolRenderingMode(.hierarchical)
                Text("No hinge on this device")
            }
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.fill.tertiary, in: .capsule)
        .animation(.default, value: hinge)
    }
}
