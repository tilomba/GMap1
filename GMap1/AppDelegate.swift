import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  // 1
  let googleMapsApiKey = "AIzaSyBSBd0djIcp2byhUNLOhMBgAD6vr7tbc-k"
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // 2
    GMSServices.provideAPIKey(googleMapsApiKey)
    return true
  }
}