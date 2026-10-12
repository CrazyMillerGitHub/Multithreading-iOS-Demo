import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let presenter = MainPresenter()
        let controller = MainViewController(presenter: presenter)
        presenter.attach(controller)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
    }
}
