import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let rootVC = MainViewController()
      let window = UIWindow(windowScene: windowScene)
      let naviVC = UINavigationController(rootViewController: rootVC)
      window.rootViewController = naviVC
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
}
