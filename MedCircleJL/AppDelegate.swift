
import UIKit
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //clearCache()     // Use this method to redownload image for download simulation
        SDWebImageManager.sharedManager().delegate = ImageManager.sharedInstance
        return true
    }
    
    func clearCache() {
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().clearDisk()
    }
}

