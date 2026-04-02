import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 13.0, *) {
            // iOS 13+ uses SceneDelegate.
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = MainViewController()
            window.makeKeyAndVisible()
            self.window = window
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let root = window?.rootViewController as? MainViewController {
            root.persistPlaybackState()
        }
    }

    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
