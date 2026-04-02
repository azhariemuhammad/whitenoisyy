import SwiftUI

@main
struct LiteRainApp: App {
    @StateObject private var audioEngine = PinkNoiseEngine()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioEngine)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                audioEngine.persistState()
            }
        }
    }
}
