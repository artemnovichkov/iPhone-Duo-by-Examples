import AVFoundation
import SwiftUI

/// Shows a second scene on the cover display while the camera runs on the inner display.
///
/// When someone takes a photo of another person with the unfolded iPhone Duo, the cover
/// display faces that person. A **scene accessory** lets your app put content there:
/// - `sceneAccessory(content:)` attaches accessories to a view's scene.
/// - `CameraCaptureAccessory` is offered by the system while your app is full screen on the
///   inner display and an `AVCaptureSession` is running. Its content appears on the cover
///   display as a separate scene of the same process, so it shares your app's state.
/// - `onAvailabilityChange(perform:)` tells you when the system offers the accessory, and
///   the `isEnabled` binding lets you turn it on and off.
///
/// On a device, the system offers the accessory while the camera captures. The simulator
/// has no camera and offers the accessory without a running session, so you can still try
/// the cover display there.
///
/// For non-interactive content on an external display, use `ExternalNonInteractiveAccessory`
/// in the same way.
struct CoverAccessoryExample: View {
    @State private var camera = CameraSession()
    @State private var isAccessoryAvailable = false
    @State private var isAccessoryEnabled = true
    @State private var message: SubjectMessage = .smile
    @State private var countdown: Int?
    @State private var shotCount = 0

    var body: some View {
        Form {
            Section {
                Viewfinder(countdown: countdown)
                    .listRowInsets(EdgeInsets())
            }

            Section {
                LabeledContent("Camera", value: camera.state.title)
                StatusRow(title: "Accessory available", isOn: isAccessoryAvailable)
                Toggle("Show on cover display", isOn: $isAccessoryEnabled)
            } header: {
                Text("Cover Display")
            } footer: {
                Text("The system offers the accessory while the app is full screen on the unfolded device and the camera captures. Fold the device and it goes away: the cover display is now the main display.")
            }

            Section("Message for the Subject") {
                Picker("Message", selection: $message) {
                    ForEach(SubjectMessage.allCases) { message in
                        Text(message.title).tag(message)
                    }
                }
                .pickerStyle(.segmented)
                Button("Take Photo in 3 Seconds", systemImage: "timer") {
                    Task { await runCountdown() }
                }
                .disabled(countdown != nil)
            }
        }
        // 👇 The API: content for the cover display, shown while the camera runs.
        .sceneAccessory {
            CameraCaptureAccessory(isEnabled: $isAccessoryEnabled) {
                // A separate scene, but the same process: it reads the same state.
                SubjectView(message: message, countdown: countdown, shotCount: shotCount)
            }
            // 👇 The API: the system tells you when it can show the accessory.
            .onAvailabilityChange { isAvailable in
                isAccessoryAvailable = isAvailable
            }
        }
        .task {
            await camera.start()
        }
        .onDisappear {
            camera.stop()
        }
    }

    private func runCountdown() async {
        for value in stride(from: 3, through: 1, by: -1) {
            countdown = value
            try? await Task.sleep(for: .seconds(1))
        }
        countdown = 0
        shotCount += 1
        try? await Task.sleep(for: .seconds(1))
        countdown = nil
    }
}

// MARK: - Camera

/// Runs an `AVCaptureSession`. On a device, capturing is what makes the accessory available.
@Observable
final class CameraSession {
    enum State {
        case idle, running, noCamera, denied

        var title: String {
            switch self {
            case .idle: "Idle"
            case .running: "Running"
            case .noCamera: "No camera"
            case .denied: "No access"
            }
        }
    }

    private(set) var state: State = .idle
    private let session = SessionBox()

    func start() async {
        guard AVCaptureDevice.default(for: .video) != nil else {
            state = .noCamera
            return
        }
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            state = .denied
            return
        }
        state = await session.start() ? .running : .idle
    }

    func stop() {
        session.stop()
        state = .idle
    }
}

/// Owns the session and talks to it off the main thread, as AVFoundation recommends.
nonisolated private final class SessionBox: @unchecked Sendable {
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "CoverAccessoryExample.session")

    func start() async -> Bool {
        await withCheckedContinuation { continuation in
            queue.async {
                let session = self.session
                if session.inputs.isEmpty,
                   let device = AVCaptureDevice.default(for: .video),
                   let input = try? AVCaptureDeviceInput(device: device),
                   session.canAddInput(input) {
                    session.addInput(input)
                }
                session.startRunning()
                continuation.resume(returning: session.isRunning)
            }
        }
    }

    func stop() {
        queue.async {
            self.session.stopRunning()
        }
    }
}

// MARK: - Inner display

private struct Viewfinder: View {
    let countdown: Int?

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .indigo, .black], startPoint: .top, endPoint: .bottom)
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 96, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.4))
            if let countdown {
                Text(countdown == 0 ? "📸" : "\(countdown)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
            }
        }
        .frame(height: 220)
        .animation(.smooth, value: countdown)
    }
}

private struct StatusRow: View {
    let title: String
    let isOn: Bool

    var body: some View {
        LabeledContent(title) {
            Label(isOn ? "Yes" : "No", systemImage: isOn ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(isOn ? .green : .secondary)
        }
    }
}

// MARK: - Cover display

/// What the person in front of the camera sees on the cover display.
private struct SubjectView: View {
    let message: SubjectMessage
    let countdown: Int?
    let shotCount: Int

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.purple.gradient)
            VStack(spacing: 16) {
                if let countdown {
                    Text(countdown == 0 ? "📸" : "\(countdown)")
                        .font(.system(size: 140, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(countsDown: true))
                } else {
                    Image(systemName: message.symbol)
                        .font(.system(size: 80))
                    Text(message.title)
                        .font(.largeTitle.bold())
                }
                Text("Photos taken: \(shotCount)")
                    .font(.headline.monospacedDigit())
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
        }
        .ignoresSafeArea()
        .animation(.smooth, value: countdown)
        .animation(.smooth, value: message)
    }
}

private enum SubjectMessage: String, CaseIterable, Identifiable {
    case smile, lookUp, wave

    var id: Self { self }

    var title: String {
        switch self {
        case .smile: "Smile!"
        case .lookUp: "Look Up"
        case .wave: "Wave!"
        }
    }

    var symbol: String {
        switch self {
        case .smile: "face.smiling"
        case .lookUp: "arrow.up.circle"
        case .wave: "hand.wave"
        }
    }
}

#Preview {
    CoverAccessoryExample()
}
