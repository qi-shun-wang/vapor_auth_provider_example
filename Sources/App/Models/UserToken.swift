//
//  UserToken.swift
//  Hello
//
//  Created by QiShunWang on 2017/5/22.
//
//

import Vapor
import FluentProvider
import HTTP

final class UserToken: Model {
    
    struct Properties {
        static let id = "id"
        static let token = "token"
        static let userId = "user_Id"
        static let password = "password"
    }
    
    let storage = Storage()
    
    /// The token of the UserToken
    let token: UUID
    let userId:Identifier
    
    /// Creates a new UserToken
    init(user:User) {
        self.token = UUID()
        self.userId = user.id!
    }
    var user: Parent<UserToken, User> {
        return parent(id: userId)
    }
    // MARK: Fluent Serialization
    
    /// Initializes the UserToken from the
    /// database row
    init(row: Row) throws {
        token = try row.get(Properties.token)
        userId = try row.get(Properties.userId)
    }
    
    // Serializes the UserToken to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.token, token)
        try row.set(Properties.userId, userId)
        return row
    }
}

// MARK: Fluent Preparation

extension UserToken: Preparation {
    /// Prepares a table/collection in the database
    /// for storing UserTokens
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string(Properties.token)
            users.foreignId(for: User.self)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
 
