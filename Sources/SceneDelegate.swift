import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let viewModel = MainViewModel()
        window.rootViewController = MainViewController(viewModel: viewModel)
        window.makeKeyAndVisible()
        self.window = window
    }
}
