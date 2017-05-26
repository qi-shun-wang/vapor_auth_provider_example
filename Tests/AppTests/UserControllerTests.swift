import XCTest
import Testing
import HTTP
import Sockets
import Sessions
@testable import Vapor
@testable import App

class UserControllerTests: XCTestCase {
    let _name:String = "qishun"
    let username:String = "wang"
    let password:String = "wang"
    var loginToken:String = ""
    let not_a_user_name:String = "shun"
    
    let controller = UserController()
    
    func testUserRoutes() throws {
        let userId1 = try register(_name,username,password)
        try registerAgain(_name,username,password)
        try login(username,password,equalTo: userId1!)
        try info()
        try logout()
    }
    
    func register(_ name:String,_ username:String,_ password:String)throws -> String? {
        let req = Request.makeTest(method: .post, path: "register")
        req.json = try JSON(node:
            [
                "name": name,
                "username": username,
                "password": password
            ])
        
        let res = try controller.register(req).makeResponse()
        let json = res.json
        
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["username"])
        XCTAssertNil(json?["password"])
        XCTAssertEqual(json?["name"], req.json?["name"])
        XCTAssertEqual(json?["username"], req.json?["username"])
        
        return try json?.get("id")
    }
    
    func registerAgain(_ name:String,_ username:String,_ password:String)throws  {
        let req = Request.makeTest(method: .post, path: "register")
        
        req.json = try JSON(node: [
            "name": name,
            "username": username,
            "password": password
            ])
        
        do {
            _ = try controller.register(req).makeResponse()
        }catch let error {
            XCTAssertTrue(error is Abort)
            let e = error as! Abort
            let re =  Abort(.badRequest, metadata: nil, reason:  "user is exist", identifier: nil, possibleCauses: nil, suggestedFixes: nil, documentationLinks: nil, stackOverflowQuestions: nil, gitHubIssues: nil)
            XCTAssertTrue(e.status == re.status)
            XCTAssertTrue(e.reason == re.reason)
            
            
        }
        
        
        
    }
    
    func login(_ username:String,_ password:String,equalTo userId:String) throws {
        let user_from_db = try User.find(userId)
        let req = Request.makeTest(method: .post, path: "login")
        req.json = try JSON(node:
            [
                
                "username": username,
                "password": password
            ])
        
        let res = try controller.login(req).makeResponse()
        let json = res.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["username"])
        XCTAssertNil(json?["password"])
        XCTAssertEqual(json?["name"]?.string, user_from_db?.name)
        XCTAssertEqual(json?["username"]?.string, user_from_db?.username)
        
        loginToken = try(user_from_db?.tokens.first()?.token.uuidString)!
        XCTAssertEqual(json?["token"]?.string,loginToken )
        
        
    }
    func info() throws {
        
        let req = Request.makeTest(method: .get,headers:[HeaderKey.authorization:"Bearer \(loginToken)" ], path: "info")
        
        do {
         _ = try controller.info(req).makeResponse()
        }catch {
            
            XCTAssert(error is Sessions.SessionsError)
        }
        
    }
    func logout() throws {
        
        let req = Request.makeTest(method: .get, path: "logout")
        
        let res = try controller.logout(req).makeResponse()
        let json = res.json
        XCTAssertNotNil(json)
        let rjson = try! JSON(node:["result":"logout success"])
        XCTAssert(json! == rjson )
        
        
    }
    
    func loginNotRegisted(_ username:String) throws {
        let req = Request.makeTest(method: .post, path: "login")
        req.json = try JSON(node: ["name": username])
    }
}


// MARK: Manifest

extension UserControllerTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testUserRoutes", testUserRoutes),
        ]
}
