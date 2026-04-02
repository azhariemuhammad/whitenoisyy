# LiteRain iOS (Offline, iOS 12+)

Native iOS version of the white-noise/rain app using UIKit + AVAudioEngine.

## Features
- Runs fully offline (no network dependency at runtime).
- Pink-noise rain generator (no audio file download).
- Play/pause toggle, volume slider, status text.
- Lightweight animated rain layers.
- Local persistence for volume and last playback state.
- Background audio mode enabled.

## Minimum iOS
- Deployment target: **iOS 12.0**

## Open and Run
1. Open `ios/LiteRain.xcodeproj` in Xcode.
2. Select the **LiteRain** scheme.
3. Build and run on a real iPhone.

## Offline Validation
1. Install app on device.
2. Enable Airplane Mode.
3. Launch app and verify:
   - Play/pause works.
   - Audio keeps working offline.
   - Volume persists after relaunch.
   - App does not require network access.

## App Store Packaging Checklist
- Add required app icons in Xcode asset catalog.
- Set your Team + Bundle Identifier.
- Verify Privacy Nutrition Label (no tracking, no external data collection if unchanged).
- Archive using Release configuration.
- Validate and upload in Organizer.
