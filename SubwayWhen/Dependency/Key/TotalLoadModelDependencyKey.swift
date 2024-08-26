//
//  TotalLoadModelDependencyKey.swift
//  SubwayWhenNetworking
//
//  Created by 이윤수 on 8/26/24.
//

import Foundation
import ComposableArchitecture

enum TotalLoadModelDependencyKey: DependencyKey {
    static var liveValue: TotalLoadProtocol = TotalLoadModel()
    static var previewValue: any TotalLoadProtocol = PreviewTotalLoadModel()
}
