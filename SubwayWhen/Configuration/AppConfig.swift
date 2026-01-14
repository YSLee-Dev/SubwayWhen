//
//  AppConfig.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/14/26.
//

import Foundation

final class AppConfig {
    
    // MARK: - Singleton
    
    static let shared = AppConfig()
    private init() {}
    
    // MARK: - Log
    
    /// 뷰와 관련된 로그 표출 여부를 관리해요.
    let enableViewLog = true
    
    /// Coordinator와 관련된 로그 표출 여부를 관리해요.
    let enableCoordinatorLog = true
    
    /// 네트워크와 관련된 로그 표출 여부를 관리해요.
    let enableTotalNetworkLog = true
}
