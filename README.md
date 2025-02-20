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

## Requirements

Minimum deployment target: 14.0


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
        appOnAirRemarkService.initialize(shakeGestureEnable: false,options: ["appBarBackgroundColor":"DAF7A6"])
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
       
    // App Remark Class instance create
    self.appRemarkService = [AppRemarkService shared];
    
    // Help to initialize remark services and customized the screen also using optional
    [self.appRemarkService initializeWithShakeGestureEnable:true options:@{@"appBarBackgroundColor": @"DAF7A6"}];
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
    let appsOnAirRemarkServices = AppRemarkService.shared
  
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
               // Help to open the manually open feedback screen 
               appsOnAirRemarkServices.addRemark(extraPayload: ["XX":"XX"])
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
     // Help to open the manually open feedback screen 
    [self.appRemarkService addRemarkWithExtraPayload:@{@"XX":@"XX"}];
}


```


## Change properties (optional)
Here are the available options (optional) and these options will help you customize your app to look better and feel more polished:

| No. | Option Name                  | Data Type  | Description                                          |
|-----|------------------------------|------------|------------------------------------------------------|
| 1   | appBarBackgroundColor       | `String`   | Sets the navigation bar background color (Hex value). |
| 2   | appBarTitleText             | `String`   | Sets the navigation bar title text.                 |
| 3   | appBarTitleColor            | `String`   | Sets the navigation bar title color (Hex value).     |
| 4   | pageBackgroundColor         | `String`   | Sets the page background color (Hex value).          |
| 5   | remarkTypeLabelText         | `String`   | Sets the label ticket text.                         |
| 6   | labelColor                  | `String`   | Sets the label ticket text color.                   |
| 7   | inputTextColor              | `String`   | Sets the input field text color.                    |
| 8   | hintColor                   | `String`   | Sets the input field hint text color.               |
| 9   | descriptionMaxLength        | `Int`      | Sets the character limit for the description field (default 255). |
| 10  | descriptionLabelText        | `String`   | Sets the description label text.                    |
| 11  | descriptionHintText         | `String`   | Sets the description hint text.                     |
| 12  | buttonText                  | `String`   | Sets the submit button text.                        |
| 13  | buttonTextColor             | `String`   | Sets the submit button text color.                  |
| 14  | buttonBackgroundColor       | `String`   | Sets the submit button background color.            |


## Documentation
more detail refer this [documentation](https://documentation.appsonair.com/Mobile-Quickstart/ios-sdk-setup).
## Author

devtools-logicwind, devtools@logicwind.com

## License

AppsOnAir-AppRemark is available under the MIT license. See the LICENSE file for more info.
