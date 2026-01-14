//
//  AppLogger.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/14/26.
//

import Foundation
import OSLog

struct AppLogger {
    private let logger: Logger
    private let categoryName: String
    private let totalLogEnabled: Bool
    
    enum LogLevel {
        case error, info, debug
    }
    
    func log(_ level: LogLevel, _ message: String, enableLog: Bool = true) {
        if !enableLog || !self.totalLogEnabled {return}
        
        switch level {
        case .info: self.logger.info("\(self.categoryName): \(message)")
        case .error: self.logger.error("\(self.categoryName): \(message)")
        case .debug: self.logger.debug("\(self.categoryName): \(message)")
        }
    }
}

extension AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.yslee.subwayWhen"
}
