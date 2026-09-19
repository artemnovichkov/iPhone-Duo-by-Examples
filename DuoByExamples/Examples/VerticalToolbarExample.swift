import SwiftUI

/// Controls the vertical bar — the bar that hosts the status bar, tab bar and toolbar items
/// along the side of an unfolded iPhone Duo.
///
/// - `toolbarVerticalBehavior(_:)` opts a screen out of the vertical bar. Use `.disabled` only for
///   UIs better served by horizontal bars, like a full-screen video player, and treat it as
///   a stable choice rather than toggling it with view state.
/// - `toolbarVerticalCompressionBehavior(_:)` decides what compresses first when the tab bar
///   and toolbar items share the vertical bar and space runs out.
/// - `axisBehavior(_:)` on toolbar content chooses whether an item may move into the vertical bar.
/// - `toolbarVerticalEdge` in the environment tells you which edge the bar is on, or `nil`.
/// - `visibilityPriority(_:)`, `.topBarPinnedTrailing` and `ToolbarOverflowMenu` decide which
///   items stay visible when the vertical bar runs out of room.
///
/// Give every item both a title and a symbol, so the system can pick the right
/// representation for horizontal and vertical bars.
///
/// The demo is presented full screen, because the vertical bar configuration flows up
/// to the window or the nearest presentation.
struct VerticalToolbarExample: View {
    @State private var isDemoPresented = false
    @State private var configuration = VerticalBarConfiguration()

    var body: some View {
        Form {
            Section {
                Toggle("Allow vertical bar", isOn: $configuration.isVerticalBarEnabled)
                Picker("Compression", selection: $configuration.compression) {
                    ForEach(CompressionOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Picker("Item axis behavior", selection: $configuration.itemAxis) {
                    ForEach(ItemAxisOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } header: {
                Text("Configuration")
            } footer: {
                Text("The vertical bar appears on the outer display and on the inner display in landscape. Launch the demo to see it with a tab bar and toolbar items.")
            }

            Section {
                Button("Launch Demo", systemImage: "play.rectangle") {
                    isDemoPresented = true
                }
            }

            Section("This screen") {
                VerticalEdgeRow()
            }
        }
        .fullScreenCover(isPresented: $isDemoPresented) {
            VerticalBarDemo(configuration: configuration)
        }
    }
}

// MARK: - Configuration

struct VerticalBarConfiguration {
    var isVerticalBarEnabled = true
    var compression: CompressionOption = .automatic
    var itemAxis: ItemAxisOption = .automatic
}

enum CompressionOption: String, CaseIterable, Identifiable {
    case automatic, prefersToolbarItems, prefersTabBar

    var id: Self { self }

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .prefersToolbarItems: "Prefers Toolbar Items"
        case .prefersTabBar: "Prefers Tab Bar"
        }
    }

    var value: ToolbarVerticalCompressionBehavior {
        switch self {
        case .automatic: .automatic
        case .prefersToolbarItems: .prefersToolbarItems
        case .prefersTabBar: .prefersTabBar
        }
    }
}

enum ItemAxisOption: String, CaseIterable, Identifiable {
    case automatic, verticalPreferred, horizontalOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .verticalPreferred: "Vertical Preferred"
        case .horizontalOnly: "Horizontal Only"
        }
    }

    var value: ToolbarItemAxisBehavior {
        switch self {
        case .automatic: .automatic
        case .verticalPreferred: .verticalPreferred
        case .horizontalOnly: .horizontalOnly
        }
    }
}

// MARK: - Demo

private struct VerticalBarDemo: View {
    let configuration: VerticalBarConfiguration

    var body: some View {
        TabView {
            Tab("Inbox", systemImage: "tray") {
                DemoScreen(title: "Inbox", configuration: configuration)
            }
            Tab("Drafts", systemImage: "doc") {
                DemoScreen(title: "Drafts", configuration: configuration)
            }
            Tab("Sent", systemImage: "paperplane") {
                DemoScreen(title: "Sent", configuration: configuration)
            }
            Tab("Archive", systemImage: "archivebox") {
                DemoScreen(title: "Archive", configuration: configuration)
            }
        }
        // 👇 The API: opt in or out of the vertical bar for this presentation.
        .toolbarVerticalBehavior(configuration.isVerticalBarEnabled ? .automatic : .disabled)
    }
}

private struct DemoScreen: View {
    let title: String
    let configuration: VerticalBarConfiguration
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VerticalEdgeRow()
                }
                Section("Messages") {
                    ForEach(1...20, id: \.self) { index in
                        Label("Message \(index)", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
                // 👇 The API: a prominent action that stays pinned instead of overflowing.
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button("Compose", systemImage: "square.and.pencil") {}
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Search", systemImage: "magnifyingglass") {}
                }
                // 👇 The API: keep this item visible longer when space runs out.
                .visibilityPriority(.high)
                // 👇 The API: whether the item may move into the vertical bar.
                .axisBehavior(configuration.itemAxis.value)

                ToolbarItem(placement: .primaryAction) {
                    Button("Unread", systemImage: "envelope.badge") {}
                        .badge(7)
                }
                .axisBehavior(configuration.itemAxis.value)

                // 👇 The API: secondary actions go straight into the overflow menu.
                ToolbarOverflowMenu {
                    Button("Mark All as Read", systemImage: "envelope.open") {}
                    Button("Select Messages", systemImage: "checkmark.circle") {}
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Flag", systemImage: "flag") {}
                    Button("Move", systemImage: "folder") {}
                    Button("Delete", systemImage: "trash") {}
                }
                .axisBehavior(configuration.itemAxis.value)
            }
            // 👇 The API: which items compress first when space in the vertical bar runs out.
            .toolbarVerticalCompressionBehavior(configuration.compression.value)
        }
    }
}

/// Shows the edge of the vertical bar from the environment.
private struct VerticalEdgeRow: View {
    // 👇 The API: `nil` when the system doesn't place a vertical bar.
    @Environment(\.toolbarVerticalEdge) private var edge

    var body: some View {
        LabeledContent("Vertical bar edge") {
            Text(edgeTitle)
                .monospaced()
        }
    }

    private var edgeTitle: String {
        switch edge {
        case .leading: "leading"
        case .trailing: "trailing"
        case nil: "none"
        }
    }
}

#Preview {
    VerticalToolbarExample()
}
