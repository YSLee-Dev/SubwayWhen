//
//  DependencyKey.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var totalLoad: TotalLoadProtocol {
        get {self[TotalLoadModelDependencyKey.self]}
        set {self[TotalLoadModelDependencyKey.self] = newValue}
    }
}
