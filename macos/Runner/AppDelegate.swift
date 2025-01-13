import Cocoa
import FlutterMacOS
import ServiceManagement

@main
class AppDelegate: FlutterAppDelegate {
  var statusBar: StatusBarController?
  var popover = NSPopover.init()
  override init() {
    popover.behavior = NSPopover.Behavior.transient //to make the popover hide when the user clicks outside of it
  }
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    //add to login items:
    do {
      try SMAppService.mainApp.register()
  } catch {}
    
      
    let controller: FlutterViewController =
      mainFlutterWindow?.contentViewController as! FlutterViewController
    popover.contentSize = NSSize(width: 360, height: 400) //change this to your desired size
    popover.contentViewController = controller //set the content view controller for the popover to flutter view controller
    statusBar = StatusBarController.init(popover)
    mainFlutterWindow?.close() //close the default flutter window
    setupMethodChannel(controller: controller)
    super.applicationDidFinishLaunching(aNotification)
    
  }



  private func setupMethodChannel(controller: FlutterViewController) {
    //controller = window?.rootViewController as! FlutterViewController
    //let mathodChannel = FlutterMethodChannel(name: "in.robbb.wad", binaryMessenger: controller.binaryMessenger)
    let methodChannel = FlutterMethodChannel(name: "in.robbb.wad", binaryMessenger: controller.engine.binaryMessenger)
    methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "setWallpaper", let args = call.arguments as? [String: Any], let path = args["path"] as? String {
        self?.setWallpaper(path: path, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setWallpaper(path: String, result: @escaping FlutterResult) {
    let url = URL(fileURLWithPath: path)
    /// set the wallpaper on ALL screens
    do {
      let screens = NSScreen.screens
      for screen in screens {
          try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
      }
      result(nil)
      //old: try NSWorkspace.shared.setDesktopImageURL(url, for: NSScreen.main!, options: [:])
      
    } catch {
      result(FlutterError(code: "UNAVAILABLE", message: "Setting wallpaper failed", details: error.localizedDescription))
    }
  }
}
