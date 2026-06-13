import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    private var blurView: UIVisualEffectView?

    override func sceneWillResignActive(_ scene: UIScene) {
        super.sceneWillResignActive(scene)
        guard let window = self.window else { return }
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 9999
        
        window.addSubview(blurView)
        self.blurView = blurView
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        self.window?.viewWithTag(9999)?.removeFromSuperview()
        self.blurView = nil
    }
}
