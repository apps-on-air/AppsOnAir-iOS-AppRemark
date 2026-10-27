import XCTest
import UIKit
@testable import AppsOnAir_AppRemark

// MARK: - MockURLProtocol
/// Intercepts every request made through URLSession.shared so no test hits the real server
final class MockURLProtocol: URLProtocol {

    struct Stub {
        var statusCode: Int = 200
        var data: Data?
        var error: Error?
    }

    private static let lock = NSLock()
    private static var _handler: ((URLRequest) -> Stub)?
    private static var _requests: [URLRequest] = []

    /// return the stubbed response for a request
    static var handler: ((URLRequest) -> Stub)? {
        get { lock.lock(); defer { lock.unlock() }; return _handler }
        set { lock.lock(); _handler = newValue; lock.unlock() }
    }

    /// every request seen by the protocol, with httpBody restored from the body stream
    static var requests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return _requests
    }

    static func register() {
        reset()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    static func unregister() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        reset()
    }

    static func reset() {
        lock.lock()
        _handler = nil
        _requests = []
        lock.unlock()
    }

    static func requests(matching path: String) -> [URLRequest] {
        return requests.filter { $0.url?.path == path }
    }

    static func jsonData(_ object: Any) -> Data {
        return (try? JSONSerialization.data(withJSONObject: object, options: [])) ?? Data()
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        var recorded = request
        recorded.httpBody = request.httpBody ?? request.httpBodyStream.map(Self.readStream)
        Self.lock.lock()
        Self._requests.append(recorded)
        Self.lock.unlock()

        // Unstubbed requests fail so a missing stub never reaches the network
        let stub =
            Self.handler?(recorded)
            ?? Stub(statusCode: 0, data: nil, error: URLError(.notConnectedToInternet))

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(
            url: request.url!, statusCode: stub.statusCode, httpVersion: "HTTP/1.1",
            headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func readStream(_ stream: InputStream) -> Data {
        var data = Data()
        stream.open()
        defer { stream.close() }
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }
}

// MARK: - PresentationSpyViewController
/// Captures presentations instead of performing them, so tests do not depend on a visible window
class PresentationSpyViewController: UIViewController {
    var presentedControllers: [UIViewController] = []
    var onPresent: ((UIViewController) -> Void)?

    override func present(
        _ viewControllerToPresent: UIViewController, animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentedControllers.append(viewControllerToPresent)
        onPresent?(viewControllerToPresent)
        completion?()
    }
}

// MARK: - Helpers
enum TestHelper {

    /// solid color image with real pixel data
    static func makeImage(
        size: CGSize = CGSize(width: 10, height: 10), color: UIColor = .red
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    /// instantiate RemarkController from the SDK storyboard
    static func makeRemarkController() -> RemarkController {
        let storyboard = UIStoryboard(name: "AppRemark", bundle: Bundle.remarkBundle)
        return storyboard.instantiateViewController(withIdentifier: "RemarkController")
            as! RemarkController
    }

    /// compare colors component wise with a tolerance for float rounding
    static func assertColor(
        _ color: UIColor?, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1,
        accuracy: CGFloat = 0.002, file: StaticString = #filePath, line: UInt = #line
    ) {
        guard let color = color else {
            XCTFail("Color is nil", file: file, line: line)
            return
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        XCTAssertTrue(
            color.getRed(&r, green: &g, blue: &b, alpha: &a), "Not an RGB color", file: file,
            line: line)
        XCTAssertEqual(r, red, accuracy: accuracy, "red", file: file, line: line)
        XCTAssertEqual(g, green, accuracy: accuracy, "green", file: file, line: line)
        XCTAssertEqual(b, blue, accuracy: accuracy, "blue", file: file, line: line)
        XCTAssertEqual(a, alpha, accuracy: accuracy, "alpha", file: file, line: line)
    }

    static func assertSameColor(
        _ lhs: UIColor?, _ rhs: UIColor?, file: StaticString = #filePath, line: UInt = #line
    ) {
        guard let rhs = rhs else {
            XCTFail("Expected color is nil", file: file, line: line)
            return
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        rhs.getRed(&r, green: &g, blue: &b, alpha: &a)
        assertColor(lhs, red: r, green: g, blue: b, alpha: a, file: file, line: line)
    }

    static func jsonObject(from data: Data?) -> [String: Any]? {
        guard let data = data else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}

// MARK: - ServiceSnapshot
/// save and restore the customization of the shared service
struct ServiceSnapshot {
    let values: [String: Any?]
    let descriptionMaxLength: Int?
    let shakeGestureEnable: Bool?
    let shakeSensitivity: ShakeSensitivity?
    let additionalParams: [String: Any]?

    init(_ service: AppRemarkService) {
        values = [
            "appBarBackgroundColor": service.appBarBackgroundColor,
            "appBarTitleText": service.appBarTitleText,
            "appBarTitleColor": service.appBarTitleColor,
            "pageBackgroundColor": service.pageBackgroundColor,
            "remarkTypeLabelText": service.remarkTypeLabelText,
            "labelColor": service.labelColor,
            "inputTextColor": service.inputTextColor,
            "hintColor": service.hintColor,
            "descriptionLabelText": service.descriptionLabelText,
            "descriptionHintText": service.descriptionHintText,
            "buttonText": service.buttonText,
            "buttonTextColor": service.buttonTextColor,
            "buttonBackgroundColor": service.buttonBackgroundColor,
        ]
        descriptionMaxLength = service.descriptionMaxLength
        shakeGestureEnable = service.shakeGestureEnable
        shakeSensitivity = service.shakeSensitivity
        additionalParams = service.additionalParams
    }

    func restore(_ service: AppRemarkService) {
        func value(_ key: String) -> String? { values[key] as? String }
        service.appBarBackgroundColor = value("appBarBackgroundColor")
        service.appBarTitleText = value("appBarTitleText")
        service.appBarTitleColor = value("appBarTitleColor")
        service.pageBackgroundColor = value("pageBackgroundColor")
        service.remarkTypeLabelText = value("remarkTypeLabelText")
        service.labelColor = value("labelColor")
        service.inputTextColor = value("inputTextColor")
        service.hintColor = value("hintColor")
        service.descriptionLabelText = value("descriptionLabelText")
        service.descriptionHintText = value("descriptionHintText")
        service.buttonText = value("buttonText")
        service.buttonTextColor = value("buttonTextColor")
        service.buttonBackgroundColor = value("buttonBackgroundColor")
        service.descriptionMaxLength = descriptionMaxLength
        service.shakeGestureEnable = shakeGestureEnable
        service.shakeSensitivity = shakeSensitivity
        service.additionalParams = additionalParams
    }
}
