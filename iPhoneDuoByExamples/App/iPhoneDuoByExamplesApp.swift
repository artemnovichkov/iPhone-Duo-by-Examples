import SwiftUI

@main
struct iPhoneDuoByExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView()
        }

        // A window with a single example, opened with `openWindow(value:)`.
        // The Split View Side example uses it to put a second window next to the first.
        WindowGroup(for: Example.self) { $example in
            if let example {
                NavigationStack {
                    ExampleScreen(example: example)
                }
            }
        }
    }
}
