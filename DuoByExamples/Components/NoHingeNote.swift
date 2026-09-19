import SwiftUI

/// Explains why an example shows placeholder data.
struct NoHingeNote: View {
    var body: some View {
        Label {
            Text("This device doesn't report a hinge. Run the app on the iPhone Duo simulator or device, then fold and unfold it.")
        } icon: {
            Image(systemName: "info.circle.fill")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding()
        .background(.fill.quaternary, in: .rect(cornerRadius: 14))
    }
}
