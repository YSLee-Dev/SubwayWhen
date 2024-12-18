//
//  TestLocationManager.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/18/24.
//

import Foundation

class TestLocationManager: LocationManagerProtocol {
    var locationData: LocationData? = nil
    var authRequest: Bool? = nil
    var authCheck: Bool? = nil
    
    func locationRequest() async -> LocationData? {
        return self.locationData
    }
    
    func locationAuthRequest() async -> Bool {
        return self.authRequest!
    }
    
    func locationAuthCheck() -> Bool {
        return self.authCheck!
    }
}
