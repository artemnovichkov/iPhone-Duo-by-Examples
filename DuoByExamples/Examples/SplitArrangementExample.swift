import SwiftUI

/// Places two views next to each other with `ArrangementView` and the `.split` style.
///
/// `ArrangementView` takes a primary and a secondary view; the arrangement style decides
/// how they share the space:
/// - `.split.axes(_:)` limits the axes the views can be split along. If the container
///   doesn't fit both views along an allowed axis, only the primary view is shown —
///   try "Vertical" on a wide screen.
/// - `splitArrangementLayoutRatio(_:)` sets the share of space a view prefers.
/// - `splitArrangementAxis` in the environment reports the axis the system split the views
///   along, so each pane can adapt its own layout. It's `nil` when no axis is reported.
struct SplitArrangementExample: View {
    @State private var ratio = 0.4
    @State private var axes: AxesOption = .both

    var body: some View {
        ArrangementView {
            PaneView(title: "Primary", symbol: "list.bullet", color: .teal, ratio: $ratio)
                // 👇 The API: the primary pane prefers this share of the container.
                .splitArrangementLayoutRatio(ratio)
        } secondary: {
            PaneView(title: "Secondary", symbol: "doc.richtext", color: .indigo, ratio: nil)
        }
        // 👇 The API: split the two panes along the allowed axes.
        .arrangementViewStyle(.split.axes(axes.value))
        .safeAreaInset(edge: .bottom) {
            Picker("Axes", selection: $axes) {
                ForEach(AxesOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .glassEffect(in: .capsule)
            .padding()
            .frame(maxWidth: 420)
        }
    }
}

private enum AxesOption: String, CaseIterable, Identifiable {
    case both, horizontal, vertical

    var id: Self { self }

    var title: String { rawValue.capitalized }

    var value: Axis.Set {
        switch self {
        case .both: [.horizontal, .vertical]
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }
}

private struct PaneView: View {
    let title: String
    let symbol: String
    let color: Color
    let ratio: Binding<Double>?

    // 👇 The API: how this pane was split, if at all.
    @Environment(\.splitArrangementAxis) private var splitAxis

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .semibold))
            Text(title)
                .font(.title2.bold())
            Text(axisDescription)
                .font(.callout.monospaced())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.2), in: .capsule)

            if let ratio {
                VStack(spacing: 4) {
                    Slider(value: ratio, in: 0.2...0.8)
                        .tint(.white)
                    Text("Layout ratio: \(ratio.wrappedValue, format: .percent.precision(.fractionLength(0)))")
                        .font(.caption.monospacedDigit())
                }
                .frame(maxWidth: 240)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.gradient, in: .rect(cornerRadius: 28))
        .padding(6)
    }

    private var axisDescription: String {
        switch splitAxis {
        case .horizontal: "axis: horizontal"
        case .vertical: "axis: vertical"
        case nil: "axis: nil"
        }
    }
}

#Preview {
    SplitArrangementExample()
}
