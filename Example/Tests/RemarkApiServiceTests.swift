import XCTest
import UIKit
@testable import AppsOnAir_AppRemark

class RemarkApiServiceTests: XCTestCase {

    private let signedURL = "https://bucket.test/upload/file.png?X-Goog-Algorithm=RSA&X-Goog-Signature=abc123"

    override func setUp() {
        super.setUp()
        MockURLProtocol.register()
    }

    override func tearDown() {
        MockURLProtocol.unregister()
        super.tearDown()
    }

    // MARK: - apiGetSignInURL
    func testGetSignInURLSendsPostRequestWithJSONBody() {
        MockURLProtocol.handler = { _ in .init(data: MockURLProtocol.jsonData(["status": "SUCCESS"])) }
        let done = expectation(description: "completion")
        let payload: NSDictionary = ["data": ["fileName": "app_1", "fileType": "image/png", "appId": "id"]]

        RemarkApiService.apiGetSignInURL(apiGetSignInPassData: payload) { _ in done.fulfill() }
        wait(for: [done], timeout: 5)

        let request = MockURLProtocol.requests.first
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
        XCTAssertEqual(request?.url?.absoluteString, EnvironmentConfig.getSignInURL)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept"), "application/json")
        let body = TestHelper.jsonObject(from: request?.httpBody)
        XCTAssertEqual((body?["data"] as? [String: Any])?["fileName"] as? String, "app_1")
    }

    func testGetSignInURLReturnsJSONOnSuccess() {
        let response: [String: Any] = [
            "status": "SUCCESS", "data": ["signedURL": signedURL, "fileUrl": "files/file.png"],
        ]
        MockURLProtocol.handler = { _ in .init(data: MockURLProtocol.jsonData(response)) }
        let done = expectation(description: "completion")

        RemarkApiService.apiGetSignInURL { json in
            XCTAssertEqual(json["status"] as? String, "SUCCESS")
            XCTAssertEqual((json["data"] as? [String: Any])?["fileUrl"] as? String, "files/file.png")
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testGetSignInURLReturnsJSONEvenForNon200Status() {
        MockURLProtocol.handler = { _ in
            .init(statusCode: 403, data: MockURLProtocol.jsonData(["status": "FAILURE", "message": "Forbidden"]))
        }
        let done = expectation(description: "completion")

        RemarkApiService.apiGetSignInURL { json in
            XCTAssertEqual(json["message"] as? String, "Forbidden")
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testGetSignInURLReturnsEmptyOnNetworkError() {
        MockURLProtocol.handler = { _ in .init(error: URLError(.timedOut)) }
        let done = expectation(description: "completion")

        RemarkApiService.apiGetSignInURL { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testGetSignInURLReturnsEmptyOnInvalidJSON() {
        MockURLProtocol.handler = { _ in .init(data: Data("<html>error</html>".utf8)) }
        let done = expectation(description: "completion")

        RemarkApiService.apiGetSignInURL { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testGetSignInURLReturnsEmptyOnEmptyBody() {
        MockURLProtocol.handler = { _ in .init(statusCode: 500, data: nil) }
        let done = expectation(description: "completion")

        RemarkApiService.apiGetSignInURL { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testGetSignInURLDoesNotCallCompletionForNonDictionaryJSON() {
        // current behavior: a top level JSON array is neither a dictionary nor a parse error
        MockURLProtocol.handler = { _ in .init(data: MockURLProtocol.jsonData([1, 2, 3])) }
        let notCalled = expectation(description: "completion not called")
        notCalled.isInverted = true

        RemarkApiService.apiGetSignInURL { _ in notCalled.fulfill() }
        wait(for: [notCalled], timeout: 1)
        XCTAssertEqual(MockURLProtocol.requests.count, 1)
    }

    // MARK: - apiUploadImage
    func testUploadImageFailsForImageWithoutData() {
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(image: UIImage(), signUrl: signedURL) { success in
            XCTAssertFalse(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertTrue(MockURLProtocol.requests.isEmpty, "no request without image data")
    }

    func testUploadImageFailsForInvalidURL() {
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(image: TestHelper.makeImage(), signUrl: "") { success in
            XCTAssertFalse(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    func testUploadImageFailsForURLWithoutQuery() {
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(
            image: TestHelper.makeImage(), signUrl: "https://bucket.test/upload/file.png"
        ) { success in
            XCTAssertFalse(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
        XCTAssertTrue(MockURLProtocol.requests.isEmpty)
    }

    func testUploadImageSendsPutRequestWithSignatureHeader() {
        MockURLProtocol.handler = { _ in .init(statusCode: 200) }
        let image = TestHelper.makeImage()
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(image: image, signUrl: signedURL) { _ in done.fulfill() }
        wait(for: [done], timeout: 5)

        let request = MockURLProtocol.requests.first
        XCTAssertEqual(request?.url?.absoluteString, signedURL)
        XCTAssertEqual(request?.httpMethod, "PUT")
        // last query param is sent as a header
        XCTAssertEqual(request?.value(forHTTPHeaderField: "X-Goog-Signature"), "abc123")
        XCTAssertNil(request?.value(forHTTPHeaderField: "X-Goog-Algorithm"))
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "image/png")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request?.httpBody, image.pngData())
    }

    func testUploadImageSucceedsOn200() {
        MockURLProtocol.handler = { _ in .init(statusCode: 200) }
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(image: TestHelper.makeImage(), signUrl: signedURL) { success in
            XCTAssertTrue(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testUploadImageFailsOnNon200() {
        [201, 400, 403, 500].forEach { code in
            MockURLProtocol.handler = { _ in .init(statusCode: code) }
            let done = expectation(description: "completion \(code)")

            RemarkApiService.apiUploadImage(image: TestHelper.makeImage(), signUrl: signedURL) { success in
                XCTAssertFalse(success, "status \(code) must fail")
                done.fulfill()
            }
            wait(for: [done], timeout: 5)
        }
    }

    func testUploadImageFailsOnNetworkErrorAndCompletesOnce() {
        MockURLProtocol.handler = { _ in .init(error: URLError(.notConnectedToInternet)) }
        let done = expectation(description: "completion")
        done.assertForOverFulfill = true

        RemarkApiService.apiUploadImage(image: TestHelper.makeImage(), signUrl: signedURL) { success in
            XCTAssertFalse(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testUploadImageWithSingleQueryParam() {
        MockURLProtocol.handler = { _ in .init(statusCode: 200) }
        let done = expectation(description: "completion")

        RemarkApiService.apiUploadImage(
            image: TestHelper.makeImage(), signUrl: "https://bucket.test/f.png?token=xyz"
        ) { success in
            XCTAssertTrue(success)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        XCTAssertEqual(MockURLProtocol.requests.first?.value(forHTTPHeaderField: "token"), "xyz")
    }

    // MARK: - apiAddRemark
    func testAddRemarkSendsPostRequestWithPayload() {
        MockURLProtocol.handler = { _ in .init(data: MockURLProtocol.jsonData(["status": "SUCCESS"])) }
        let done = expectation(description: "completion")
        let payload: NSDictionary = [
            "where": ["appId": "app-id"],
            "data": ["description": "Hello", "type": "BUG"],
        ]

        RemarkApiService.apiAddRemark(apiPassData: payload) { _ in done.fulfill() }
        wait(for: [done], timeout: 5)

        let request = MockURLProtocol.requests.first
        XCTAssertEqual(request?.url?.absoluteString, EnvironmentConfig.addFeedback)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept"), "application/json")
        let body = TestHelper.jsonObject(from: request?.httpBody)
        XCTAssertEqual((body?["where"] as? [String: Any])?["appId"] as? String, "app-id")
        XCTAssertEqual((body?["data"] as? [String: Any])?["type"] as? String, "BUG")
    }

    func testAddRemarkReturnsServerJSON() {
        MockURLProtocol.handler = { _ in
            .init(data: MockURLProtocol.jsonData(["status": "SUCCESS", "message": "Thanks!"]))
        }
        let done = expectation(description: "completion")

        RemarkApiService.apiAddRemark { json in
            XCTAssertEqual(json["status"] as? String, "SUCCESS")
            XCTAssertEqual(json["message"] as? String, "Thanks!")
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testAddRemarkReturnsJSONForErrorStatus() {
        MockURLProtocol.handler = { _ in
            .init(statusCode: 422, data: MockURLProtocol.jsonData(["error": "Invalid", "message": "Bad"]))
        }
        let done = expectation(description: "completion")

        RemarkApiService.apiAddRemark { json in
            XCTAssertEqual(json["error"] as? String, "Invalid")
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testAddRemarkReturnsEmptyOnNetworkError() {
        MockURLProtocol.handler = { _ in .init(error: URLError(.cannotFindHost)) }
        let done = expectation(description: "completion")

        RemarkApiService.apiAddRemark { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testAddRemarkReturnsEmptyOnInvalidJSON() {
        MockURLProtocol.handler = { _ in .init(data: Data("not json".utf8)) }
        let done = expectation(description: "completion")

        RemarkApiService.apiAddRemark { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
    }

    func testAddRemarkWithEmptyPayloadSendsEmptyObject() {
        MockURLProtocol.handler = { _ in .init(data: MockURLProtocol.jsonData([:])) }
        let done = expectation(description: "completion")

        RemarkApiService.apiAddRemark { json in
            XCTAssertTrue(json.isEmpty)
            done.fulfill()
        }
        wait(for: [done], timeout: 5)
        XCTAssertEqual(MockURLProtocol.requests.first?.httpBody, Data("{}".utf8))
    }
}
