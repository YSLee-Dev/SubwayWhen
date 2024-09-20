//
//  DependencyKey.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 9/20/24.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var totalLoad: TotalLoadTCADependencyProtocol {
        get {self[TotalLoadModelDependencyKey.self]}
        set {self[TotalLoadModelDependencyKey.self] = newValue}
    }
}
