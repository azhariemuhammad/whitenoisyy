import UIKit

final class MainViewController: UIViewController {
    private let audioEngine = PinkNoiseEngine()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap to Start"
        label.textColor = UIColor(white: 1, alpha: 0.75)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 1, alpha: 0.06)
        button.layer.borderColor = UIColor(white: 1, alpha: 0.14).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 56
        button.contentEdgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        button.setTitle("▶︎", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 34, weight: .semibold)
        button.accessibilityHint = "Double tap to toggle playback"
        return button
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.7
        slider.tintColor = UIColor(white: 1, alpha: 0.8)
        return slider
    }()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Headphones Recommended"
        label.textColor = UIColor(white: 1, alpha: 0.35)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let rainLayer1 = CAGradientLayer()
    private let rainLayer2 = CAGradientLayer()
    private let rainLayer3 = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 15 / 255, green: 15 / 255, blue: 19 / 255, alpha: 1)

        setupRainLayers()
        setupUI()
        setupActions()

        audioEngine.restoreStateAndApply()
        slider.value = Float(audioEngine.volume)
        refreshUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutRainLayers()
    }

    private func setupUI() {
        view.addSubview(statusLabel)
        view.addSubview(toggleButton)
        view.addSubview(slider)
        view.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -110),

            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 18),
            toggleButton.widthAnchor.constraint(equalToConstant: 112),
            toggleButton.heightAnchor.constraint(equalToConstant: 112),

            slider.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 26),
            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slider.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            slider.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 28),
            slider.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -28),

            footerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        toggleButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        slider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
    }

    private func setupRainLayers() {
        [rainLayer1, rainLayer2, rainLayer3].forEach {
            $0.colors = [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.10).cgColor
            ]
            $0.locations = [0.9, 1.0]
            view.layer.insertSublayer($0, at: 0)
        }
        rainLayer1.opacity = 0.6
        rainLayer2.opacity = 0.4
        rainLayer3.opacity = 0.2
    }

    private func layoutRainLayers() {
        let frame = view.bounds.insetBy(dx: -100, dy: -view.bounds.height)
        rainLayer1.frame = frame
        rainLayer2.frame = frame
        rainLayer3.frame = frame

        let t = CATransform3DMakeRotation(.pi / 14, 0, 0, 1)
        rainLayer1.transform = t
        rainLayer2.transform = t
        rainLayer3.transform = t

        applyRainAnimation(layer: rainLayer1, duration: 0.8)
        applyRainAnimation(layer: rainLayer2, duration: 1.2)
        applyRainAnimation(layer: rainLayer3, duration: 1.8)
    }

    private func applyRainAnimation(layer: CALayer, duration: CFTimeInterval) {
        if layer.animation(forKey: "rain") != nil { return }
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -view.bounds.height * 0.5
        animation.toValue = view.bounds.height * 0.5
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: "rain")
    }

    private func refreshUI() {
        let isPlaying = audioEngine.isPlaying
        statusLabel.text = isPlaying ? "Raining" : "Tap to Start"
        toggleButton.setTitle(isPlaying ? "❚❚" : "▶︎", for: .normal)
        toggleButton.accessibilityLabel = isPlaying ? "Pause rain sound" : "Play rain sound"
        slider.isEnabled = isPlaying
        slider.alpha = isPlaying ? 1 : 0.35
    }

    @objc private func togglePlayback() {
        audioEngine.togglePlayback()
        Haptics.tap()
        refreshUI()
    }

    @objc private func volumeChanged(_ sender: UISlider) {
        audioEngine.setVolume(Double(sender.value), persist: true)
    }

    func persistPlaybackState() {
        audioEngine.persistState()
    }
}
