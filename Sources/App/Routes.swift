import Vapor
import  AuthProvider
import Sessions

final class Routes: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }
        
        
        try builder.resource("posts", PostController.self)
        builder.get("logout", handler: UserController().logout)
        builder.post("login", handler: UserController().login)
        builder.post("register", handler: UserController().register)
        builder.grouped(TokenAuthenticationMiddleware(User.self))
            .get("info", handler: UserController().info)
    }
}

/// Since Routes doesn't depend on anything
/// to be initialized, we can conform it to EmptyInitializable
///
/// This will allow it to be passed by type.
extension Routes: EmptyInitializable { }
