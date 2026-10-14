import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @IBAction func openPreferences(_ sender: Any?) {
    if let window = mainFlutterWindow,
       let flutterViewController = window.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.repetita.app/menu", binaryMessenger: flutterViewController.engine.binaryMessenger)
      channel.invokeMethod("openPreferences", arguments: nil)
    }
  }
}
