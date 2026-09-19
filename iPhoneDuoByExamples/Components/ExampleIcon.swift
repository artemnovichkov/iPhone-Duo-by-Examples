import SwiftUI

/// A rounded, tinted SF Symbol tile used to represent an example.
struct ExampleIcon: View {
    let example: Example
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: example.symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(example.tint.gradient, in: .rect(cornerRadius: size * 0.28))
    }
}
