import AVFoundation
import Foundation

final class PinkNoiseEngine {
    private(set) var isPlaying: Bool = false
    private(set) var volume: Double = 0.7

    private let engine = AVAudioEngine()
    private let sourceNode: AVAudioSourceNode
    private let mixer = AVAudioMixerNode()
    private let stateStore = PlaybackStateStore()
    private let queue = DispatchQueue(label: "LiteRain.PinkNoise")
    private let pinkStateLock = NSLock()
    private var pinkState = PinkFilterState()

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            for buffer in ablPointer {
                guard let channelData = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                self.pinkStateLock.lock()
                for frame in 0..<frames {
                    let white = Float.random(in: -1...1)
                    channelData[frame] = self.pinkState.nextSample(white: white)
                }
                self.pinkStateLock.unlock()
            }
            return noErr
        }
        sourceNode.volume = 1.0

        setupAudioSession()

        engine.attach(sourceNode)
        engine.attach(mixer)
        engine.connect(sourceNode, to: mixer, format: format)
        engine.connect(mixer, to: engine.mainMixerNode, format: format)
        mixer.outputVolume = Float(volume)
    }

    func togglePlayback() {
        isPlaying ? pause() : play()
    }

    func play() {
        queue.async {
            self.setupAudioSession()
            if !self.engine.isRunning {
                do {
                    try self.engine.start()
                } catch {
                    return
                }
            }
            DispatchQueue.main.async {
                self.isPlaying = true
                self.persistState()
            }
        }
    }

    func pause() {
        queue.async {
            self.engine.pause()
            DispatchQueue.main.async {
                self.isPlaying = false
                self.persistState()
            }
        }
    }

    func setVolume(_ value: Double, persist: Bool) {
        let clamped = min(max(value, 0), 1)
        DispatchQueue.main.async {
            self.volume = clamped
            self.mixer.outputVolume = Float(clamped)
            if persist {
                self.persistState()
            }
        }
    }

    func restoreStateAndApply() {
        let stored = stateStore.read()
        setVolume(stored.volume, persist: false)
        if stored.shouldResume {
            play()
        }
    }

    func persistState() {
        stateStore.write(PlaybackState(volume: volume, shouldResume: isPlaying))
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Session setup failure means playback may not start or may stop in background, but app remains usable.
        }
    }
}

private struct PinkFilterState {
    private var b0: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0
    private var b3: Float = 0
    private var b4: Float = 0
    private var b5: Float = 0
    private var b6: Float = 0

    mutating func nextSample(white: Float) -> Float {
        b0 = 0.99886 * b0 + white * 0.0555179
        b1 = 0.99332 * b1 + white * 0.0750759
        b2 = 0.96900 * b2 + white * 0.1538520
        b3 = 0.86650 * b3 + white * 0.3104856
        b4 = 0.55000 * b4 + white * 0.5329522
        b5 = -0.7616 * b5 - white * 0.0168980

        let pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11
        b6 = white * 0.115926
        return pink
    }
}
