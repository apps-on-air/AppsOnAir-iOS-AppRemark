import Foundation
import UIKit

///get screen wight
let screenWidth = UIScreen.main.bounds.size.width

///get screen height
let screenHeight = UIScreen.main.bounds.size.height

//MARK: - User Info Messages

let errorPhotosPermission = "Need to add NSPhotoLibraryUsageDescription in your info.plist for access Photos"

let appsOnAirRemark = "AppsOnAir Remark"

let remark = "Remark"

let ok = "Ok"

let chooseImageSource = "Choose your Image source"

let gallery = "Gallery"

let cancel = "Cancel"

//MARK: - Internal Logs Messages

let statusCode = "Status code:"

let failedGetURL = "Failed to get URL"

let responseJson = "Response JSON:"

let failedToLoad = "Failed to load:"

let errorImageData = "Error converting image to data"

let errorURL = "No URL"

let errorNotFoundQuery = "No query parameters found"

let errorNotFoundParams = "No parameters found"

let errorUploadImage = "Error uploading image:"

let errorNetwork = "Please check internet connection" // !!!: Developer Guideline URL

let errorSomethingWentWrong = "Something Went Wrong"

let getSignInURL = "getSignIn"

let imageUploadSuccess = "Image uploaded successfully!!"

let errorGalleryPermission = "Gallery permission required!"

let url = "URL"

let apiData = "Api Passing Data"

let echoTime = "Epoch time in milliseconds:"

let viewControllerViewDidLoad = "View controller viewDidLoad:"

let shakeGestureDetected = "Shake Gesture Detected"

enum RemarkType: String {
    case suggestion = "SUGGESTION"
    case bug = "BUG"
}

