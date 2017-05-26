import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

/// This file shows an example of testing
/// routes through the Droplet.

class RouteTests: TestCase {
    let drop = try! Droplet.testable()
    
    func testHello() throws {
        try drop
            .testResponse(to: .get, at: "hello")
            .assertStatus(is: .ok)
            .assertJSON("hello", equals: "world")
    }
    
//    func testRegister() throws {
//        //        Body(JSON(StructuredData(["name":"wang"]))
//        let req = Request(method: .post, uri: URI(hostname: "0.0.0.0", path: "register"),
//                          body: JSON(["name":"wang"])
//        )
//        try drop
//            .testResponse(to: req)
//            .assertStatus(is:.badRequest)
//        
//        
//        
//    }
}

// MARK: Manifest

extension RouteTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testHello", testHello),
//        ("testRegister", testRegister),
        ]
}
