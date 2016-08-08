
import Foundation
import SDWebImage

class ImageManager: NSObject {
    static let sharedInstance = ImageManager()
    
    private override init() { super.init() }
}

private extension ImageManager {
    // Change large image to have a max dimension of screen's max dimension (width or height)
    func resizeLargeImgToSmallerImg(image: UIImage) -> UIImage {
        let maxDimension = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        guard max(image.size.width, image.size.height) > maxDimension else { return image }
        
        let aspect = image.size.width / image.size.height
        let newSize = image.size.width > image.size.height ?
            CGSizeMake(maxDimension, maxDimension/aspect) :
            CGSizeMake(maxDimension * aspect, maxDimension)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        let newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
        image.drawInRect(newImageRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

extension ImageManager: SDWebImageManagerDelegate  {
    func imageManager(imageManager: SDWebImageManager!, transformDownloadedImage image: UIImage!, withURL imageURL: NSURL!) -> UIImage! {
        return resizeLargeImgToSmallerImg(image)
    }
}
