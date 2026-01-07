//
//  PreviewLocationManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation

class PreviewLocationManager: LocationManagerProtocol {
    func locationRequest() async -> LocationData? {
        return .init(lat: 37.5665, lon: 126.9780)
    }
    
    func locationAuthRequest() async -> Bool {
        return true
    }
    
    func locationAuthCheck() -> Bool {
        return true
    }
}
