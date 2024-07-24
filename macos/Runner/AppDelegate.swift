import Cocoa
import FlutterMacOS
import GoogleMaps

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    return true
  }
}
