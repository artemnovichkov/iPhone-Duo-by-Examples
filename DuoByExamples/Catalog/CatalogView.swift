import SwiftUI

/// The root of the app: a sidebar with every example and a detail column for the selected one.
///
/// On a folded iPhone Duo the split view collapses into a single navigation stack;
/// unfold the device and the sidebar and detail appear side by side.
struct CatalogView: View {
    // Pass `-example <name>` as a launch argument to open an example directly, e.g. `-example hingeAngle`.
    @State private var selection: Example? = UserDefaults.standard.string(forKey: "example").flatMap(Example.init)
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                CatalogHeader()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                ForEach(ExampleSection.allCases) { section in
                    Section(section.rawValue) {
                        ForEach(section.examples) { example in
                            NavigationLink(value: example) {
                                ExampleRow(example: example)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Duo by Examples")
        } detail: {
            if let selection {
                ExampleScreen(example: selection)
            } else {
                ContentUnavailableView(
                    "Pick an Example",
                    systemImage: "iphone.gen3",
                    description: Text("Choose an example from the sidebar to explore an iPhone Duo API.")
                )
            }
        }
        // Most examples are about the whole screen, so give them all of it.
        .onChange(of: selection, initial: true) {
            columnVisibility = selection == nil ? .all : .detailOnly
        }
    }
}

private struct ExampleRow: View {
    let example: Example

    var body: some View {
        HStack(spacing: 14) {
            ExampleIcon(example: example)
            VStack(alignment: .leading, spacing: 2) {
                Text(example.title)
                    .font(.headline)
                Text(example.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

/// A banner at the top of the catalog. It already uses the hinge API
/// to show the live state of the device.
private struct CatalogHeader: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SwiftUI APIs for the foldable iPhone, one example at a time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HingeBadge(hinge: hinge)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .onHingeChange { _, newContext in
            hinge = newContext.hinge
        }
    }
}

#Preview {
    CatalogView()
}
