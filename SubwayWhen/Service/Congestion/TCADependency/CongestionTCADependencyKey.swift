//
//  CongestionTCADependencyKey.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation
import ComposableArchitecture

enum CongestionTCADependencyKey: DependencyKey {
    static var liveValue: CongestionManagerProtocol = CongestionManager.shared
}
