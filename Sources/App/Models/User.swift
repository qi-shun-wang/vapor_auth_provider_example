//
//  User.swift
//  Hello
//
//  Created by QiShunWang on 2017/5/22.
//
//
import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class User: Model {
    
    
    struct Properties {
        static let id = "id"
        static let name = "name"
        static let username = "username"
        static let password = "password"
    }
    
    
    let storage = Storage()
    
    /// The name of the User
    
    var name: String
    var username: String
    var password: Bytes
    
    /// Creates a new User
    init(name: String ,username:String,password:Bytes) {
        self.name = name
        self.username = username.lowercased()
        self.password = password
        
    }
    var tokens: Children<User, UserToken> {
        return children()
    }
    // MARK: Fluent Serialization
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name = try row.get(Properties.name)
        username = try row.get(Properties.username)
        let passwordAsString: String = try row.get(Properties.password)
        password = passwordAsString.makeBytes()
    }
    
    // Serializes the User to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.username, username)
        try row.set(Properties.password, password.makeString())
        
        return row
    }
}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("username")
            builder.string("password")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Node

extension User: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.name, name)
        try node.set(Properties.username, username)
        
        return node
    }
    
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension User: ResponseRepresentable {}
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(name: json.get("name"),
                      username: json.get("username"),
                      password: json.get("password"))
        
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("username", username)
        try json.set("token", tokens.first()?.token)
        return json
    }
}



// MARK: Authentication
extension User: TokenAuthenticatable {
    // join the TestToken table and search for
    // the supplied bearer token to authenticate
    // the user
    public typealias TokenType = UserToken
}

// MARK: HTTP
extension Request {
    func user() throws -> User {
        
        guard let token_from_req = auth.header?.bearer else {
            throw Abort.init(.badRequest, reason: "is missed token")
        }
        
        let user_from_token = try User.authenticate(token_from_req)
        
        guard let user_from_session = try User.fetchPersisted(for: self) else {
            
            throw Abort.init(.badRequest, reason: "fetch Persisted session not found")
        }
        
        
        if user_from_token.id == user_from_session.id {
            return user_from_session
        }
        
        throw Abort.init(.badRequest, reason: "is not correct token")
        
        
        
    }
    
    
}

// MARK: Sessions

extension User:SessionPersistable{}

extension User:PasswordAuthenticatable {
    
    public static let usernameKey = Properties.username
    //    public static let passwordVerifier: PasswordVerifier? = User.passwordHasher
    //    public var hashedPassword: String? {
    //        return password.makeString()
    //    }
    //    public static let passwordHasher = BCryptHasher(cost: 10)
}


