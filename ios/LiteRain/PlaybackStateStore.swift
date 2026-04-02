import Foundation

struct PlaybackState: Codable {
    let volume: Double
    let shouldResume: Bool
}

final class PlaybackStateStore {
    private let defaults = UserDefaults.standard
    private let key = "LiteRain.playbackState"

    func read() -> PlaybackState {
        guard
            let data = defaults.data(forKey: key),
            let state = try? JSONDecoder().decode(PlaybackState.self, from: data)
        else {
            return PlaybackState(volume: 0.7, shouldResume: false)
        }
        return PlaybackState(volume: min(max(state.volume, 0), 1), shouldResume: state.shouldResume)
    }

    func write(_ state: PlaybackState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: key)
        }
    }
}
