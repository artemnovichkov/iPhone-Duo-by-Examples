import SwiftUI

/// Wraps an example with a title and an info sheet that lists the APIs it demonstrates.
struct ExampleScreen: View {
    let example: Example
    @State private var isInfoPresented = false

    var body: some View {
        example.destination
            .navigationTitle(example.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("About", systemImage: "info.circle") {
                        isInfoPresented = true
                    }
                }
            }
            .sheet(isPresented: $isInfoPresented) {
                ExampleInfoSheet(example: example)
                    .presentationDetents([.medium, .large])
            }
    }
}

private struct ExampleInfoSheet: View {
    let example: Example
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ExampleIcon(example: example, size: 52)
                        Text(example.summary)
                            .font(.callout)
                    }
                    .padding(.vertical, 4)
                }
                Section("APIs") {
                    ForEach(example.apis, id: \.self) { api in
                        Text(api)
                            .font(.callout.monospaced())
                    }
                }
                Section {
                    Link(destination: Repository.sourceURL(for: example)) {
                        Label("View Source on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .navigationTitle(example.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                }
            }
        }
    }
}

enum Repository {
    static let url = URL(string: "https://github.com/artemnovichkov/iPhone-Duo-by-Examples")!

    static func sourceURL(for example: Example) -> URL {
        url.appending(path: "blob/main").appending(path: example.sourcePath)
    }
}
