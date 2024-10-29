import Foundation

import UIKit
import iOSDropDown
import AppsOnAir_Core

class RemarkController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var btnNavClose: UIButton!
    
    @IBOutlet weak var lblTicketType: UILabel!
    @IBOutlet weak var dropDownTitle: UILabel!
    @IBOutlet weak var dropDown: DropDown!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var descriptionCharLimit: UILabel!
    
    @IBOutlet weak var lblAppsOnAir: UILabel!
    
    @IBOutlet weak var clView: UICollectionView!
    
    @IBOutlet weak var clViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnSubmit: UIButton!

    
    //MARK: - Declarations
    var appBarBackgroundColor: String?
    var appBarTitleColor: String?
    var appBarTitleText: String?

    var pageBackgroundColor: String?
    
    var lblTicketText: String?

    var dropDownArrowColor: UIColor?
    var arrowSize: CGFloat?
    var arrowColor: UIColor?
    
    var descriptionLabelText:String?
    var txtDescriptionHintText: String?
    var txtDescriptionCharLimit: Int = 255
    var descriptionHintText = "Add description here.."
    
    var raduis: CGFloat?
    var labelColor: String?
    var inputTextColor: String?
    var hintColor: String?

    
    var buttonText: String?
    var buttonTextColor: String?
    var buttonBackgroundColor: String?
    
    let ticketType = ["Improvement suggestion", "Bug report"]
    var selectedImage: [UIImage]? = []
    
    // Loader
    var activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView()
            indicator.color = .white // White loader on dark background
            indicator.translatesAutoresizingMaskIntoConstraints = false
            return indicator
        }()
    
    //overlay view for loader for disable another View
    var overlayView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.5) // Semi-transparent background
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

    
    //MARK: - View Methods
    override func viewDidLoad() {
       super.viewDidLoad()
            self.view.backgroundColor = UIColor.init(hex: pageBackgroundColor) ?? sColorPrimaryThemeLight
        
            self.navView.addShadow()
            self.navView.backgroundColor = UIColor.init(hex: appBarBackgroundColor) ?? sColorPrimaryThemeLight
            
            self.navTitle.textColor = UIColor.init(hex: appBarTitleColor) ?? sColorTextBlack
            self.navTitle.text = appBarTitleText ?? "Add Remark"
        
            self.btnNavClose.setTitle("", for: .normal)
            self.btnNavClose.addTarget(self, action: #selector(self.btnClose(_:)), for: .touchUpInside)
            
        
            self.dropDownTitle.text = lblTicketText ?? "Remark Type"
            self.lblTicketType.textColor = UIColor.init(hex: labelColor) ?? sColorTextLightGray
        
            self.dropDown.text = self.ticketType[0]
            self.dropDown.optionArray = ticketType
            self.dropDown?.selectedIndex = 0
            self.dropDown.isSearchEnable = false
            self.dropDown.arrowSize = arrowSize ?? CGFloat(12)
            self.dropDown.arrowColor = arrowColor ?? .black
            self.dropDown.selectedRowColor = UIColor.white
            self.dropDown.textColor =  sColorTextBlack
            self.dropDown.backgroundColor = sColorWhite
            self.dropDown.cornerRadius = 0
            self.dropDown.addCornerRadius(raduis: raduis)
            self.dropDown.handleKeyboard = false
            self.dropDown.checkMarkEnabled = false
            self.dropDown.didSelect{(selectedText , index ,id) in
                self.view.endEditing(true)
                self.dropDown.text = self.ticketType[index]
            }
            
            self.lblDescription.text = descriptionLabelText ?? "Description"
            self.lblDescription.textColor =  UIColor.init(hex: labelColor) ?? sColorTextLightGray
    
            self.descriptionCharLimit.text = "0/\(txtDescriptionCharLimit)"
          
            self.txtDescription.addCornerRadius(raduis: raduis)
            self.txtDescription.delegate = self
            self.txtDescription.backgroundColor = sColorWhite
            self.txtDescription.text = txtDescriptionHintText ?? descriptionHintText
            self.txtDescription.attributedText = NSAttributedString(string: txtDescriptionHintText ?? descriptionHintText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: hintColor) ?? sColorTextLightGray])
            
            
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            
            lblAppsOnAir.text = "We run on AppsOnAir"
            lblAppsOnAir.textColor = sColorTextPrimary
            
            clViewHeight.constant = screenHeight * 0.024
            clView?.collectionViewLayout = layout
        
           // let bundle = Bundle(for: type(of: self))
            let bundle = Bundle(identifier: "org.cocoapods.AppsOnAir-AppRemark")
            clView?.register(UINib(nibName: "ImageViewCell", bundle: bundle), forCellWithReuseIdentifier: "ImageViewCell")
            clView?.register(UINib(nibName: "AddImageCVCell", bundle: bundle), forCellWithReuseIdentifier: "AddImageCVCell")
            
            clView.delegate = self
            clView.dataSource = self
            clView.layoutIfNeeded()
            clView.reloadData()
            
            btnSubmit.backgroundColor = UIColor.init(hex: buttonBackgroundColor) ?? sColorPrimaryThemeDark
            btnSubmit.setTitleColor(UIColor.init(hex: buttonTextColor) ?? sColorTextWhite, for: .normal)
            btnSubmit.setTitle(buttonText ?? "Submit", for: .normal)
            btnSubmit.addShadow()
            btnSubmit.addCornerRadius(color: sColorClear, raduis: raduis)
            btnSubmit.addTarget(self, action: #selector(btnSubmit(_:)), for: .touchUpInside)
            setupActivityIndicatorAndOverlay()
   }
    
    //MARK: - Action Methods
    @objc func btnClose(_ sender: UIButton) {
        view.endEditing(true)
        self.dismissController()
    }
    
    @objc func removeSnapshot(_ sender: UIButton) {
        selectedImage?.remove(at: sender.tag)
        clView.reloadData()
    }
    
    // Function to set up the overlay and loader in the XIB view
      func setupActivityIndicatorAndOverlay() {
          // Add overlay to the main view
          view.addSubview(overlayView)
          // Add activity indicator to the overlay
          overlayView.addSubview(activityIndicator)
          // Constrain the overlay to cover the whole screen
          NSLayoutConstraint.activate([
              overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              overlayView.topAnchor.constraint(equalTo: view.topAnchor),
              overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
          ])
          // Center the activity indicator within the overlay
          NSLayoutConstraint.activate([
              activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
              activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
          ])
          // Initially hide the overlay and loader
          overlayView.isHidden = true
      }
    
    // Function to show the loader and block the UI
    @objc func showLoader() {
           overlayView.isHidden = false
           activityIndicator.startAnimating()  // Start animating the loader
       }
     
    // Function to hide the loader and unblock the UI
    @objc func hideLoader() {
           overlayView.isHidden = true
           activityIndicator.stopAnimating()   // Stop animating the loader
       }
    
    //failure toast
    @objc func failureToast(isNetworkError:Bool = false) {
        self.showToast(message: isNetworkError ? errorNetwork : errorSomethingWentWrong) {success in
            if success  {
                self.hideLoader()
            }
        }
    }
    
    @objc func getPodVersion() -> String {
        let podVersion = Bundle(for: AppRemarkService.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        Logger.logInternal(podVersion)
        return podVersion
    }

    @objc func dismissController() {
        NotificationCenter.default.post(name: NSNotification.Name("visibilityChanges"), object: nil, userInfo: ["isPresented": false])
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func btnSubmit(_ sender: UIButton){
        showLoader()
        view.endEditing(true)
        let AppsOnAirAppId  = AppRemarkService.shared.appsOnAirCore.appId
        //Check internet connectivity
        if ((AppRemarkService.shared.appsOnAirCore.isNetworkConnected ?? false) && !(AppsOnAirAppId.isEmpty) ) {
            
            let dispatchGroup = DispatchGroup()
           
            //Remark screenData from BE
            var feedBackScreenShotData:[NSDictionary] = []
            
            //Loop of multiple images upload
            for index in 0..<(selectedImage?.count ?? 0) {
                // Enter the dispatch group before starting each API call
                dispatchGroup.enter()
                
                //File name
                let epochTimeInMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
                Logger.logInternal("\(echoTime) \(epochTimeInMilliseconds)")
                let fullFileName = "\((Bundle.main.appName ?? "").isEmpty ? "" : "\(Bundle.main.appName ?? "")_")\(epochTimeInMilliseconds)"
                let fileType = "image/\(selectedImage?[index].getFileType() ?? "")"
                let imageData:NSDictionary = [
                  "data": [
                    "fileName": fullFileName,
                    "fileType": fileType
                  ]
                ]
                
                //Api of getSignIn
                RemarkApiService.apiGetSignInURL(apiGetSignInPassData: imageData) { signInData in
                    if (signInData.count != 0) {
                        let signUinUploadUrl = (signInData["data"] as! NSDictionary)["signedURL"] as! String
                        let fileURL = (signInData["data"] as! NSDictionary)["fileUrl"] as! String
                        RemarkApiService.apiUploadImage(image: (self.selectedImage?[index]) ?? UIImage(), signUrl: signUinUploadUrl){ value in
                            if(value){
                                feedBackScreenShotData.append(["key":fileURL,"fileType":fileType])
                                dispatchGroup.leave()
                            }else{
                                self.failureToast()
                                return
                            }
                        }
                    }else{
                        self.failureToast()
                        return
                    }
                }
            }
            //Call after the all image are uploaded
            dispatchGroup.notify(queue: .main) {
                    
                //get Device Info
                let deviceInfo = MyDevice().getInfo()
                // Get current time zone
                let timeZone = TimeZone.current.identifier
                
                Logger.logInternal(TimeZone.current.identifier)
                let deviceInfoDict: NSDictionary = [
                    "deviceModel": deviceInfo["deviceModel"] ?? "",
                    "deviceUsedStorage": deviceInfo["deviceUsedStorage"] ?? "",
                    "deviceTotalStorage": deviceInfo["deviceTotalStorage"] ?? "",
                    "deviceMemory": deviceInfo["deviceMemory"] ?? "",
                    "appMemoryUsage": deviceInfo["appMemoryUsage"] ?? "",
                    "deviceOrientation": deviceInfo["deviceOrientation"] ?? "",
                    "buildVersionNumber": deviceInfo["buildVersionNumber"] ?? "",
                    "bundleIdentifier":deviceInfo["bundleIdentifier"] ?? "",
                    "deviceOsVersion": deviceInfo["deviceOsVersion"] ?? "",
                    "deviceRegionCode": deviceInfo["deviceRegionCode"] ?? "",
                    "deviceBatteryLevel": deviceInfo["deviceBatteryLevel"] ?? "",
                    "deviceScreenSize": deviceInfo["deviceScreenSize"] ?? "",
                    "deviceRegionName": deviceInfo["deviceRegionName"] ?? "",
                    "releaseVersionNumber": deviceInfo["releaseVersionNumber"] ?? "",
                    "timezone": timeZone,
                    "appsOnAirSDKVersion": self.getPodVersion(),
                    "appName" : Bundle.main.appName ?? ""
                ]
                let remarkType:String = (self.dropDown.text ?? "") == self.ticketType[0] ? "SUGGESTION" : "BUG"
                
                
                let userDescription = self.txtDescription.text.trimmingCharacters(in: .whitespacesAndNewlines) as String
                // Step 2: Create the data dictionary separately
                let apiData:NSDictionary = [
                    "additionalMetadata": AppRemarkService.shared.additionalParams ?? [],
                    "attachments": feedBackScreenShotData,
                    "description": ((userDescription == "") || userDescription == self.descriptionHintText) ? "":
                        userDescription,
                    "deviceInfo": deviceInfoDict, // Use the deviceInfoDict here
                    "type": remarkType
                ]
                
                //  Create the final request dictionary
                let apiKey:NSDictionary = ["appId": AppRemarkService.shared.appsOnAirCore.appId]
                let apiPassingData:NSDictionary = [
                    "where": apiKey,
                    "data": apiData
                ]
                
                Logger.logInternal("\(apiData): \(apiPassingData)")
         
                //Api of Create remark
                RemarkApiService.apiAddRemark(apiPassData: apiPassingData as NSDictionary) { feedbackData in
                    if(feedbackData.count != 0 && feedbackData["error"] == nil) {
                        let apiStatus = feedbackData["status"] as? String ?? ""
                        if(apiStatus == "SUCCESS") {
                            self.showToast(message: feedbackData["message"] as! String) {success in
                                if (success) {
                                    DispatchQueue.global().async {
                                        sleep(1)//Delay to display toast message
                                        DispatchQueue.main.async {
                                            self.dismiss(animated: true, completion: nil)
                                            self.hideLoader()
                                        }
                                    }
                                }
                            }
                        }else{
                            self.failureToast()
                        }
                    }else{
                        self.failureToast()
                    }
                }
            }
        }else if (AppsOnAirAppId.isEmpty){
            self.failureToast()
        }else{
            self.failureToast(isNetworkError: true)
        }
    }
}

//MARK: - UICollectionDelegate
extension RemarkController:  UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.selectedImage?.count ?? 0;
        return (count < 2 ? count + 1 : count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.row < (self.selectedImage?.count ?? 0) else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCVCell", for: indexPath) as? AddImageCVCell
            
            return cell ?? UICollectionViewCell()
        }
        let inx = indexPath.row
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as? ImageViewCell
        
        cell?.imageView.image = selectedImage?[inx]
        cell?.imageView.layer.masksToBounds = true
        cell?.imageView.contentMode = .scaleAspectFit
        cell?.imageView.clipsToBounds = true

        
        cell?.bgImageView.layer.masksToBounds = true
        cell?.bgImageView.clipsToBounds = true
        cell?.bgImageView.backgroundColor = sColorWhite
        cell?.bgImageView.addShadows(shadowColor: sColorGray.cgColor, shadowOffset: CGSize(width: 5, height: 3), shadowOpacity: 0.9, shadowRadius: 6, cornerRadiusIs: 6)
        
        
        cell?.btnRemove.tag = inx
        cell?.btnRemove.addTarget(self, action: #selector(removeSnapshot(_:)), for: .touchUpInside)
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((screenWidth) - 16) / 3, height: ((screenHeight)) * 0.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row >= (self.selectedImage?.count ?? 0)) {
            self.selectImagePopup()
        }
    }
    
    
}
//MARK: - UITextViewDelegate
extension RemarkController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {

        if txtDescription.text == (txtDescriptionHintText ?? descriptionHintText) {
            txtDescription.text = ""
            txtDescription.textColor = UIColor.init(hex: inputTextColor) ?? sColorTextBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if txtDescription.text.isEmpty {
            txtDescription.text = txtDescriptionHintText ?? descriptionHintText
            txtDescription.textColor = UIColor.init(hex: hintColor) ?? sColorTextLightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        descriptionCharLimit.text = "\(numberOfChars)/\(txtDescriptionCharLimit)"
        return numberOfChars < txtDescriptionCharLimit;
    }
}


extension RemarkController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.selectedImage?.append(image)
        self.clView.reloadData()
    }
}
