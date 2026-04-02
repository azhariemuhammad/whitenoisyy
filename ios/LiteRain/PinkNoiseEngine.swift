import AVFoundation
import Foundation

final class PinkNoiseEngine {
    private(set) var isPlaying: Bool = false
    private(set) var volume: Double = 0.7

    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private let stateStore = PlaybackStateStore()
    private let queue = DispatchQueue(label: "LiteRain.PinkNoise")
    private lazy var sourceNode: AVAudioSourceNode = {
        AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            for buffer in ablPointer {
                guard let channelData = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                for frame in 0..<frames {
                    let white = Float.random(in: -1...1)
                    self.b0 = 0.99886 * self.b0 + white * 0.0555179
                    self.b1 = 0.99332 * self.b1 + white * 0.0750759
                    self.b2 = 0.96900 * self.b2 + white * 0.1538520
                    self.b3 = 0.86650 * self.b3 + white * 0.3104856
                    self.b4 = 0.55000 * self.b4 + white * 0.5329522
                    self.b5 = -0.7616 * self.b5 - white * 0.0168980

                    let pink = (self.b0 + self.b1 + self.b2 + self.b3 + self.b4 + self.b5 + self.b6 + white * 0.5362) * 0.11
                    self.b6 = white * 0.115926
                    channelData[frame] = pink
                }
            }
            return noErr
        }
    }()

    private var b0: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0
    private var b3: Float = 0
    private var b4: Float = 0
    private var b5: Float = 0
    private var b6: Float = 0

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
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
            // Ignore session failures and keep app functional without crash.
        }
    }
}
