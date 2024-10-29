import Foundation
import UIKit

//DEFAULTS COLORS
let sColorPrimaryThemeLight =  UIColor.init(rgb: 0xE8F1FF)
let sColorPrimaryThemeDark =  UIColor.init(rgb: 0x007AFF)

let sColorWhite = UIColor.init(rgb: 0xFFFFFF)
let sColorBlack = UIColor.init(rgb: 0x000000)
let sColorGray = UIColor.gray
let sColorLightGray = UIColor.lightGray
let sColorRed = UIColor.init(rgb: 0xe04646)
let sColorGreen = UIColor.init(rgb: 0x4dc501)
let sColorClear = UIColor.clear


//TEXT COLORS
let sColorTextPrimary = sColorPrimaryThemeDark
let sColorTextPrimaryLight = sColorPrimaryThemeLight

//TEXT COLORS
let sColorTextWhite = sColorWhite
let sColorTextBlack = sColorBlack
let sColorTextGray = sColorGray
let sColorTextLightGray = sColorLightGray
let sColorTextRed = sColorRed
let sColorTextGreen = sColorGreen




extension UIColor {
    /// RGB to UIColor
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
 convenience init?(hex: String?) {
        guard let hex = hex else { return nil }
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        var alpha: CGFloat = 1.0
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0

        switch hexString.count {
        case 3: // #RGB
            red = CGFloat((hexNumber & 0xF00) >> 8) / 15.0
            green = CGFloat((hexNumber & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexNumber & 0x00F) / 15.0
        case 4: // #RGBA
            red = CGFloat((hexNumber & 0xF000) >> 12) / 15.0
            green = CGFloat((hexNumber & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexNumber & 0x00F0) >> 4) / 15.0
            alpha = CGFloat(hexNumber & 0x000F) / 15.0
        case 6: // #RRGGBB
            red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexNumber & 0x0000FF) / 255.0
        case 8: // #RRGGBBAA
            red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(hexNumber & 0x000000FF) / 255.0
        default:
            return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
