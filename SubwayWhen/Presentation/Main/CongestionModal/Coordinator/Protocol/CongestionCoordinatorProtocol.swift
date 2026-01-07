//
//  CongestionCoordinatorProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/7/26.
//

import Foundation

protocol CongestionCoordinatorProtocol: AnyObject {
    func didDisappear(coordinator: Coordinator)
    func dismiss()
}
