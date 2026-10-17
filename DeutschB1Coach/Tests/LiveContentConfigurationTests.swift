import XCTest
@testable import DeutschB1Coach

final class LiveContentConfigurationTests: XCTestCase {
    func testRemoteServicesAreDisabledWithoutConfiguration() {
        for value: String? in [nil, "", "   ", "$(LiveContentBaseURL)"] {
            XCTAssertNil(LiveContentConfiguration.parse(rawURL: value))
        }
    }

    func testRejectsUnsafeOrAmbiguousURLs() {
        for value in ["http://example.com", "https:/path", "https://user:password@example.com", "https://example.com?token=x", "https://example.com#fragment"] {
            XCTAssertNil(LiveContentConfiguration.parse(rawURL: value), value)
        }
    }

    func testAcceptsExplicitHTTPSDeployment() throws {
        let configuration = try XCTUnwrap(LiveContentConfiguration.parse(rawURL: " https://example.com/course ", publicAPIKey: " public-key "))
        XCTAssertEqual(configuration.baseURL.absoluteString, "https://example.com/course")
        XCTAssertEqual(configuration.publicAPIKey, "public-key")
    }
}
