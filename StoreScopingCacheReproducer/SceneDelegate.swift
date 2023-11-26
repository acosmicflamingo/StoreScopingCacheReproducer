import ComposableArchitecture
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  let store = Store(initialState: AppMain.State()) {
    AppMain()
  }

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene {
      let viewController = AppMainViewController(store: store)
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = viewController
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {}

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {}
}

