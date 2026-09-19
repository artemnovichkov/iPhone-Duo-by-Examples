import SwiftUI

/// Floats one view over another with `ArrangementView` and the `.overlay` style.
///
/// In an overlay arrangement the **primary** view floats on top, anchored to the top leading
/// corner, and the **secondary** view fills the container behind it. Think of a map with
/// a floating panel of search results.
///
/// - `overlayArrangementEdge(_:)` picks the edge the view occupies when the arrangement
///   transitions to a side-by-side layout. Pass a `HorizontalEdge` or a `VerticalEdge`.
/// - `.overlay.axes(_:)` limits the axes that transition can use.
/// - `overlayArrangementZIndex` in the environment reports a view's stacking order
///   within the arrangement.
struct OverlayArrangementExample: View {
    @State private var edge: HorizontalEdge = .leading

    var body: some View {
        ArrangementView {
            ResultsPanel(edge: $edge)
                // 👇 The API: the edge to occupy when the arrangement goes side by side.
                .overlayArrangementEdge(edge)
        } secondary: {
            MapPlaceholder()
        }
        // 👇 The API: float the primary view over the secondary one.
        .arrangementViewStyle(.overlay.axes(.horizontal))
    }
}

/// A stand-in for full-bleed content such as a map or a canvas.
private struct MapPlaceholder: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        LinearGradient(colors: [.teal, .mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: "map")
                    .font(.system(size: 160, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .overlay(alignment: .bottomTrailing) {
                ZIndexLabel(title: "Secondary", zIndex: zIndex)
                    .padding()
            }
    }
}

private struct ResultsPanel: View {
    @Binding var edge: HorizontalEdge
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZIndexLabel(title: "Primary", zIndex: zIndex)
            Text("Coffee Nearby")
                .font(.title3.bold())
            ForEach(["Hinge & Bean", "The Fold", "Crease Café"], id: \.self) { name in
                Label(name, systemImage: "cup.and.saucer.fill")
            }
            Divider()
            Picker("Side-by-side edge", selection: $edge) {
                Text("Leading").tag(HorizontalEdge.leading)
                Text("Trailing").tag(HorizontalEdge.trailing)
            }
            .pickerStyle(.segmented)
            Text("The edge this panel takes when the arrangement switches to side by side.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 320)
        .glassEffect(in: .rect(cornerRadius: 28))
        .padding()
    }
}

private struct ZIndexLabel: View {
    let title: String
    let zIndex: Int

    var body: some View {
        Text("\(title) · zIndex \(zIndex)")
            .font(.caption.monospaced().weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.black.opacity(0.25), in: .capsule)
            .foregroundStyle(.white)
    }
}

#Preview {
    OverlayArrangementExample()
}
