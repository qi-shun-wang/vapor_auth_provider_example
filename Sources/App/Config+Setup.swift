//import FluentProvider
import MySQLProvider
import RedisProvider
import AuthProvider
import Sessions


extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
        try setupMiddleware()
        setupLoggers()
        
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(RedisProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        
        preparations.append(Post.self)
        preparations.append(User.self)
        preparations.append(UserToken.self)
    }
    
    private func setupLoggers()  {
        addConfigurable(log:EmailLoger.init, name: "email")
    }
    
    
    private func setupMiddleware() throws{
        
      
        addConfigurable(middleware: PersistMiddleware(User.self), name: "persist-user")
       try addConfigurable(middleware: SessionsMiddleware( CacheSessions.init(RedisCache.init(config: self)), cookieName: "user-cookie"), name: "sessions")
    }
}
