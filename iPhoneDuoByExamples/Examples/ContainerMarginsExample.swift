import SwiftUI

/// Aligns content to the container's margins with `ContentMarginGuide.container`.
///
/// A hard-coded `padding()` knows nothing about the container it lives in.
/// `contentMargins(for: .container, edges:alignment:)` insets a view by the margins the
/// container recommends, so the content lines up with system components and adapts when
/// the container changes — for example when the device unfolds or the vertical bar appears.
///
/// `GeometryProxy.contentMargins(for:edges:)` returns the same margins as `EdgeInsets`
/// if you need the raw values.
struct ContainerMarginsExample: View {
    @State private var useContainerMargins = true

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                // 👇 The API: read the container margins as values.
                let margins = proxy.contentMargins(for: .container)

                ZStack {
                    MarginsVisualization(margins: margins, size: proxy.size)
                    content(margins: margins)
                }
            }

            Toggle("Use container margins", isOn: $useContainerMargins.animation(.smooth))
                .padding()
                .glassEffect(in: .capsule)
                .padding()
                .frame(maxWidth: 420)
        }
    }

    @ViewBuilder
    private func content(margins: EdgeInsets) -> some View {
        let card = CardStack(margins: margins, useContainerMargins: useContainerMargins)
        if useContainerMargins {
            // 👇 The API: inset content by the container's margins.
            card.contentMargins(for: .container)
        } else {
            card.padding(8)
        }
    }
}

private struct CardStack: View {
    let margins: EdgeInsets
    let useContainerMargins: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(useContainerMargins ? "contentMargins(for: .container)" : "padding(8)")
                .font(.headline.monospaced())
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                GridRow { Text("top"); Text(margins.top, format: .number.precision(.fractionLength(0))) }
                GridRow { Text("leading"); Text(margins.leading, format: .number.precision(.fractionLength(0))) }
                GridRow { Text("bottom"); Text(margins.bottom, format: .number.precision(.fractionLength(0))) }
                GridRow { Text("trailing"); Text(margins.trailing, format: .number.precision(.fractionLength(0))) }
            }
            .font(.callout.monospaced())
            .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.orange.opacity(0.15), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.orange, lineWidth: 2)
        }
    }
}

/// Draws the margin area as hatched bands around the container.
private struct MarginsVisualization: View {
    let margins: EdgeInsets
    let size: CGSize

    var body: some View {
        Rectangle()
            .fill(.orange.opacity(0.12))
            .overlay {
                Rectangle()
                    .fill(.background)
                    .padding(margins)
            }
            .overlay {
                Rectangle()
                    .strokeBorder(.orange.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .padding(margins)
            }
            .allowsHitTesting(false)
    }
}

#Preview {
    ContainerMarginsExample()
}
