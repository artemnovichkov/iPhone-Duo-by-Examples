import SwiftUI

/// Finds out which half of the inner display a Split View window is on.
///
/// On the unfolded iPhone Duo, two windows can share the inner display, one on each side
/// of the fold. A window always starts at `(0, 0)` in its own coordinate space, so its
/// geometry alone doesn't tell you which half it got. The reserved regions do:
/// - The division region of the fold is still reported, as an inactive region, at the edge
///   of the window that faces the fold. At the trailing edge, the window is on the left half;
///   at the leading edge, it's on the right half. In a full-width window, the fold is in the
///   middle.
/// - Pass `layoutDirectionBehavior: .fixed` to get physical coordinates, so left stays left
///   in right-to-left languages.
/// - `toolbarVerticalEdge` is a second signal: the system puts the vertical bar on the edge
///   away from the fold.
///
/// Both windows run in one process, so they can share state through a plain `@Observable`
/// object. Change the color in one window and watch the other follow.
struct SplitViewSideExample: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.toolbarVerticalEdge) private var verticalBarEdge
    @Bindable private var shared = SharedWindowState.shared

    var body: some View {
        GeometryReader { proxy in
            // 👇 The API: physical coordinates, inactive regions included.
            let fold = proxy.reservedRegions(
                kind: .division,
                options: [.includeInactive],
                layoutDirectionBehavior: .fixed
            ).first?.frame
            let position = WindowPosition(fold: fold, size: proxy.size)

            ScrollView {
                VStack(spacing: 24) {
                    PositionCard(position: position, hue: shared.hue)

                    VStack(alignment: .leading, spacing: 12) {
                        SignalRow(title: "Fold frame", value: fold.map(format) ?? "none")
                        SignalRow(title: "Window size", value: "\(Int(proxy.size.width)) × \(Int(proxy.size.height))")
                        SignalRow(title: "Vertical bar edge", value: verticalBarEdge.title)
                    }
                    .padding()
                    .background(.fill.quaternary, in: .rect(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shared Between Windows")
                            .font(.headline)
                        Slider(value: $shared.hue, in: 0...1) {
                            Text("Color")
                        }
                        Text("Both windows read the same @Observable object.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.fill.quaternary, in: .rect(cornerRadius: 20))

                    if supportsMultipleWindows {
                        Button("Open Another Window", systemImage: "plus.rectangle.on.rectangle") {
                            // 👇 The API: open this example in a new window.
                            openWindow(value: Example.splitViewSide)
                        }
                        .buttonStyle(.glassProminent)
                    }

                    Text("Unfold the device and open a second window. Then use Split View to put the two windows side by side.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .animation(.smooth, value: position)
        }
    }

    private func format(_ rect: CGRect) -> String {
        "(\(Int(rect.minX)), \(Int(rect.minY)), \(Int(rect.width)) × \(Int(rect.height)))"
    }
}

// MARK: - Position

/// Where the window is, derived from the frame of the fold.
enum WindowPosition: Equatable {
    case noFold
    case fullWidth
    case left, right, top, bottom

    init(fold: CGRect?, size: CGSize) {
        guard let fold, size.width > 0, size.height > 0 else {
            self = .noFold
            return
        }
        if fold.height >= fold.width {
            // A vertical fold. Near an edge, the window is one half of a Split View.
            let x = fold.midX / size.width
            self = x > 0.75 ? .left : x < 0.25 ? .right : .fullWidth
        } else {
            let y = fold.midY / size.height
            self = y > 0.75 ? .top : y < 0.25 ? .bottom : .fullWidth
        }
    }

    var title: String {
        switch self {
        case .noFold: "OUTSIDE"
        case .fullWidth: "INSIDE"
        case .left: "LEFT"
        case .right: "RIGHT"
        case .top: "TOP"
        case .bottom: "BOTTOM"
        }
    }

    var detail: String {
        switch self {
        case .noFold: "No division region: the cover display, or not an iPhone Duo."
        case .fullWidth: "The fold runs through the middle of this window."
        case .left, .top: "The fold is at the far edge of this window."
        case .right, .bottom: "The fold is at the near edge of this window."
        }
    }

    var symbol: String {
        switch self {
        case .noFold: "iphone.gen3"
        case .fullWidth: "rectangle.split.2x1"
        case .left: "rectangle.lefthalf.filled"
        case .right: "rectangle.righthalf.filled"
        case .top: "rectangle.tophalf.filled"
        case .bottom: "rectangle.bottomhalf.filled"
        }
    }
}

private struct PositionCard: View {
    let position: WindowPosition
    let hue: Double

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: position.symbol)
                .font(.system(size: 56))
                .contentTransition(.symbolEffect(.replace))
            Text(position.title)
                .font(.system(size: 56, weight: .black, design: .rounded))
                .contentTransition(.interpolate)
            Text(position.detail)
                .font(.callout)
                .multilineTextAlignment(.center)
                .opacity(0.85)
        }
        .foregroundStyle(.white)
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color(hue: hue, saturation: 0.6, brightness: 0.8).gradient, in: .rect(cornerRadius: 28))
    }
}

private struct SignalRow: View {
    let title: String
    let value: String

    var body: some View {
        LabeledContent(title) {
            Text(value)
                .font(.callout.monospaced())
        }
    }
}

// MARK: - Shared state

/// State shared by every window of the app. Windows are scenes in one process,
/// so a single object is all they need to talk to each other.
@Observable
final class SharedWindowState {
    static let shared = SharedWindowState()

    var hue = 0.75
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

#Preview {
    SplitViewSideExample()
}
