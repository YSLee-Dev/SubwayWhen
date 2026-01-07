//
//  LocationManagerTCADependencyKey.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/4/24.
//

import Foundation
import ComposableArchitecture

enum LocationManagerTCADependencyKey: DependencyKey {
    static var liveValue: LocationManagerProtocol = LocationManager.shared
    static var previewValue: any LocationManagerProtocol = PreviewLocationManager()
    static var testValue: any LocationManagerProtocol = TestLocationManager()
}
