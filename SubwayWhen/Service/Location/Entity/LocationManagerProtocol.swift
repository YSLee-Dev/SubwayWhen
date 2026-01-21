//
//  LocationManagerProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation

protocol LocationManagerProtocol {
    func locationAuthCheck()  -> Bool
    func locationAuthRequest() async -> Bool
    func locationRequest() async -> LocationData?
}
