import SwiftUI

/// Switches between layouts based on `DeviceHinge.Status`.
///
/// When the device is partially open it can stand on a table like a small laptop.
/// This example turns into a "tabletop" media player in that posture: artwork on the
/// upper half, playback controls on the lower half. In every other status it shows
/// a regular single-column player.
///
/// Prefer `status` over `angle` when you only need to know the posture:
/// angle updates are throttled by the system and their precision can change.
struct HingeStatusExample: View {
    @State private var status: DeviceHinge.Status?
    @State private var isPlaying = true
    @State private var progress = 0.35

    var body: some View {
        Group {
            if status == .partiallyOpen {
                tabletopLayout
            } else {
                regularLayout
            }
        }
        .animation(.smooth, value: status)
        // 👇 The API: we only care about the status, not the precise angle.
        .onHingeChange { oldContext, newContext in
            guard oldContext.hinge?.status != newContext.hinge?.status else { return }
            status = newContext.hinge?.status
        }
    }

    // MARK: Layouts

    /// Content on the upper half, controls on the lower half — split at the fold.
    private var tabletopLayout: some View {
        VStack(spacing: 0) {
            Artwork()
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            VStack(spacing: 24) {
                Label("Tabletop mode", systemImage: "laptopcomputer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                trackInfo
                controls
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.fill.quinary)
        }
        .transition(.blurReplace)
    }

    private var regularLayout: some View {
        VStack(spacing: 32) {
            Artwork()
                .frame(maxWidth: 360)
            trackInfo
            controls
            Text("Fold the device partially to switch to tabletop mode.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.blurReplace)
    }

    // MARK: Pieces

    private var trackInfo: some View {
        VStack(spacing: 4) {
            Text("Hinge Blues")
                .font(.title2.bold())
            Text("The Foldables")
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        VStack(spacing: 20) {
            Slider(value: $progress)
                .tint(.indigo)
            HStack(spacing: 48) {
                Button("Previous", systemImage: "backward.fill") {}
                Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                    isPlaying.toggle()
                }
                .font(.largeTitle)
                .contentTransition(.symbolEffect(.replace))
                Button("Next", systemImage: "forward.fill") {}
            }
            .labelStyle(.iconOnly)
            .font(.title)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 420)
    }
}

private struct Artwork: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                MeshGradient(
                    width: 2,
                    height: 2,
                    points: [[0, 0], [1, 0], [0, 1], [1, 1]],
                    colors: [.indigo, .purple, .pink, .orange]
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }
}

#Preview {
    HingeStatusExample()
}
