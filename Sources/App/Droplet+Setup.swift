@_exported import Vapor

extension Droplet {
    public func setup() throws {
  
        print(self.cache.self)
        try collection(Routes.self)
    }
}
