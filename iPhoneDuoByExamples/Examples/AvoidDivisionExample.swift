import SwiftUI

/// Lays out a two-page reader so that no text falls into the fold.
///
/// A `.division` region marks where content should split into two separate areas.
/// This example reads the first division region and places one page on each side of it.
/// When there's no division — the device is folded, or the app runs elsewhere —
/// it falls back to a single page.
struct AvoidDivisionExample: View {
    @State private var respectInactive = true

    var body: some View {
        GeometryReader { proxy in
            let options: ReservedRegion.QueryOptions = respectInactive ? [.includeInactive] : []
            // 👇 The API: find where the content should divide.
            let division = proxy.reservedRegions(kind: .division, options: options).first

            BookLayout(size: proxy.size, division: division?.frame)
                .animation(.smooth, value: division?.frame)
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.91))
        .safeAreaInset(edge: .bottom) {
            Toggle("Respect inactive regions", isOn: $respectInactive)
                .padding()
                .glassEffect(in: .capsule)
                .padding()
                .frame(maxWidth: 420)
        }
    }
}

/// Positions the pages around an optional division rect.
private struct BookLayout: View {
    let size: CGSize
    let division: CGRect?

    var body: some View {
        if let division, division.height >= division.width {
            // A vertical fold: pages on the left and right.
            HStack(spacing: 0) {
                Page(number: 1)
                    .frame(width: max(division.minX, 0))
                FoldGap()
                    .frame(width: division.width)
                Page(number: 2)
                    .frame(width: max(size.width - division.maxX, 0))
            }
        } else if let division {
            // A horizontal fold: pages on the top and bottom.
            VStack(spacing: 0) {
                Page(number: 1)
                    .frame(height: max(division.minY, 0))
                FoldGap()
                    .frame(height: division.height)
                Page(number: 2)
                    .frame(height: max(size.height - division.maxY, 0))
            }
        } else {
            Page(number: 1)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct FoldGap: View {
    var body: some View {
        LinearGradient(
            colors: [.black.opacity(0), .black.opacity(0.08), .black.opacity(0)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private struct Page: View {
    let number: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if number == 1 {
                    Text("Chapter One")
                        .font(.system(.largeTitle, design: .serif).bold())
                }
                Text(number == 1 ? Self.first : Self.second)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                Text("\(number)")
                    .font(.system(.footnote, design: .serif))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            .padding(24)
        }
        .foregroundStyle(.black.opacity(0.85))
    }

    private static let first = """
    The phone lay open on the table like a small book. Its two halves caught the morning light at slightly different angles, and the crease between them was barely visible — but it was there, and the app knew it.

    Instead of running a paragraph straight across the fold, the layout asked the system where the division was and simply stepped around it. Page one ended just before the crease.
    """

    private static let second = """
    Page two began just after it. Nothing was hidden, nothing was split mid-word, and the reader never had to think about the hardware at all.

    When the phone was folded shut again, the division region disappeared, and the two pages quietly became one. Good adaptive layout is mostly invisible.
    """
}

#Preview {
    AvoidDivisionExample()
}
