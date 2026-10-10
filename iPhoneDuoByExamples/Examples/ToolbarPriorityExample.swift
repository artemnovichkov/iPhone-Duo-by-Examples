import SwiftUI

/// Shows which toolbar items stay visible when the vertical bar runs out of room.
///
/// The vertical bar along the side of the iPhone Duo is shorter than a horizontal bar is
/// wide, so items overflow sooner. You decide the order:
/// - `.topBarPinnedTrailing` items never overflow.
/// - `visibilityPriority(_:)` ranks the rest: `.low`, `.automatic`, `.high`, and anything in
///   between with `ToolbarItemVisibilityPriority(higherThan:)` and `(lowerThan:)`.
///   Lower priorities move into the overflow menu first.
/// - `ToolbarOverflowMenu` puts secondary actions straight into the overflow menu.
///
/// Add items with the stepper and watch them overflow, lowest priority first. The vertical
/// bar appears on the cover display and on the inner display in landscape.
struct ToolbarPriorityExample: View {
    @State private var extraItemCount = 4

    var body: some View {
        List {
            Section {
                Stepper("Extra items: \(extraItemCount)", value: $extraItemCount, in: 0...8)
            } footer: {
                Text("Extra items have low priority, so they overflow before the others.")
            }

            Section("Visibility Order") {
                ForEach(PriorityLevel.allCases) { level in
                    Label {
                        VStack(alignment: .leading) {
                            Text(level.title)
                            Text(level.code)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: level.symbol)
                    }
                }
            }
        }
        .toolbar {
            // 👇 The API: pinned items never overflow.
            ToolbarItem(placement: .topBarPinnedTrailing) {
                Button("Compose", systemImage: "square.and.pencil") {}
            }

            ToolbarItem(placement: .primaryAction) {
                Button("Search", systemImage: "magnifyingglass") {}
            }
            // 👇 The API: the last item to overflow among the unpinned ones.
            .visibilityPriority(PriorityLevel.critical.value)

            ToolbarItem(placement: .primaryAction) {
                Button("Share", systemImage: "square.and.arrow.up") {}
            }
            .visibilityPriority(PriorityLevel.high.value)

            ToolbarItem(placement: .primaryAction) {
                Button("Favorite", systemImage: "star") {}
            }
            .visibilityPriority(PriorityLevel.automatic.value)

            ForEach(1..<extraItemCount + 1, id: \.self) { index in
                ToolbarItem(placement: .primaryAction) {
                    Button("Tag \(index)", systemImage: "\(index).circle") {}
                }
                // 👇 The API: these go to the overflow menu first.
                .visibilityPriority(PriorityLevel.low.value)
            }

            // 👇 The API: always in the overflow menu.
            ToolbarOverflowMenu {
                Button("Settings", systemImage: "gear") {}
            }
        }
        .animation(.smooth, value: extraItemCount)
    }
}

private enum PriorityLevel: CaseIterable, Identifiable {
    case pinned, critical, high, automatic, low

    var id: Self { self }

    var title: String {
        switch self {
        case .pinned: "Compose — pinned"
        case .critical: "Search — above high"
        case .high: "Share — high"
        case .automatic: "Favorite — automatic"
        case .low: "Tags — low"
        }
    }

    var code: String {
        switch self {
        case .pinned: ".topBarPinnedTrailing"
        case .critical: ".init(higherThan: .high)"
        case .high: ".high"
        case .automatic: ".automatic"
        case .low: ".low"
        }
    }

    var symbol: String {
        switch self {
        case .pinned: "pin.fill"
        case .critical: "chevron.up.2"
        case .high: "chevron.up"
        case .automatic: "minus"
        case .low: "chevron.down"
        }
    }

    var value: ToolbarItemVisibilityPriority {
        switch self {
        case .pinned, .automatic: .automatic
        case .critical: ToolbarItemVisibilityPriority(higherThan: .high)
        case .high: .high
        case .low: .low
        }
    }
}

#Preview {
    NavigationStack {
        ToolbarPriorityExample()
    }
}
