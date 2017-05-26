//
//  UserController.swift
//  Hello
//
//  Created by QiShunWang on 2017/5/22.
//
//
import HTTP
import Foundation
import Authentication

final class UserController {
    
    
    func register(_ req:Request) throws -> ResponseRepresentable {
        
        guard let username = req.data[User.Properties.username]?.string else {
            throw Abort.init(.badRequest, reason: "username property")
        }
        guard try User.makeQuery().filter("username", username).count() == 0 else {
            throw Abort.init(.badRequest, reason: "user is exist")
        }
        
        guard let name = req.data[User.Properties.name]?.string else {
            throw Abort.init(.badRequest, reason: "name property")
        }
        
        guard let password = req.data[User.Properties.password]?.string else {
            throw Abort.init(.badRequest, reason: "password property")
        }
        
        let user = User(name: name, username: username, password: password.makeBytes())
        try user.save()
        let token = UserToken(user: user)
        try token.save()
        
        return user
    }
    
    
    
    func login(_ req:Request) throws -> ResponseRepresentable {
        
        guard let username = req.data[User.Properties.username]?.string else {
            throw Abort.init(.badRequest, reason: "username property")
        }
        guard let password = req.data[User.Properties.password]?.string else {
            throw Abort.init(.badRequest, reason: "password property")
        }
        
        let passwordCredentials = Password(username: username, password: password)
        
        let user = try User.authenticate(passwordCredentials)
        req.auth.authenticate(user)
        return user
    }
    
    
    
    func logout(_ req:Request) throws -> ResponseRepresentable {
        try req.auth.unauthenticate()
        return try Response.init(status: .ok, json: JSON(node:["result":"logout success"]))
    }
    
    
    
    func info(_ req:Request) throws -> ResponseRepresentable {
        return try req.user()
    }
    
    
}
