//
//  TotalLoadModelDependencyKey.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 9/20/24.
//

import Foundation
import ComposableArchitecture

enum TotalLoadModelDependencyKey: DependencyKey {
    static var liveValue: TotalLoadTCADependencyProtocol = TotalLoadTCADependency()
    static var previewValue: any TotalLoadTCADependencyProtocol = PreviewTotalLoadTCADependency()
    static var testValue: any TotalLoadTCADependencyProtocol = TestTotalLoadTCADependency()
}
