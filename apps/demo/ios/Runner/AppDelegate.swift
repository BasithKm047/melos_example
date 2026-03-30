import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  @available(iOS 16.1, *)
  private var liveActivityBridge: OrderLiveActivityBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 16.1, *),
      let controller = window?.rootViewController as? FlutterViewController
    {
      liveActivityBridge = OrderLiveActivityBridge(binaryMessenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
