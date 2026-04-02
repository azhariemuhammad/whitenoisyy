import AVFoundation
import Foundation

final class PinkNoiseEngine {
    private(set) var isPlaying: Bool = false
    private(set) var volume: Double = 0.7

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let mixer = AVAudioMixerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private let bufferFrameCount: AVAudioFrameCount = 4_096
    private let stateStore = PlaybackStateStore()
    private let queue = DispatchQueue(label: "LiteRain.PinkNoise")
    private let pinkStateLock = NSLock()
    private var pinkState = PinkFilterState()
    private var shouldKeepScheduling = false
    private var isScheduling = false

    init() {
        playerNode.volume = 1.0

        setupAudioSession()

        engine.attach(playerNode)
        engine.attach(mixer)
        engine.connect(playerNode, to: mixer, format: format)
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
            self.shouldKeepScheduling = true
            if !self.isScheduling {
                self.scheduleNextBuffer()
            }
            if !self.playerNode.isPlaying {
                self.playerNode.play()
            }
            DispatchQueue.main.async {
                self.isPlaying = true
                self.persistState()
            }
        }
    }

    func pause() {
        queue.async {
            self.shouldKeepScheduling = false
            self.playerNode.stop()
            self.engine.pause()
            self.isScheduling = false
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

    private func scheduleNextBuffer() {
        guard shouldKeepScheduling else {
            isScheduling = false
            return
        }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferFrameCount) else {
            isScheduling = false
            return
        }

        let frames = Int(bufferFrameCount)
        buffer.frameLength = bufferFrameCount
        guard let channelData = buffer.floatChannelData?.pointee else {
            isScheduling = false
            return
        }
        pinkStateLock.lock()
        for frame in 0..<frames {
            let white = Float.random(in: -1...1)
            channelData[frame] = pinkState.nextSample(white: white)
        }
        pinkStateLock.unlock()

        isScheduling = true
        playerNode.scheduleBuffer(buffer, completionHandler: { [weak self] in
            guard let self else { return }
            self.queue.async {
                self.isScheduling = false
                self.scheduleNextBuffer()
            }
        })
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
