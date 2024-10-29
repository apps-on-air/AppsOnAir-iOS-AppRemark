## [![pub package](https://appsonair.com/images/logo.svg)](https://cocoapods.org/pods/AppsOnAir-AppRemark)
# AppsOnAir-AppRemark

[![Version](https://img.shields.io/cocoapods/v/AppsOnAir-AppRemark.svg?style=flat)](https://cocoapods.org/pods/AppsOnAir-AppRemark)
[![License](https://img.shields.io/cocoapods/l/AppsOnAir-AppRemark.svg?style=flat)](https://cocoapods.org/pods/AppsOnAir-AppRemark)

## Overview

AppsOnAir-AppRemark simplifies feedback collection, allowing users to report bugs and suggestions with a shake or a button action. It captures screenshots and descriptions in a customizable interface.

## Installation

AppsOnAir-AppRemark is available through [CocoaPods](https://cocoapods.org). To use or install AppsOnAir-AppRemark with CocoaPods,
simply add the following line to your Podfile:

```ruby
pod 'AppsOnAir-AppRemark'
```

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. To use AppsOnAir-AppRemark with Swift Package Manger, add it to `dependencies` in your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/apps-on-air/AppsOnAir-iOS-AppRemark.git")
]
```
## Requirements

Minimum deployment target: 12.0


## USAGE 
Add APIKey in your app info.plist file.
```xml
<key>AppsOnAirAPIKey</key>
<string>XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX</string>
```
how to get APIKey for more details check this [URL](https://documentation.appsonair.com/Mobile-Quickstart/ios-sdk-setup)

This pod requires photo permissions. Add the following usage description to your Info.plist:


```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>$(PRODUCT_NAME) need permission to choose image from gallery for App Remark feature.</string>
```

## 1. Automatically Opening Feedback Screen at App Launch
### Firstly, import AppsOnAir_AppRemark in appDelegate

Swift / SwiftUI
```swift
import AppsOnAir_AppRemark
```
Objective-c

```swift
#import "AppsOnAir_AppRemark-Swift.h"
```

### App-Remark Implement Code

Swift / SwiftUI
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appOnAirRemarkService = AppRemarkService.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // help to initialize remark services and customized the screen also using optional
        appOnAirRemarkService.initialize(options: ["appBarBackgroundColor":"DAF7A6"],shakeGestureEnable: false)
        return true
    }
}
```

Objective-c
```swift
#import "AppDelegate.h"
#import "AppsOnAir_AppRemark-Swift.h"



@interface AppDelegate ()
@property (nonatomic, strong) AppRemarkService *appRemarkService;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       
    // App Sync Class instance create
    self.appRemarkService = [AppRemarkService shared];
    
    // Help to enable sync manager for app with directory for showNativeUi handling and completion method
    [self.appRemarkService initializeWithOptions:@{@"appBarBackgroundColor": @"DAF7A6"} shakeGestureEnable:true];
    // Override point for customization after application launch.
    return YES;
}

```

## 2.Manually Triggering Feedback Screen from Any Code
You can also trigger the feedback screen manually, such as from a button action:
### Firstly, import AppsOnAir_AppRemark in your ViewController file or swift code file

Swift / SwiftUI
```swift
import AppsOnAir_AppRemark
```
Objective-c

```swift
#import "AppsOnAir_AppRemark-Swift.h"
```

### App-Remark Implement Code

Swift / SwiftUI
```swift
class ViewController: UIViewController {
    let appsOnAirStateServices = AppRemarkService.shared
  
    override func viewDidLoad() {
        super.viewDidLoad()
       
            
        let button = UIButton(type: .system)
                button.setTitle("Button", for: .normal)
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.cornerRadius = 10
                
                // Set button frame (size and position)
                button.frame = CGRect(x: 100, y: 200, width: 150, height: 50)
                
                // Add target for onPressed (TouchUpInside)
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                
                // Add the button to the view
                self.view.addSubview(button)
          }
    
          // Define the action when button is pressed
           @objc func buttonPressed() {
               // Help to enable remark services where using Options customize the remark screen and customize text and raiseNewTicket is true for opening the remark screen on particular event , without capture screenshot and raiseNewTicket is set to false for only customize the remark screen  and extraPayload is for added custom and additional params.
               appsOnAirStateServices.addRemark(extraPayload: ["XX":"XX"])
           }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```

Objective-c
```swift
#import "ViewController.h"
#import "AppsOnAir_AppRemark-Swift.h"


@interface ViewController ()
@property (nonatomic, strong) AppRemarkService *appRemarkService;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appRemarkService = [AppRemarkService shared];
    // Create a UIButton programmatically
       UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeSystem];
       
       // Set button title
       [ctaButton setTitle:@"Open Remark Screen" forState:UIControlStateNormal];
       
       // Set button frame (position and size)
       ctaButton.frame = CGRectMake(100, 200, 200, 50);
       
       // Add target-action for button tap
       [ctaButton addTarget:self action:@selector(openNextScreen) forControlEvents:UIControlEventTouchUpInside];
       
       // Add button to the view
       [self.view addSubview:ctaButton];
}
- (void)openNextScreen {
    [self.appRemarkService addRemarkWithExtraPayload:@{@"XX":@"XX"}];
}


```


## Change properties (optional)
Here are the available options (optional) and these options will help you customize your app to look better and feel more polished:

| No. | Option Name                  | Description      
|-----|------------------------------|-------------------------------------------------------
| 1   | appBarBackgroundColor       | Sets the navigation bar background color (Hex value).
| 2   | appBarTitleText             | Sets the navigation bar title text.               
| 3   | appBarTitleColor            | Sets the navigation bar title color (Hex value).    
| 4   | pageBackgroundColor         | Sets the page background color (Hex value).           
| 5   | remarkTypeLabelText         | Sets the label ticket text.                      
| 6   | labelColor                  | Sets the label ticket text color.                 
| 7   | inputTextColor              | Sets the input field text color.                     
| 8   | hintColor                   | Sets the input field hint text color.               
| 9   | descriptionMaxLength        | Sets the character limit for the description field (default 255).
| 10  | descriptionLabelText        | Sets the description label text.                    
| 11  | descriptionHintText         | Sets the description hint text.                 
| 12  | buttonText                  | Sets the submit button text.                     
| 13  | buttonTextColor             | Sets the submit button text color.                   
| 14  | buttonBackgroundColor       | Sets the submit button background color. 

## Documentation
more detail refer this [documentation](https://documentation.appsonair.com/Mobile-Quickstart/ios-sdk-setup).
## Author

devtools-logicwind, devtools@logicwind.com

## License

AppsOnAir-AppRemark is available under the MIT license. See the LICENSE file for more info.
