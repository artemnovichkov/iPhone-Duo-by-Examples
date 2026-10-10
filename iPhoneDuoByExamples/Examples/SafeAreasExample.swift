import SwiftUI

/// Draws the safe area insets on every edge.
///
/// On iPhone Duo the safe area is often **asymmetric**. The vertical bar sits on one side of
/// the screen and takes up space there, while the other side has only a small inset.
/// Folding, unfolding, and rotating move the bar, so the insets change while the app runs.
///
/// - Read the insets from `GeometryProxy.safeAreaInsets` instead of assuming that leading
///   equals trailing, or that the top inset is the tallest one.
/// - `toolbarVerticalEdge` tells you which side the vertical bar is on.
///
/// Keep interactive content inside the safe area. Backgrounds can extend under it.
struct SafeAreasExample: View {
    @Environment(\.toolbarVerticalEdge) private var verticalBarEdge
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        GeometryReader { proxy in
            // 👇 The API: the insets on each edge, as `EdgeInsets`.
            let insets = proxy.safeAreaInsets

            ZStack {
                InsetBands(insets: insets)

                VStack(spacing: 16) {
                    Text(insets.leading == insets.trailing ? "Symmetric" : "Asymmetric")
                        .font(.title.bold())
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                        row("top", insets.top)
                        row("leading", insets.leading)
                        row("bottom", insets.bottom)
                        row("trailing", insets.trailing)
                    }
                    .font(.callout.monospaced())
                    Divider()
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                        GridRow {
                            Text("vertical bar")
                            Text(verticalBarEdge.title)
                        }
                        GridRow {
                            Text("size classes")
                            Text("\(horizontalSizeClass.title) × \(verticalSizeClass.title)")
                        }
                    }
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
                }
                .padding(24)
                .glassEffect(in: .rect(cornerRadius: 28))
                .padding(insets)
                .padding()
            }
            .ignoresSafeArea()
            .animation(.smooth, value: insets)
        }
    }

    private func row(_ edge: String, _ value: CGFloat) -> some View {
        GridRow {
            Text(edge)
            Text(value, format: .number.precision(.fractionLength(0)))
                .contentTransition(.numericText(value: value))
        }
    }
}

/// Colors the area outside the safe area, one color per edge.
private struct InsetBands: View {
    let insets: EdgeInsets

    var body: some View {
        ZStack {
            Color.green.opacity(0.08)
            VStack(spacing: 0) {
                Color.blue.opacity(0.35).frame(height: insets.top)
                Spacer(minLength: 0)
                Color.blue.opacity(0.35).frame(height: insets.bottom)
            }
            HStack(spacing: 0) {
                Color.orange.opacity(0.45).frame(width: insets.leading)
                Spacer(minLength: 0)
                Color.orange.opacity(0.45).frame(width: insets.trailing)
            }
            Rectangle()
                .strokeBorder(.green, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .padding(insets)
        }
        .allowsHitTesting(false)
    }
}

private extension Optional where Wrapped == HorizontalEdge {
    var title: String {
        switch self {
        case .leading: "leading"
        case .trailing: "trailing"
        case nil: "none"
        }
    }
}

private extension Optional where Wrapped == UserInterfaceSizeClass {
    var title: String {
        switch self {
        case .compact: "compact"
        case .regular: "regular"
        default: "unknown"
        }
    }
}

#Preview {
    SafeAreasExample()
}
