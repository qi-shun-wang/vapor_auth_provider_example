//
//  EmailLoger.swift
//  Hello
//
//  Created by QiShunWang on 2017/5/18.
//
//

@_exported import Vapor

final class EmailLoger:LogProtocol,ConfigInitializable {
    init(config: Config) throws {
        
    }

    var enabled: [LogLevel] = [.info]
    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        print(message.uppercased() + "!!!!!!!")
    }
   
}
 
