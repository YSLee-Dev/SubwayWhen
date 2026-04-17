//
//  RealtimeCoordinatorDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/17/26.
//

import Foundation

protocol RealtimeCoordinatorDelegate: AnyObject {
    func pop()
    func disappear(realtimeCoordinator : RealtimeCoordinator)
}
