import SwiftUI

/// Writes a custom arrangement style that puts each view on its own side of the fold.
///
/// `ArrangementView` delegates layout to its style. The built-in styles are `.split`,
/// `.overlay`, and `.automatic`. To build your own, conform to `ArrangementViewStyle` and
/// place `configuration.primary` and `configuration.secondary` in `makeBody(configuration:)`.
///
/// The custom `FoldArrangementStyle` below reads the division region, inactive ones
/// included, and gives each view one side of the fold. Without a fold, for example on the
/// cover display, it stacks the views and gives the primary view more room.
///
/// The configuration doesn't tell you where the fold is. A style is a regular view, so
/// it reads the reserved regions itself, with a `GeometryReader`.
struct CustomArrangementExample: View {
    @State private var style: StyleOption = .fold

    var body: some View {
        arrangement
            .safeAreaInset(edge: .bottom) {
                Picker("Style", selection: $style) {
                    ForEach(StyleOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .glassEffect(in: .capsule)
                .padding()
                .frame(maxWidth: 480)
            }
    }

    @ViewBuilder
    private var arrangement: some View {
        let view = ArrangementView {
            Pane(title: "Primary", symbol: "list.bullet", color: .teal)
        } secondary: {
            Pane(title: "Secondary", symbol: "doc.richtext", color: .indigo)
        }

        switch style {
        // 👇 The API: apply the custom style like any built-in one.
        case .fold: view.arrangementViewStyle(.fold)
        case .split: view.arrangementViewStyle(.split)
        case .overlay: view.arrangementViewStyle(.overlay)
        case .automatic: view.arrangementViewStyle(.automatic)
        }
    }
}

// MARK: - Custom style

/// Gives each view one side of the fold. Stacks them when there's no fold.
struct FoldArrangementStyle: ArrangementViewStyle {
    var stackedPrimaryRatio = 0.6

    // 👇 The API: lay out the primary and secondary views yourself.
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { proxy in
            let fold = proxy.reservedRegions(kind: .division, options: [.includeInactive]).first?.frame

            if let fold, fold.height >= fold.width {
                // A vertical fold: one view on each side, the fold's frame as the gap.
                HStack(spacing: 0) {
                    configuration.primary
                        .frame(width: max(fold.minX, 0))
                    Spacer(minLength: fold.width)
                    configuration.secondary
                        .frame(width: max(proxy.size.width - fold.maxX, 0))
                }
            } else if let fold {
                // A horizontal fold: primary above, secondary below.
                VStack(spacing: 0) {
                    configuration.primary
                        .frame(height: max(fold.minY, 0))
                    Spacer(minLength: fold.height)
                    configuration.secondary
                        .frame(height: max(proxy.size.height - fold.maxY, 0))
                }
            } else {
                VStack(spacing: 0) {
                    configuration.primary
                        .frame(height: proxy.size.height * stackedPrimaryRatio)
                    configuration.secondary
                }
            }
        }
    }
}

extension ArrangementViewStyle where Self == FoldArrangementStyle {
    /// Gives each view one side of the fold.
    static var fold: FoldArrangementStyle { FoldArrangementStyle() }
}

// MARK: - Demo

private enum StyleOption: String, CaseIterable, Identifiable {
    case fold, split, overlay, automatic

    var id: Self { self }

    var title: String {
        switch self {
        case .fold: "Custom"
        case .split: "Split"
        case .overlay: "Overlay"
        case .automatic: "Automatic"
        }
    }
}

private struct Pane: View {
    let title: String
    let symbol: String
    let color: Color

    var body: some View {
        ViewThatFits(in: .vertical) {
            content(showsIcon: true)
            content(showsIcon: false)
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.gradient, in: .rect(cornerRadius: 28))
        .padding(6)
    }

    private func content(showsIcon: Bool) -> some View {
        VStack(spacing: 12) {
            if showsIcon {
                Image(systemName: symbol)
                    .font(.system(size: 44, weight: .semibold))
            }
            Text(title)
                .font(.title2.bold())
        }
    }
}

#Preview {
    CustomArrangementExample()
}
