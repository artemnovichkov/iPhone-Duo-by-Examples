import SwiftUI

/// Three common dual-pane layouts, each built with `ArrangementView`.
///
/// Foldables and dual-screen devices share a few layout patterns. With `ArrangementView`,
/// each one comes down to a style and a sizing modifier:
/// - **List–detail.** A mailbox and a message, with `.split`. The list takes an ideal share
///   of the width, but never less than a minimum, with
///   `splitArrangementLayoutRatio(minHorizontal:idealHorizontal:)`. In book pose, the
///   divider moves to the fold.
/// - **Companion pane.** A canvas and its tool palette, with `.split`. The palette asks for a
///   width in points with `splitArrangementLayoutSize(minWidth:idealWidth:maxWidth:)`, and
///   `splitArrangementFixedLayoutSize(horizontal:vertical:)` keeps it at its ideal width,
///   even in book pose. With `.split.axes(.horizontal)`, the palette hides when it doesn't fit
///   next to the canvas, as on the cover display.
/// - **Extended canvas.** A map with a floating search card, with `.overlay`. The `.axes(_:)`
///   modifier limits the side-by-side layout to the horizontal axis.
///
/// Fold and unfold the device to see each pattern adapt.
struct DualPanePatternsExample: View {
    @State private var pattern: Pattern = .listDetail

    var body: some View {
        Group {
            switch pattern {
            case .listDetail: ListDetailPattern()
            case .companion: CompanionPattern()
            case .extendedCanvas: ExtendedCanvasPattern()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Picker("Pattern", selection: $pattern) {
                ForEach(Pattern.allCases) { pattern in
                    Text(pattern.title).tag(pattern)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .glassEffect(in: .capsule)
            .padding()
            .frame(maxWidth: 480)
        }
    }
}

private enum Pattern: String, CaseIterable, Identifiable {
    case listDetail, companion, extendedCanvas

    var id: Self { self }

    var title: String {
        switch self {
        case .listDetail: "List–Detail"
        case .companion: "Companion"
        case .extendedCanvas: "Canvas"
        }
    }
}

// MARK: - List–detail

private struct ListDetailPattern: View {
    @State private var selection: Int? = 1

    var body: some View {
        ArrangementView {
            List(1...20, id: \.self, selection: $selection) { index in
                VStack(alignment: .leading, spacing: 2) {
                    Text("Message \(index)")
                        .font(.headline)
                    Text("A short preview of the message body…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            // 👇 The API: ideally 40% of the width, at least 30%.
            // Avoid `maxHorizontal` here: in book pose it fights the fold and squeezes the detail pane.
            .splitArrangementLayoutRatio(minHorizontal: 0.3, idealHorizontal: 0.4)
        } secondary: {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Message \(selection ?? 1)")
                        .font(.largeTitle.bold())
                    Text("The detail pane shows the selected message. On a folded device there's room for one pane, so only the primary list stays.")
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.background.secondary)
        }
        // 👇 The API: side by side when both fit along the horizontal axis.
        .arrangementViewStyle(.split.axes(.horizontal))
    }
}

// MARK: - Companion pane

private struct CompanionPattern: View {
    @State private var color: Color = .orange
    private let colors: [Color] = [.orange, .pink, .teal, .indigo, .green]

    var body: some View {
        ArrangementView {
            ZStack {
                Rectangle()
                    .fill(.background.secondary)
                Circle()
                    .fill(color.gradient)
                    .frame(width: 180, height: 180)
            }
        } secondary: {
            VStack(alignment: .leading, spacing: 16) {
                Text("Palette")
                    .font(.headline)
                ForEach(colors, id: \.self) { swatch in
                    Button {
                        withAnimation(.smooth) { color = swatch }
                    } label: {
                        Circle()
                            .fill(swatch.gradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if swatch == color {
                                    Circle().strokeBorder(.primary, lineWidth: 3)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            // 👇 The API: a size in points rather than a share of the container…
            .splitArrangementLayoutSize(minWidth: 120, idealWidth: 160, maxWidth: 240)
            // 👇 The API: …and keep the palette at its ideal width.
            .splitArrangementFixedLayoutSize(horizontal: true, vertical: false)
        }
        // 👇 The API: only side by side. When the palette doesn't fit next to the canvas, it hides.
        .arrangementViewStyle(.split.axes(.horizontal))
    }
}

// MARK: - Extended canvas

private struct ExtendedCanvasPattern: View {
    var body: some View {
        ArrangementView {
            VStack(alignment: .leading, spacing: 12) {
                Label("Search Maps", systemImage: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.fill.tertiary, in: .capsule)
                Text("Nearby")
                    .font(.headline)
                ForEach(["Hinge & Bean", "The Fold", "Crease Café"], id: \.self) { name in
                    Label(name, systemImage: "mappin.circle.fill")
                }
            }
            .padding()
            .frame(maxWidth: 340)
            .glassEffect(in: .rect(cornerRadius: 28))
            .padding()
        } secondary: {
            LinearGradient(colors: [.mint, .teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay {
                    Image(systemName: "map")
                        .font(.system(size: 160, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.35))
                }
        }
        // 👇 The API: an overlay that only goes side by side horizontally.
        .arrangementViewStyle(.overlay.axes(.horizontal))
    }
}

#Preview {
    DualPanePatternsExample()
}
