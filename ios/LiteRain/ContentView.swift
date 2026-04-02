import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioEngine: PinkNoiseEngine

    var body: some View {
        ZStack {
            Color(red: 15 / 255, green: 15 / 255, blue: 19 / 255)
                .ignoresSafeArea()

            RainBackground()
                .allowsHitTesting(false)
                .opacity(0.65)

            VStack(spacing: 24) {
                Text(audioEngine.isPlaying ? "Raining" : "Tap to Start")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.white.opacity(0.75))

                Button(action: {
                    audioEngine.togglePlayback()
                    Haptics.tap()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.14), lineWidth: 2)
                            )
                            .frame(width: 110, height: 110)

                        Image(systemName: audioEngine.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: audioEngine.isPlaying ? 0 : 2)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(audioEngine.isPlaying ? "Pause rain sound" : "Play rain sound")
                .accessibilityHint("Double tap to toggle playback")

                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { audioEngine.volume },
                        set: { audioEngine.setVolume($0, persist: true) }
                    ), in: 0...1)
                    .tint(Color.white.opacity(0.8))
                    .opacity(audioEngine.isPlaying ? 1 : 0.35)
                    .disabled(!audioEngine.isPlaying)
                    .accessibilityLabel("Volume")

                    Text("Headphones Recommended")
                        .font(.footnote)
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                .frame(maxWidth: 300)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            audioEngine.restoreStateAndApply()
        }
    }
}

private struct RainBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RainLayer(duration: 0.8, opacity: 0.55, lineWidth: 1, spacing: 10)
                RainLayer(duration: 1.2, opacity: 0.35, lineWidth: 1, spacing: 14)
                RainLayer(duration: 1.8, opacity: 0.2, lineWidth: 2, spacing: 18)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

private struct RainLayer: View {
    let duration: Double
    let opacity: Double
    let lineWidth: CGFloat
    let spacing: CGFloat
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            var x: CGFloat = 0
            while x < size.width + spacing {
                var path = Path()
                path.move(to: CGPoint(x: x, y: -size.height))
                path.addLine(to: CGPoint(x: x, y: size.height * 2))
                context.stroke(
                    path,
                    with: .color(Color.white.opacity(opacity)),
                    lineWidth: lineWidth
                )
                x += spacing
            }
        }
        .rotationEffect(.degrees(12))
        .offset(y: animate ? sizeShift : -sizeShift)
        .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: animate)
        .onAppear { animate = true }
    }

    private var sizeShift: CGFloat { 180 }
}

#Preview {
    ContentView()
        .environmentObject(PinkNoiseEngine())
        .preferredColorScheme(.dark)
}
