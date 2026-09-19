import SwiftUI

/// Adapts a layout when the iPhone Duo folds and unfolds.
///
/// Folding changes the size of the app's window while it runs. Don't ask which device
/// you're on — ask how much space you have:
/// - `horizontalSizeClass` for coarse layout decisions,
/// - `onGeometryChange(for:of:action:)` for the exact container size.
///
/// The photo grid below picks its column count from the available width,
/// so it works the same when folded, unfolded, in Split View or in Stage Manager.
struct FoldedUnfoldedExample: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var containerSize: CGSize = .zero

    private var columnCount: Int {
        max(2, Int(containerSize.width / 160))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                metrics

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount),
                    spacing: 8
                ) {
                    ForEach(0..<36, id: \.self) { index in
                        PhotoTile(index: index)
                    }
                }
                .animation(.smooth, value: columnCount)
            }
            .padding()
        }
        // 👇 The API: track the exact size of the container.
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            containerSize = newSize
        }
    }

    private var metrics: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                MetricTile(title: "Width", value: Int(containerSize.width).formatted(), symbol: "arrow.left.and.right")
                MetricTile(title: "Height", value: Int(containerSize.height).formatted(), symbol: "arrow.up.and.down")
            }
            GridRow {
                MetricTile(title: "Horizontal", value: horizontalSizeClass.title, symbol: "rectangle.split.2x1")
                MetricTile(title: "Vertical", value: verticalSizeClass.title, symbol: "rectangle.split.1x2")
            }
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.green.opacity(0.12), in: .rect(cornerRadius: 16))
    }
}

private struct PhotoTile: View {
    let index: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hue: Double(index % 12) / 12, saturation: 0.45, brightness: 0.9).gradient)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: ["leaf", "mountain.2", "sun.max", "cloud", "drop", "flame"][index % 6])
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.85))
            }
    }
}

private extension Optional where Wrapped == UserInterfaceSizeClass {
    var title: String {
        switch self {
        case .compact: "Compact"
        case .regular: "Regular"
        default: "Unknown"
        }
    }
}

#Preview {
    FoldedUnfoldedExample()
}
