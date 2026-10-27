import XCTest
import UIKit
@testable import AppsOnAir_AppRemark

class ColorConstTests: XCTestCase {

    // MARK: - UIColor(rgb:)
    func testRGBInitializerParsesComponents() {
        TestHelper.assertColor(UIColor(rgb: 0xFF8000), red: 1, green: 128 / 255, blue: 0)
    }

    func testRGBInitializerBlackAndWhite() {
        TestHelper.assertColor(UIColor(rgb: 0x000000), red: 0, green: 0, blue: 0)
        TestHelper.assertColor(UIColor(rgb: 0xFFFFFF), red: 1, green: 1, blue: 1)
    }

    func testRGBInitializerIgnoresBitsAboveRGB() {
        // only the lower 24 bits are used for color, alpha is always 1
        TestHelper.assertColor(UIColor(rgb: 0xAB12_3456), red: 0x12 / 255, green: 0x34 / 255, blue: 0x56 / 255)
    }

    // MARK: - UIColor(hex:)
    func testHexNilReturnsNil() {
        XCTAssertNil(UIColor(hex: nil))
    }

    func testHexEmptyStringReturnsNil() {
        XCTAssertNil(UIColor(hex: ""))
    }

    func testHexInvalidCharactersReturnsNil() {
        XCTAssertNil(UIColor(hex: "ZZZZZZ"))
        XCTAssertNil(UIColor(hex: "#GGG"))
    }

    func testHexOnlyHashReturnsNil() {
        XCTAssertNil(UIColor(hex: "#"))
    }

    func testHexSixDigitsWithHash() {
        TestHelper.assertColor(UIColor(hex: "#007AFF"), red: 0, green: 122 / 255, blue: 1)
    }

    func testHexSixDigitsWithoutHash() {
        TestHelper.assertColor(UIColor(hex: "1c1c9e"), red: 0x1c / 255, green: 0x1c / 255, blue: 0x9e / 255)
    }

    func testHexIsCaseInsensitive() {
        let lower = UIColor(hex: "#abcdef")
        let upper = UIColor(hex: "#ABCDEF")
        TestHelper.assertSameColor(lower, upper)
    }

    func testHexThreeDigitsRGB() {
        TestHelper.assertColor(UIColor(hex: "#F80"), red: 1, green: 8 / 15, blue: 0)
    }

    func testHexFourDigitsRGBA() {
        TestHelper.assertColor(UIColor(hex: "#F808"), red: 1, green: 8 / 15, blue: 0, alpha: 8 / 15)
    }

    func testHexEightDigitsRRGGBBAA() {
        TestHelper.assertColor(
            UIColor(hex: "#FF000080"), red: 1, green: 0, blue: 0, alpha: 128 / 255)
    }

    func testHexEightDigitsFullyTransparent() {
        TestHelper.assertColor(UIColor(hex: "00000000"), red: 0, green: 0, blue: 0, alpha: 0)
    }

    func testHexUnsupportedLengthsReturnNil() {
        ["#F", "#FF", "#FFFFF", "#FFFFFFF", "#FFFFFFFFF"].forEach {
            XCTAssertNil(UIColor(hex: $0), "\($0) should be rejected")
        }
    }

    func testHexWithTrailingInvalidCharacterIsParsedLeniently() {
        // scanner stops at "Z" and keeps 0x0FFFFF, the length check still uses the full string
        TestHelper.assertColor(UIColor(hex: "#FFFFFZ"), red: 0x0F / 255, green: 1, blue: 1)
    }

    func testHexWithMultipleHashesStripsAll() {
        TestHelper.assertColor(UIColor(hex: "##000000"), red: 0, green: 0, blue: 0)
    }

    // MARK: - Default colors
    func testDefaultThemeColors() {
        TestHelper.assertColor(sColorPrimaryThemeLight, red: 0xE8 / 255, green: 0xF1 / 255, blue: 1)
        TestHelper.assertColor(sColorPrimaryThemeDark, red: 0, green: 0x7A / 255, blue: 1)
        TestHelper.assertColor(sColorWhite, red: 1, green: 1, blue: 1)
        TestHelper.assertColor(sColorBlack, red: 0, green: 0, blue: 0)
        TestHelper.assertColor(sColorRed, red: 0xe0 / 255, green: 0x46 / 255, blue: 0x46 / 255)
        TestHelper.assertColor(sColorGreen, red: 0x4d / 255, green: 0xc5 / 255, blue: 0x01 / 255)
        XCTAssertEqual(sColorClear, UIColor.clear)
        XCTAssertEqual(sColorGray, UIColor.gray)
        XCTAssertEqual(sColorLightGray, UIColor.lightGray)
    }

    func testTextColorsAliasThemeColors() {
        XCTAssertTrue(sColorTextPrimary === sColorPrimaryThemeDark)
        XCTAssertTrue(sColorTextPrimaryLight === sColorPrimaryThemeLight)
        XCTAssertTrue(sColorTextWhite === sColorWhite)
        XCTAssertTrue(sColorTextBlack === sColorBlack)
        XCTAssertTrue(sColorTextGray === sColorGray)
        XCTAssertTrue(sColorTextLightGray === sColorLightGray)
        XCTAssertTrue(sColorTextRed === sColorRed)
        XCTAssertTrue(sColorTextGreen === sColorGreen)
    }
}
